import 'package:flutter/material.dart';
import 'RPSclient.dart';
import 'widgets/decorations.dart';


class RPSApp extends StatefulWidget {

  final String serverURL;
  const RPSApp({required this.serverURL, super.key});



  @override
  State<RPSApp> createState() => _RPSAppState();
}



class _RPSAppState extends State<RPSApp> {
  late RPSclient client;
  String status= "Choose move";



  @override
  void initState(){
    super.initState();
    client = RPSclient(widget.serverURL);
    client.messages.listen((message){
      setState(() {
        status = message;
      });
    });


    @override
    void dispose() {
      
      client.dispose();
      super.dispose();
    }
  }
  void sendMove(String move){
    client.sendMove(move);

    setState(() {
      status = "move is chosen, waiting for opp...";
    });
  }

  Widget moveButton(String move) {
    return ElevatedButton(
      onPressed: () => sendMove(move),
      child: Text(move.toUpperCase()),
      style: AppDecorations.buttonStyle,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hello RPS"),
      ),

      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(status),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              moveButton("rock"),
              moveButton("paper"),
              moveButton("scissors")
            ],
          ),
        ],
      ),
    );
  }


}
