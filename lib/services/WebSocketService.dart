import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  Function(String)? onDataReceived;

  static final WebSocketService _instance = WebSocketService._internal();

  factory WebSocketService() => _instance;

  WebSocketService._internal();

  void connect(String serverAddress, {Function(String)? onData}) {
    onDataReceived = onData;
    _channel = IOWebSocketChannel.connect(Uri.parse(serverAddress));

    _channel!.stream.listen((data) {
      // debugPrint(data); // Logging the data
      if (onDataReceived != null) {
        onDataReceived!(
            data); // Call the provided callback function with new data
      }
    }, onDone: () {
      debugPrint('WebSocket Connection Closed');
    }, onError: (error) {
      debugPrint('WebSocket Error: $error');
    });
  }

  void close() {
    _channel?.sink.close();
  }
}
