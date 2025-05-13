import 'package:flutter/material.dart';
import 'package:network_practice/chat.dart';
import 'widgets/decorations.dart';
import 'rockpaperscizors.dart';
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
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatApp()));
                  }, style: AppDecorations.buttonStyle,
                    child: const Text("hello chat"),),

                  const SizedBox(height: 50.0,),

                  TextButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> RPSApp(serverURL: 'ws://localhost:1234',)));
                  },style: AppDecorations.buttonStyle,
                  child: const Text("hello rps")),
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
