import 'dart:io';

import 'package:flutter/material.dart';
import 'package:network_practice/roomScreen.dart';
import 'classes/tcpSing.dart';
class EnterIpRooms extends StatefulWidget {
  const EnterIpRooms({super.key});

  @override
  State<EnterIpRooms> createState() => _EnterIpRoomsState();
}

class _EnterIpRoomsState extends State<EnterIpRooms> {
  final TextEditingController controller = TextEditingController();
  String status = "Enter server IP";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("TCP Chat - Enter IP")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Enter Server IP", style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text(status, style: TextStyle(color: Colors.grey)),
            SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "e.g., 192.168.1.100",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: connectToServer,
              child: Text("Connect"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> checkServerReachable() async {
    try {
      final socket = await Socket.connect(
        controller.text.trim(),
        1234,
        timeout: Duration(seconds: 2),
      );
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> connectToServer() async {
    setState(() {
      status = "Checking server...";
    });

    if (await checkServerReachable()) {
      try {
        setState(() {
          status = "Connecting to server...";
        });

        final channel = await TCPChannel.connect(controller.text.trim(), 1234);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RoomScreen(channel: channel),
          ),
        );
      } catch (e) {
        setState(() {
          status = "Connection error: $e";
        });
      }
    } else {
      setState(() {
        status = "Server unreachable";
      });
    }
  }
}
