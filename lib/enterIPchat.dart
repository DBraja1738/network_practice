import 'package:flutter/material.dart';
import 'package:network_practice/chat.dart';
import 'chatClient.dart';
import 'chatScreen.dart';
import 'widgets/decorations.dart';
import 'dart:io';
class IPinputChat extends StatefulWidget {
  const IPinputChat({super.key});


  @override
  State<IPinputChat> createState() => _IPinputChatState();
}

class _IPinputChatState extends State<IPinputChat> {
  final TextEditingController controller = TextEditingController();
  String status= "status";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter IP"),),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: [Text("Enter IP"), ],
          ),
          Row(
            children: [Text(status)],
          ),
          SizedBox(height: 70, child:  TextField(controller: controller, decoration: AppDecorations.inputDecoration,),),
          ElevatedButton(onPressed: connectToServer, child: Text("Enter IP"), style: AppDecorations.buttonStyleRed,),
        ],
      ),
    );
  }

  Future<bool> checkServerReachable() async {
    try{
      final socket= await Socket.connect("${controller.text}", 1234, timeout: Duration(seconds: 2));
      socket.destroy();
      return true;
    }catch(_){
      return false;
    }
  }
  Future<void> connectToServer() async {
    if(await checkServerReachable()){
      final ip=controller.text.trim();
      final url="ws://localhost:1234";
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreenRooms(client: ChatClient(url)),
        ),
      );

    }else{
      status="failed connection";
      setState(() {

      });
    }

  }
}
