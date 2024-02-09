import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:esc_printer_test/abstract_class/PrinterServiceAbstract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';

class NetworkPrinterService implements PrinterServiceAbstract {
  String printerIp;
  int printerPort;

  NetworkPrinterService({required this.printerIp, required this.printerPort});

  @override
  Future<void> generateAndPrintReceipt() async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    // Receipt generation logic
    bytes += generator.setGlobalCodeTable('CP1252');
    bytes += generator.text('Test Print',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Product 1');
    bytes += generator.text('Product 2');
    bytes += generator.text('Product 3');
    bytes += generator.feed(2);
    bytes += generator.cut();

    // Printing logic
    Socket? socket;
    try {
      socket = await Socket.connect(this.printerIp, this.printerPort);
      debugPrint(
          'Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');
      socket.add(Uint8List.fromList(bytes));
      await socket.flush();
      debugPrint('Receipt sent to printer');
    } catch (e) {
      debugPrint('Failed to connect to printer: $e');
    } finally {
      await socket?.close();
    }
  }

  Future<void> printReceiptJson(String orderJson) async {
    debugPrint('Printing order receipt:');
    final orderData = json.decode(orderJson);
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    // Setting the character code table
    bytes += generator.setGlobalCodeTable('CP1252');

    // Receipt Header
    bytes += generator.text('Store Name',
        styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('Address line 1\nAddress line 2',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.hr();

    // Adding order details (Dynamically generated based on JSON data)
    bytes += formatOrderReceipt(orderData, generator);

    // Feed lines and cut
    bytes += generator.feed(2);
    bytes += generator.cut();

    // Printing logic
    Socket? socket;
    try {
      socket = await Socket.connect(this.printerIp, this.printerPort);
      debugPrint(
          'Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');
      socket.add(Uint8List.fromList(bytes));
      await socket.flush();
      debugPrint('Receipt sent to printer');
    } catch (e) {
      debugPrint('Failed to connect to printer: $e');
    } finally {
      await socket?.close();
    }
  }

  List<int> formatOrderReceipt(
      Map<String, dynamic> orderData, Generator generator) {
    List<int> bytes = [];
    debugPrint('Formatting order receipt');
    // debugPrint('Order data: $orderData');

    // Header Section
    bytes += generator.text('Order #${orderData["id"]}',
        styles: const PosStyles(
            width: PosTextSize.size2,
            height: PosTextSize.size2,
            underline: true,
            bold: true,
            align: PosAlign.center));
    String dateCreated = orderData["date_created"].toString().split('T')[0];
    // String timeCreated = orderData["date_created"].toString().split('T')[1];
    bytes += generator.text('Date: $dateCreated',
        styles: PosStyles(align: PosAlign.center));
    // bytes += generator.text('Time: $timeCreated',
    // styles: PosStyles(align: PosAlign.center));
    bytes += generator.hr();

    // Products Section
    var lineItems = orderData['line_items'] as List<dynamic>?;
    if (lineItems != null) {
      // Ensure line_items is not null
      for (var item in lineItems) {
        bytes += generator.text('${item["name"]} x ${item["quantity"]}',
            styles: PosStyles(bold: true));
        bytes += generator.text(
            ' ${orderData["currency_symbol"]}${item["total"]}\n',
            styles: PosStyles(align: PosAlign.right));

        var metaData = item['meta_data'] as List<dynamic>?;
        if (metaData != null) {
          // Ensure meta_data is not null
          for (var data in metaData) {
            if (data['key'].startsWith('_')) continue;
            var displayKey =
                data["display_key"].toString().replaceAll('+&#036;', '\$');
            var displayValue = data["display_value"].toString();
            bytes += generator.text('$displayKey: $displayValue\n',
                styles: PosStyles(align: PosAlign.left));
          }
        }
        bytes += generator.hr();
      }
    }

    // Subtotal, Taxes, and Total
    bytes += generator.text('SUBTOTAL', styles: PosStyles(bold: true));
    bytes += generator.text(
        '${orderData["currency_symbol"]}${orderData["total"]}',
        styles: PosStyles(align: PosAlign.right, bold: true));
    bytes += generator.hr(ch: '=');

// Check if 'tax_lines' is not null and is a list before iterating
    var taxLines = orderData['tax_lines'] as List<dynamic>?;
    if (taxLines != null) {
      for (var taxLine in taxLines) {
        // Safely use 'taxLine' assuming it's not null
        bytes += generator.text('${taxLine["label"]}',
            styles: PosStyles(bold: true));
        // Ensure the tax total is formatted with two decimal places
        var taxTotal =
            double.tryParse('${taxLine["tax_total"]}')?.toStringAsFixed(2) ??
                '0.00';
        bytes += generator.text('${orderData["currency_symbol"]}$taxTotal',
            styles: PosStyles(align: PosAlign.right, bold: true));
        bytes += generator.hr();
      }
    } else {
      // Handle the case where 'tax_lines' is null
      // For example, you might want to log this situation or add default values
      debugPrint("No tax lines available");
    }

    bytes += generator.text('TOTAL', styles: PosStyles(bold: true));
    bytes += generator.text(
        '${orderData["currency_symbol"]}${orderData["total"]}',
        styles: PosStyles(
            align: PosAlign.right, bold: true, height: PosTextSize.size2));

    // Payment Method
    bytes += generator.hr(ch: '-');
    bytes += generator.text('PAYMENT METHOD', styles: PosStyles(bold: true));
    bytes += generator.text('${orderData["payment_method_title"]}',
        styles: PosStyles(align: PosAlign.right, bold: true));
    bytes += generator.hr(ch: '=');

// Customer Details
    if (orderData["billing"] != null && orderData["billing"] is Map) {
      Map<String, dynamic> billingInfo = orderData["billing"];
      String firstName = billingInfo["first_name"] ?? 'Unknown';
      String lastName = billingInfo["last_name"] ?? 'Unknown';
      String phone = billingInfo["phone"] ?? 'Unknown';
      String email = billingInfo["email"] ?? 'Unknown';

      bytes +=
          generator.text('Customer Details', styles: PosStyles(bold: true));
      bytes +=
          generator.text('$firstName $lastName', styles: PosStyles(bold: true));
      bytes += generator.text(phone);
      bytes += generator.text(email, styles: PosStyles(bold: true));
      bytes += generator.hr(ch: '=');
    } else {
      // Handle the case where billing information is not available
      debugPrint("No billing information available");
      // You might want to add some default handling here, or simply skip this section
    }

    return bytes;
  }
}
