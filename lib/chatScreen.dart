import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatScreenNew extends StatefulWidget {
  final String roomName;
  final WebSocketChannel channel;
  
  const ChatScreenNew({required this.channel, required this.roomName ,super.key});

  @override
  State<ChatScreenNew> createState() => _ChatScreenNewState();
}

class ChatMessage{
  final String sender;
  final String text;
  ChatMessage({
    required this.sender,
    required this.text,
  });
}

class _ChatScreenNewState extends State<ChatScreenNew> {
  List<ChatMessage> messages = [];
  final TextEditingController controller = TextEditingController();
  late StreamSubscription subscription;

  @override
  void initState(){
    super.initState();

    subscription = widget.channel.stream.listen((data){
      final messageData = jsonDecode(data);

      if(messageData["type"]=="message"){
        setState(() {
          messages.add(ChatMessage(
            sender: messageData["from"] ?? "Unknown",
            text: messageData["text"] ?? "",
          ));
        });
      }else if(messageData["type"]=="status"){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(messageData["message"] ?? "")));
      }
    },
        onDone: (){
          if(mounted){
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Connection closed"))
            );
          }
        }

    );


  }

  void sendMessage(){
    if(controller.text.isNotEmpty){
      final text = controller.text.trim();

      widget.channel.sink.add(jsonEncode({
        "type" : "message",
        "room" : widget.roomName,
        "text" : text,
      }));
      setState(() {
        messages.add(ChatMessage(sender: "me", text: text));
      });

      controller.clear();
    }
  }
  @override
  void dispose(){
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("hello chat"),),
      body: Column(
        children: [
          Expanded(child: messages.isNotEmpty
              ? Center(child: Text("No messages yet"))
              : ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context,index){
                    final message = messages[index];
                    return ListTile(
                      title: Text(message.sender + " : " + message.text),
                    );
                  }
                )
          ),

          Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(child: TextField(controller: controller, onSubmitted: (_) => sendMessage,))
                ],
              ),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: sendMessage,
            child: Text('Send'),
          ),

        ],
      ),
    );
  }
}
