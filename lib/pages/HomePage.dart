import 'dart:convert';
import 'package:esc_printer_test/abstract_class/PrinterServiceAbstract.dart';
import 'package:esc_printer_test/main_old.dart';
import 'package:flutter/material.dart';
import 'package:esc_printer_test/services/NetworkPrinterService.dart';
import 'package:esc_printer_test/services/WebSocketService.dart';
import 'package:esc_printer_test/class/Order.dart';

List<Order> orders = []; // List to store unique orders

class HomePage extends StatefulWidget {
  final PrinterServiceAbstract printerService;

  HomePage({Key? key, required this.printerService}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WebSocketService().connect(
      'wss://middleware.trttechnologies.ca/',
      onData: (data) {
        setState(() {
          debugPrint('Received data: $data');
          widget.printerService.printReceiptJson(data);
          handleIncomingData(data);
        });
      },
    );
  }

  void handleIncomingData(String jsonData) {
    final Map<String, dynamic> orderJson = json.decode(jsonData);
    final Order newOrder = Order.fromJson(orderJson);

    // Check for duplicates before adding to the list
    if (!orders.any((order) => order.id == newOrder.id)) {
      orders.add(newOrder);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TRT Technologies - Orders Management'),
      ),
      body: orders.isEmpty
          ? Center(child: Text('No orders yet'))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  child: ListTile(
                    title: Text('Order ID: ${order.id}'),
                    subtitle:
                        Text('Status: ${order.status} - Total: ${order.total}'),
                    // Optionally, add a trailing widget, like an icon button for more actions
                    trailing: IconButton(
                      icon: Icon(Icons.print),
                      onPressed: () {
                        // Implement your print function here
                        debugPrint('Printing order: ${order.id}');
                        // widget.printerService.printReceiptJson(order.fulljson);
                      },
                    ),
                    onTap: () {
                      // Implement what happens when you tap on an order
                      debugPrint('Tapped on order: ${order.id}');
                    },
                  ),
                );
              },
            ),
    );
  }
}
