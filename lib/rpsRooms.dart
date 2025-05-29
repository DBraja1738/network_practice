import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:network_practice/classes/tcpSink.dart';
import 'package:network_practice/widgets/decorations.dart';

class RpsRooms extends StatefulWidget {
  final TCPChannel channel;
  const RpsRooms({super.key, required this.channel});

  @override
  State<RpsRooms> createState() => _RpsRoomsState();
}

class _RpsRoomsState extends State<RpsRooms> {
  List<dynamic> rooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    widget.channel.stream.listen((message){
      final data = jsonDecode(message);

      if(data["type"]=="rooms_list"){
        setState(() {
          rooms = data["rooms"];
          isLoading = false;
        });
      }else if(data["type"] == "status"){
        if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["message"]))
          );
        }
      }else if(data["type"] == "room_created"){
        fetchRooms();
      }
    },
    onDone: (){
      print("client disconnected");
    },
    onError: (e){
      print("error $e");
    }
    );

    fetchRooms();
  }

  void fetchRooms(){
    widget.channel.sink.add(jsonEncode({
      "type": "fetch_rooms",
    }));
  }
  void joinRoom(String roomName){
    widget.channel.sink.add(jsonEncode({
      "type": "join",
      "room": roomName,
    }));

    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RpsGame(channel: widget.channel, roomName: roomName)))
        .then((_){
          fetchRooms();
        });
  }

  void createRoom(){
    showDialog(context: context, builder: (context){
      final controller = TextEditingController();
      return AlertDialog(
        title: Text("create new room"),
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: ()=> Navigator.pop(context), child: Text("cancel")),
          TextButton(onPressed: (){
           if(controller.text.isNotEmpty){
             widget.channel.sink.add(jsonEncode({
               "type": "create",
               "name": controller.text.trim()
             }));
             Navigator.pop(context);
           }
          },
           child: Text("create")),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("hello rooms"),
        actions: [
          IconButton(onPressed: createRoom, icon: Icon(Icons.add), tooltip: "Create room", ),
          IconButton(onPressed: fetchRooms, icon: Icon(Icons.refresh), tooltip: "Refresh",),
        ],
      ),
      body: isLoading
      ? Center(child: CircularProgressIndicator(),)
      : rooms.isEmpty
      ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("No rooms available", style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: createRoom,
              icon: Icon(Icons.add),
              label: Text('Create First Room'),
            ),
          ],
        ),
      )
      : RefreshIndicator(
        onRefresh: () async => fetchRooms(),
        child: ListView.builder(
          itemCount: rooms.length,
          itemBuilder: (context,index){
            final room=rooms[index];
            final isFull = room["occupancy"] >= room["capacity"];

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isFull ? Colors.red : Colors.green,
                  child: Icon(
                    isFull ? Icons.block : Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),

                title: Text(room["name"]),
                subtitle: Text("${room["occupancy"]}/${room["capacity"]}"),
                trailing: isFull ? Chip(label: Text("full")) : ElevatedButton(onPressed: ()=>joinRoom(room["name"]), child: Text("join")),
              ),
            );

          },
        ),

      )


    );
  }
}

class RpsGame extends StatefulWidget {

  final String roomName;
  final TCPChannel channel;

  const RpsGame({
    required this.channel,
    required this.roomName,
    super.key,
  });

  @override
  State<RpsGame> createState() => _RpsGameState();
}

class _RpsGameState extends State<RpsGame> {
  String status = "status";

  @override
  void initState() {
    super.initState();

    widget.channel.stream.listen((message){
      final data = jsonDecode(message);

      switch(data["type"]){
        case "result":
          status = data["result"];
          setState(() {

          });
          break;
        case "status":
          status=data["message"] ?? "status";
          break;
        default:
          status = "unknown datatype";
          setState(() {

          });
          break;
      }
    });
  }


  void sendMove(String move){
    widget.channel.sink.add(jsonEncode({
      "type": "move",
      "move": move,
    }));

    setState(() {
      status = "move is chosen, waiting for opp....";
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
        title: Text("Hello ${widget.roomName}"),
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

