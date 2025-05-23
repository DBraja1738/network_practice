import 'dart:io';

import 'package:flutter/material.dart';
import 'package:network_practice/chatAndRooms.dart';
import 'widgets/decorations.dart';
class EnterIpChat extends StatefulWidget {
  const EnterIpChat({super.key});

  @override
  State<EnterIpChat> createState() => _EnterIpChatState();
}

class _EnterIpChatState extends State<EnterIpChat> {
  final TextEditingController controller = TextEditingController();
  String status = "status";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("hello enter ip"),),
      body: Column(
        children: [
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
      final socket= await Socket.connect(controller.text, 1234, timeout: Duration(seconds: 2));
      socket.destroy();
      return true;
    }catch(_){
      return false;
    }
  }
  Future<void> connectToServer() async {
    if(await checkServerReachable()){
      Navigator.push(context, MaterialPageRoute(builder: (context)=> Chatandrooms(ip: "ws://${controller.text}:1234")));
    }else{
      status="failed connection";
      setState(() {

      });
    }

  }
}
