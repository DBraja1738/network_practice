import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Chatandrooms extends StatefulWidget {
  final String ip;
  const Chatandrooms({super.key, required this.ip});

  @override
  State<Chatandrooms> createState() => _ChatandroomsState();
}

class _ChatandroomsState extends State<Chatandrooms> {
  TextEditingController _controller = TextEditingController();
   late WebSocketChannel _channel;
  @override
  void initState(){
    super.initState();
    _channel = WebSocketChannel.connect(Uri.parse(widget.ip));


  }

  void createRoom(){
    if(_controller.text.isNotEmpty){
      _channel.sink.add(jsonEncode({
        "type" : "create",
        "name" : _controller.text.trim(),
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hello rooms"),),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
                height: 30,
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(hintText: "enter room name"),
                )

            ),
            ElevatedButton(onPressed: createRoom, child: Text("create room")),
          ],
        ),
      ),
    );
  }
}
