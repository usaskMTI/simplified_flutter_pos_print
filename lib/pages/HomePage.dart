import 'package:esc_printer_test/abstract_class/PrinterServiceAbstract.dart';
import 'package:flutter/material.dart';
import 'package:esc_printer_test/services/NetworkPrinterService.dart';
import 'package:esc_printer_test/services/WebSocketService.dart';

class HomePage extends StatefulWidget {
  final PrinterServiceAbstract printerService;

  HomePage({Key? key, required this.printerService}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String eventData = 'Waiting for data...';

  @override
  void initState() {
    super.initState();
    WebSocketService().connect(
      'wss://middleware.trttechnologies.ca/',
      onData: (data) {
        setState(() {
          eventData = data;
          widget.printerService.printReceiptJson(eventData);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TRT Technologies - Orders Management'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your ListView widgets and other UI elements here
          ],
        ),
      ),
    );
  }
}
