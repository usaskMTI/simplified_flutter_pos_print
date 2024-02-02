import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:esc_printer_test/abstract_class/PrinterServiceAbstract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';

class NetworkPrinterService implements PrinterServiceAbstract {
  final String printerIp;
  final int printerPort;

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
      socket = await Socket.connect(printerIp, printerPort);
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
    debugPrint('orderJson: $orderJson');
    // final orderData = json.decode(orderJson);
    // final profile = await CapabilityProfile.load();
    // final generator = Generator(PaperSize.mm80, profile);
    // List<int> bytes = [];

    // // Setting the character code table
    // bytes += generator.setGlobalCodeTable('CP1252');

    // // Receipt Header
    // bytes += generator.text('Store Name',
    //     styles: const PosStyles(align: PosAlign.center, bold: true));
    // bytes += generator.text('Address line 1\nAddress line 2',
    //     styles: const PosStyles(align: PosAlign.center));
    // bytes += generator.hr();

    // // Adding order details (Dynamically generated based on JSON data)
    // bytes += formatOrderDetails(orderData, generator);

    // // Feed lines and cut
    // bytes += generator.feed(2);
    // bytes += generator.cut();

    // // Printing logic
    // Socket? socket;
    // try {
    //   socket = await Socket.connect(printerIp, printerPort);
    //   debugPrint(
    //       'Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');
    //   socket.add(Uint8List.fromList(bytes));
    //   await socket.flush();
    //   debugPrint('Receipt sent to printer');
    // } catch (e) {
    //   debugPrint('Failed to connect to printer: $e');
    // } finally {
    //   await socket?.close();
    // }
  }

  List<int> formatOrderDetails(
      Map<String, dynamic> orderData, Generator generator) {
    List<int> bytes = [];
    // Implement the formatting logic here, similar to _formatOrderReceipt
    // Example: Formatting the order ID
    bytes += generator.text('Order #${orderData["id"]}',
        styles: const PosStyles(bold: true));

    // Iterate over items and add them to the receipt
    for (var item in orderData['line_items']) {
      bytes += generator.text('${item["name"]} x ${item["quantity"]}',
          styles: PosStyles(bold: true));
      bytes += generator.text(' ${item["total"]}',
          styles: PosStyles(align: PosAlign.right));
      // Add more item details as needed
    }

    // Add subtotal, taxes, total, etc.
    // Example: Adding subtotal
    bytes += generator.hr();
    bytes += generator.text('SUBTOTAL', styles: PosStyles(bold: true));
    bytes += generator.text('${orderData["subtotal"]}',
        styles: PosStyles(align: PosAlign.right));

    // Add any additional sections as per your receipt format
    return bytes;
  }
}
