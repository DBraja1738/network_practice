import 'dart:io';

import 'package:flutter/material.dart';
import 'package:network_practice/chatAndRooms.dart';
import 'package:network_practice/roomScreen.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'widgets/decorations.dart';
class EnterIpRooms extends StatefulWidget {
  const EnterIpRooms({super.key});

  @override
  State<EnterIpRooms> createState() => _EnterIpRoomsState();
}

class _EnterIpRoomsState extends State<EnterIpRooms> {
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
      final channel = WebSocketChannel.connect(Uri.parse("ws://${controller.text.trim()}:1234"));
      Navigator.push(context, MaterialPageRoute(builder: (context)=> RoomScreen(channel: channel)));
    }else{
      status="failed connection";
      setState(() {

      });
    }

  }
}
