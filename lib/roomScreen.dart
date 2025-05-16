import 'package:flutter/material.dart';

class RoomScreen extends StatefulWidget {
  final void Function(String roomName) onRoomJoined;

  const RoomScreen({required this.onRoomJoined, super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final TextEditingController _controller = TextEditingController();

  void _joinRoom() {
    final roomName = _controller.text.trim();
    if (roomName.isNotEmpty) {
      widget.onRoomJoined(roomName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Join or Create Room')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Room Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _joinRoom,
              child: Text('Enter Room'),
            ),
          ],
        ),
      ),
    );
  }
}
