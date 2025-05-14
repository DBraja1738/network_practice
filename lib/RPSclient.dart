import 'dart:io';

import 'package:web_socket_channel/web_socket_channel.dart';

class RPSclient {
  late final WebSocketChannel channel;

  RPSclient(String serverURL)
      : channel = WebSocketChannel.connect(Uri.parse(serverURL));

  void sendMove(String move){
    channel.sink.add(move);
  }

  Stream<String> get messages => channel.stream.map((data)=>data.toString());

  void dispose(){
    channel.sink.close(WebSocketStatus.normalClosure, "user left");
  }
}