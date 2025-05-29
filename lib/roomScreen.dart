import 'package:flutter/material.dart';
import 'dart:convert';
import 'classes/tcpSink.dart';

class RoomScreen extends StatefulWidget {
  final TCPChannel channel;

  const RoomScreen({super.key, required this.channel});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  List<dynamic> rooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    widget.channel.stream.listen((message) {
      final data = jsonDecode(message);

      if (data["type"] == "rooms_list") {
        setState(() {
          rooms = data["rooms"];
          isLoading = false;
        });
      } else if (data["type"] == "status") {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      } else if (data["type"] == "room_created") {

        fetchRooms();
      }
    });


    fetchRooms();
  }

  void fetchRooms() {
    widget.channel.sink.add(jsonEncode({
      "type": "fetch_rooms",
    }));
  }

  void joinRoom(String roomName) {
    widget.channel.sink.add(jsonEncode({
      "type": "join",
      "room": roomName,
    }));


    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          channel: widget.channel,
          roomName: roomName,
        ),
      ),
    ).then((_) {
      // Refresh
      fetchRooms();
    });
  }

  void createRoom() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text('Create New Room'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Room name'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  widget.channel.sink.add(jsonEncode({
                    "type": "create",
                    "name": controller.text.trim(),
                  }));
                  Navigator.pop(context);
                }
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Rooms'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: createRoom,
            tooltip: 'Create Room',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchRooms,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
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
          itemBuilder: (context, index) {
            final room = rooms[index];
            final isFull = room["occupancy"] >= room["capacity"];

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isFull ? Colors.red : Colors.green,
                  child: Icon(
                    isFull ? Icons.block : Icons.chat,
                    color: Colors.white,
                  ),
                ),
                title: Text(room["name"]),
                subtitle: Text("${room["occupancy"]}/${room["capacity"]} users"),
                trailing: isFull
                    ? Chip(
                  label: Text("FULL"),
                  backgroundColor: Colors.red.shade100,
                )
                    : ElevatedButton(
                  onPressed: () => joinRoom(room["name"]),
                  child: Text("Join"),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String roomName;
  final TCPChannel channel;

  const ChatScreen({
    required this.channel,
    required this.roomName,
    super.key,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatMessage> messages = [];
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();


    widget.channel.stream.listen((data) {
      final messageData = jsonDecode(data);

      if (messageData["type"] == "message") {
        setState(() {
          messages.add(ChatMessage(
            sender: messageData["from"] ?? "Unknown",
            text: messageData["text"] ?? "",
            isSystem: messageData["from"] == "System",
          ));
        });


        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  void sendMessage() {
    if (controller.text.isNotEmpty) {
      final text = controller.text.trim();

      widget.channel.sink.add(jsonEncode({
        "type": "message",
        "room": widget.roomName,
        "text": text,
      }));

      setState(() {
        messages.add(ChatMessage(
          sender: "Me",
          text: text,
          isSystem: false,
        ));
      });

      controller.clear();

      // Scroll to bottom after sending
      Future.delayed(Duration(milliseconds: 100), () {
        if (scrollController.hasClients) {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  @override
  void dispose() {

    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.roomName),
            Text(
              'TCP Chat Room',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No messages yet", style: TextStyle(color: Colors.grey)),
                  Text("Be the first to say hello!", style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
                : ListView.builder(
              controller: scrollController,
              padding: EdgeInsets.all(8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message.sender == "Me";

                if (message.isSystem) {
                  return Center(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(
                          color: Colors.grey.shade300,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey[700],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomLeft: isMe ? Radius.circular(12) : Radius.circular(2),
                        bottomRight: isMe ? Radius.circular(2) : Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isMe)
                          Text(
                            message.sender,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.blue.shade200,
                            ),
                          ),
                        if (!isMe) SizedBox(height: 4),
                        Text(
                          message.text,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, -2),
                  blurRadius: 4,
                  color: Colors.black12,
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade800,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => sendMessage(),
                    ),
                  ),
                  SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    radius: 24,
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String sender;
  final String text;
  final bool isSystem;

  ChatMessage({
    required this.sender,
    required this.text,
    this.isSystem = false,
  });
}