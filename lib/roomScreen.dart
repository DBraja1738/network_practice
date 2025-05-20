import 'dart:convert';

import 'package:flutter/material.dart';
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

  @override
  void initState(){
    super.initState();

    widget.channel.stream.listen((message){
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
    });
    Future.delayed(Duration(milliseconds: 700),(){
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
    widget.channel.sink.close();
    super.dispose();

  }
}
