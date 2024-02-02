import 'package:esc_printer_test/abstract_class/PrinterServiceAbstract.dart';
import 'package:flutter/material.dart';
import 'package:esc_printer_test/services/NetworkPrinterService.dart';

void main() {
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
  late PrinterServiceAbstract printerService;

  @override
  void initState() {
    super.initState();
    printerService =
        NetworkPrinterService(printerIp: '192.168.0.100', printerPort: 9100)
            as PrinterServiceAbstract;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ESC/POS Demo'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await printerService.generateAndPrintReceipt();
          },
          child: Text('Generate and Print Receipt'),
        ),
      ),
    );
  }
}
