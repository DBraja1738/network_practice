import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatClient {
  final WebSocketChannel _channel;
  final Stream<String> messages;

  ChatClient(String serverURL)
      : _channel = WebSocketChannel.connect(Uri.parse(serverURL)),
        messages = WebSocketChannel.connect(Uri.parse(serverURL)).stream
            .map((event) => event.toString());

  void send(String text) {
    _channel.sink.add(jsonEncode({"type": "message", "text": text}));
  }

  void disconnect() {
    _channel.sink.close();
  }
}
