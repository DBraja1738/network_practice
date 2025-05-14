import 'package:flutter/material.dart';
import 'package:network_practice/rockpaperscizors.dart';
import 'widgets/decorations.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:io';
class IPinput extends StatefulWidget {
  const IPinput({super.key});


  @override
  State<IPinput> createState() => _IPinputState();
}

class _IPinputState extends State<IPinput> {
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
      Navigator.push(context, MaterialPageRoute(builder: (context)=> RPSApp(serverURL: "ws://${controller.text}:1234")));
    }else{
      status="failed connection";
      setState(() {

      });
    }

  }
}
