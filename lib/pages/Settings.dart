import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final printerService; // Assuming this is how you have access to your printerService

  SettingsPage({this.printerService});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _ipController =
      TextEditingController(); // For network IP
  final TextEditingController _portController =
      TextEditingController(); // For port

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    String? apiKey = prefs.getString('apiKey');
    String? url = prefs.getString('url');
    String? ip = prefs.getString('ip');
    String? port = prefs.getString('port');
    setState(() {
      _apiKeyController.text = apiKey ?? '';
      _urlController.text = url ?? '';
      _ipController.text = ip ?? '192.168.0.100';
      _portController.text = port ?? '9100';
    });
  }

  _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiKey', _apiKeyController.text);
    await prefs.setString('url', _urlController.text);

    // Show confirmation dialog
    _showConfirmationDialog();
  }

  _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Settings Saved'),
          content: Text('Your settings have been successfully saved.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }

  _testPrint() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ip', _ipController.text);
    await prefs.setString('port', _portController.text);
    widget.printerService.testPrint();

    // TODO: Use the testPrint() from PrinterNetworkService to test the connection
    // and also to update the printerIp and printerPort in   NetworkPrinterService(printerIp: '192.168.0.100', printerPort: 9100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('API Key:'),
            TextField(
              controller: _apiKeyController,
              decoration: InputDecoration(hintText: 'Enter your API key'),
            ),
            SizedBox(height: 20),
            Text('URL:'),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(hintText: 'Enter the URL'),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _savePreferences,
                child: Text('Save'),
              ),
            ),
            SizedBox(height: 20),
            Text('Network IP:'),
            TextField(
              controller: _ipController,
              decoration: InputDecoration(hintText: 'Enter the network IP'),
            ),
            SizedBox(height: 20),
            Text('Port:'),
            TextField(
              controller: _portController,
              keyboardType:
                  TextInputType.number, // Ensures numeric input for the port
              decoration: InputDecoration(hintText: 'Enter the port number'),
            ),
            SizedBox(height: 20),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _testPrint,
                child: Text('Connect'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
