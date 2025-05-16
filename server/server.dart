import 'dart:io';
import 'dart:convert';

void main() async {
  final server = await HttpServer.bind("0.0.0.0", 1234);
  print("Server is running");

  final Map<String, Set<WebSocket>> rooms = {};
  final Map<WebSocket, String> clientRooms = {};

  await for (HttpRequest request in server){
    if(WebSocketTransformer.isUpgradeRequest(request)){
      final socket = await WebSocketTransformer.upgrade(request);
      print("Client connected");

      socket.listen((data){
        try{
          final message= jsonDecode(data);
          final type= message["type"];

          if(type=="join"){
            final room = message["room"];
            rooms.putIfAbsent(room, ()=><WebSocket>{});

            if(rooms[room]!.length >= 2){
              socket.add(jsonEncode({'type': 'status','message' : 'Room full'}));
              return;
            }

            rooms[room]!.add(socket);
            clientRooms[socket] = room;

            print("client entered room $room");

          }else if(type=="message"){
            final room = clientRooms[socket];
            final text = message["text"];

            if(room!=null && rooms.containsKey(room)){
              for(var client in rooms[room]!){
                if(client!=socket){
                  client.add(jsonEncode({
                    "type" : "message",
                    "from" : "user",
                    "text" : "text",
                  }));
                }
              }
            }
          }


        }catch(e){
          print("Invalid format");
        }


      }, onDone: (){
        final room = clientRooms[socket];
        if(room!=null){
          rooms[room]?.remove(socket);
          if(rooms[room]!.isEmpty){
            rooms.remove(room);
          }
          clientRooms.remove(socket);
        }
        print("client disconnected");
      }
      );

    }else{
      request.response..statusCode = HttpStatus.forbidden..close();
    }
  }
}
