import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:esc_printer_test/abstract_class/PrinterServiceAbstract.dart';
import 'package:esc_printer_test/services/WebSocketService.dart';
import 'package:esc_printer_test/class/Order.dart';

final StreamController<List<Order>> _orderStreamController =
    StreamController<List<Order>>.broadcast();
final List<Order> _currentOrders = [];
final List<Order> _printedOrders = [];

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
        print('Received data: $data');
        final Order newOrder = Order.fromJson(json.decode(data));
        _currentOrders.add(newOrder);
        _orderStreamController.add(List.from(_currentOrders));

        // Delay printing for testing
        Future.delayed(const Duration(seconds: 0), () {
          if (mounted) {
            // Check if the widget is still mounted
            _printAndArchiveOrder(newOrder);
          }
        });
      },
    );
  }

  void _printAndArchiveOrder(Order order) async {
    try {
      await widget.printerService.printReceiptJson(order.fulljson);
      Future.delayed(Duration(seconds: 1), () {
        // Wait for the printing to complete

        // Printing succeeded, proceed to update the order status and lists
        if (mounted) {
          setState(() {
            _currentOrders.remove(order);
            order.status = 'Printed';
            _printedOrders.add(order);
            _orderStreamController.add(List.from(_currentOrders));
          });
        }
      });
    } catch (e) {
      // Handle printing error, maybe log or show a message to the user
      print('Error printing order ${order.id}: $e');
    }
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
        title: const Text('TRT Technologies - Orders Management'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'Incoming Orders',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: StreamBuilder<List<Order>>(
              stream: _orderStreamController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Order> orders = snapshot.data!;
                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        child: Card(
                          child: ListTile(
                            title: Text('Incoming Order ID: ${order.id}'),
                            subtitle: Text(
                                'Status: ${order.status} - Total: ${order.total}'),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1.0),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: const Center(child: Text('Waiting for orders...')),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'Printed Orders',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: _printedOrders.isEmpty
                ? Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 1.0),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: const Center(child: Text('Waiting for orders...')),
                  )
                : ListView.builder(
                    itemCount: _printedOrders.length,
                    itemBuilder: (context, index) {
                      final order = _printedOrders[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        child: Card(
                          child: ListTile(
                            title: Text('Printed Order ID: ${order.id}'),
                            subtitle: Text(
                                'Status: ${order.status} - Total: ${order.total}'),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
