import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  late WebSocketChannel _channel;
  Function(String)? onData;
  Function()? onDone;
  Function(dynamic)? onError;

  void connect(String url) {
    _channel = WebSocketChannel.connect(Uri.parse(url));

    _channel.stream.listen((data) {
      if (onData != null) onData!(data);
    }, onError: (error) {
      if (onError != null) onError!(error);
    }, onDone: () {
      if (onDone != null) onDone!();
    });
  }

  void send(String message) {
    _channel.sink.add(message);
  }

  void close() {
    _channel.sink.close();
  }
}
