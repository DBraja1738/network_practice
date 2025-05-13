import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _channel = WebSocketChannel.connect(Uri.parse("ws://localhost:1234"));
  final _controller = TextEditingController();
  final List<String> _messsages = [];

  @override
  void initState(){
    super.initState();
    _channel.stream.listen(
            (message){
          setState(() {
            _messsages.add(message);
          });
        }
    );
  }

  void _sendMessage(){
    if(_controller.text.isNotEmpty){
      _channel.sink.add(_controller.text);
      setState(() {
        _messsages.add("me: ${_controller.text}");
        _controller.clear();
      });
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("my text app")),
      body: Column(
        children: [
          Expanded(child: ListView.builder(
            itemCount: _messsages.length,
            itemBuilder: (context,index) => ListTile(
              title: Text(_messsages[index]),
            ),
          ),

          ),

          Padding(padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(hintText: "enter msg"),
                )

                ),
                IconButton(onPressed: _sendMessage, icon: Icon(Icons.send))
              ],
            ),
          ),

        ],
      ),
    );
  }
}