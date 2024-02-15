import 'dart:io';
import 'package:esc_printer_test/abstract_class/PrinterServiceAbstract.dart';
import 'package:flutter/material.dart';
import 'package:esc_printer_test/services/NetworkPrinterService.dart';
import 'pages/HomePage.dart';
import 'pages/Settings.dart';
import 'package:window_size/window_size.dart';
import 'package:provider/provider.dart';
import 'class/OrdersProvider.dart';

void main() {
  final printerService =
      NetworkPrinterService(printerIp: '192.168.0.100', printerPort: 9100);

  // Set the window size and title
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('TRT Technologies - Orders Management');
    setWindowMaxSize(const Size(720, 1280));
    setWindowMinSize(const Size(480, 640));
  }

  runApp(MyApp(printerService: printerService));
}

class MyApp extends StatefulWidget {
  final PrinterServiceAbstract printerService;

  MyApp({Key? key, required this.printerService}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  List<Widget> _widgetOptions = [];

  @override
  void initState() {
    super.initState();
    _widgetOptions = [
      HomePage(printerService: widget.printerService),
      SettingsPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OrdersProvider>(
      create: (_) => OrdersProvider(),
      child: MaterialApp(
        home: Scaffold(
          body: _widgetOptions.elementAt(_selectedIndex),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
