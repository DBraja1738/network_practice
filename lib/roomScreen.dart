import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:network_practice/chatScreen.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RoomScreen extends StatefulWidget {
  final WebSocketChannel channel;

  const RoomScreen({super.key, required this.channel});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  List<dynamic> rooms = [];
  bool isLoading = true;
  final TextEditingController _controller = TextEditingController();
  StreamSubscription? subscription;


  @override
  void initState(){
    super.initState();

    setupListener();

    Future.delayed(Duration(milliseconds: 700),(){
      fetchRooms();
    });

  }

  void setupListener(){

    if(subscription != null) return;

    subscription = widget.channel.stream.listen((message){
      final data = jsonDecode(message);

      if(data["type"] == "rooms_list"){
        setState(() {
          rooms = data["rooms"];
          isLoading = false;
        });
      }else if(data["type"] == "status"){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message']))
        );
      }
    },
    onError: (error){
      print("error: $error");

      setState(() {
        isLoading = false;
      });
    },
    onDone: (){
      print("Websocket closed");

      if(mounted){
        Navigator.of(context).pop();
      }
    }

    );
  }


  void joinRoom(String roomName){
    widget.channel.sink.add(jsonEncode({
      "type" : "join",
      "room" : roomName,
    }));

    subscription?.cancel();
    subscription = null;

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context)=> ChatScreenNew(
                channel: widget.channel,
                roomName: roomName
            )
        )
    ).then((_){

      setupListener();
      fetchRooms();
    });
  }

  void fetchRooms(){
    widget.channel.sink.add(jsonEncode({
      "type": "fetch_rooms",
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hello rooms')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : rooms.isEmpty ? const Center(child: Text("No rooms"),)
                    : ListView.builder(
                        itemCount: rooms.length,
                        itemBuilder: (context, index){
                          final room= rooms[index];
                          return ListTile(
                            title: Text(room["name"]),
                            subtitle: Text("${room["occupancy"] / room["capacity"]} participants"),
                            trailing: room["occupancy"] < room["capacity"]
                                      ? ElevatedButton(onPressed: ()=> joinRoom(room["name"]), child: const Text("Join"))
                                      : const Text("FULL", style: TextStyle(color: Colors.red),)
                          );
                        }
                      )
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  @override
  void dispose(){
    _controller.dispose();
    subscription?.cancel();
    super.dispose();

  }
}
