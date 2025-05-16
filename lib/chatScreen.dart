import 'package:flutter/material.dart';
import 'chatClient.dart';


class ChatScreenRooms extends StatefulWidget {
  final ChatClient client;

  const ChatScreenRooms({required this.client, super.key});

  @override
  State<ChatScreenRooms> createState() => _ChatScreenRoomsState();
}

class _ChatScreenRoomsState extends State<ChatScreenRooms> {
  final List<String> _messages = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.client.messages.listen((msg) {
      setState(() {
        _messages.add(msg);
      });
    });
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.client.send(text);
      setState(() {
        _messages.add("Me: $text");
        _controller.clear();
      });
    }
  }

  @override
  void dispose() {
    widget.client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (_, i) => ListTile(title: Text(_messages[i])),
            ),
          ),
          Row(
            children: [
              Expanded(child: TextField(controller: _controller)),
              IconButton(icon: Icon(Icons.send), onPressed: _send),
            ],
          ),
        ],
      ),
    );
  }
}