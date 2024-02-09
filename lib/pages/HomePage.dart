import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:esc_printer_test/abstract_class/PrinterServiceAbstract.dart';
import 'package:esc_printer_test/services/WebSocketService.dart';
import 'package:esc_printer_test/class/Order.dart';

class HomePage extends StatefulWidget {
  final PrinterServiceAbstract printerService;

  HomePage({Key? key, required this.printerService}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final StreamController<Order> _orderStreamController =
      StreamController.broadcast();
  final List<Order> _printedOrders = [];

  @override
  void initState() {
    super.initState();
    WebSocketService().connect(
      'wss://middleware.trttechnologies.ca/',
      onData: (data) {
        final Order newOrder = Order.fromJson(json.decode(data));
        _orderStreamController.add(newOrder);
      },
    );

    _orderStreamController.stream.listen((Order order) {
      _printAndArchiveOrder(order);
    });
  }

  void _printAndArchiveOrder(Order order) async {
    await widget.printerService.printReceiptJson(order.fulljson);
    setState(() {
      _printedOrders.add(order);
    });
  }

  @override
  void dispose() {
    _orderStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TRT Technologies - Orders Management'),
      ),
      body: _printedOrders.isEmpty
          ? Center(child: Text('No printed orders yet'))
          : ListView.builder(
              itemCount: _printedOrders.length,
              itemBuilder: (context, index) {
                final order = _printedOrders[index];
                return Card(
                  child: ListTile(
                    title: Text('Printed Order ID: ${order.id}'),
                    subtitle:
                        Text('Status: ${order.status} - Total: ${order.total}'),
                  ),
                );
              },
            ),
    );
  }
}
