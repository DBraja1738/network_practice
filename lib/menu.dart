import 'package:flutter/material.dart';
import 'package:network_practice/animations.dart';
import 'package:network_practice/chat.dart';
import 'package:network_practice/enterIPchat.dart';
import 'package:network_practice/enterip.dart';
import 'package:network_practice/ipInputRpsRooms.dart';
import 'IPinputRooms.dart';
import 'widgets/decorations.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainMenu(),
    );
  }
}

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("hello menu"),
      ),
      body: Column(

        children: <Widget>[
          Padding(padding: EdgeInsets.only(top: 50.0)),
          Row(
            children: <Widget>[
              Expanded(child: Container(color: Colors.green,), flex: 2,),
              Expanded(
                flex: 6,
                child: Column(
                children: [
                  TextButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> EnterIpChat()));
                  }, style: AppDecorations.buttonStyle,
                    child: const Text("hello chat"),),

                  const SizedBox(height: 50.0,),
                  TextButton(
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> EnterIpRooms()));
                      },style: AppDecorations.buttonStyle,
                      child: const Text("hello all rooms")),

                  const SizedBox(height: 50.0,),

                  TextButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> IPinput()));
                  },style: AppDecorations.buttonStyle,
                  child: const Text("hello rps")),

                  const SizedBox(height: 50.0,),

                  TextButton(
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> AnimationPractice()));
                      },style: AppDecorations.buttonStyle,
                      child: const Text("hello animations")),

                  const SizedBox(height: 50.0,),

                  TextButton(
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> Ipinputrpsrooms()));
                      },style: AppDecorations.buttonStyle,
                      child: const Text("hello tcp rps")),


                ],
              ),
              ),
              Expanded(child: Container(color: Colors.green,), flex: 2,),
            ],
          )
        ],
      ),
    );
  }
}
