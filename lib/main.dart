import 'package:esc_printer_test/abstract_class/PrinterServiceAbstract.dart';
import 'package:flutter/material.dart';
import 'package:esc_printer_test/services/NetworkPrinterService.dart';
import 'package:esc_printer_test/services/WebSocketService.dart';

String eventData = 'Waiting for data...';
late PrinterServiceAbstract printerService;
void main() {
  printerService =
      NetworkPrinterService(printerIp: '192.168.0.100', printerPort: 9100);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    WebSocketService().connect(
      'wss://middleware.trttechnologies.ca/',
      onData: (data) {
        // This is where you call setState
        setState(() {
          eventData = data;
          // debugPrint(eventData);
          printerService.printReceiptJson(eventData);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TRT Teechnologies - ESC/POS Printer Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await printerService.generateAndPrintReceipt();
              },
              child: Text('Generate and Print Receipt'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await printerService.printReceiptJson(eventData);
              },
              child: Text('Print Receipt JSON'),
            ),
            SizedBox(
                height: 20), // Provides spacing between the buttons and text
            // Text(eventData), // Display the WebSocket data
          ],
        ),
      ),
    );
  }
}
