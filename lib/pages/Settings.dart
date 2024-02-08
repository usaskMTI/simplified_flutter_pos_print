import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

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
          ],
        ),
      ),
    );
  }
}
