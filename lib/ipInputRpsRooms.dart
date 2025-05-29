import 'dart:io';

import 'package:flutter/material.dart';
import 'package:network_practice/rpsRooms.dart';

import 'classes/tcpSink.dart';

class Ipinputrpsrooms extends StatefulWidget {
  const Ipinputrpsrooms({super.key});

  @override
  State<Ipinputrpsrooms> createState() => _IpinputrpsroomsState();
}

class _IpinputrpsroomsState extends State<Ipinputrpsrooms> {
  String status= "status";
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("enter ip"),),

      body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Enter ip"),
            SizedBox(height: 16,),
            Text(status),
            SizedBox(height: 16,),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder()
              ),
            ),
            ElevatedButton(onPressed: connectToServer, child: Text("Connect"))
          ],
      ),
      ),
    );
  }
  Future<bool> checkServerReachable() async {
    try {
      final socket = await Socket.connect(
        controller.text.trim(),
        1235,
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

        final channel = await TCPChannel.connect(controller.text.trim(), 1235);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RpsRooms(channel: channel),
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


