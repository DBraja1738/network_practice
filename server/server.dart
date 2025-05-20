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
      print(rooms);

      socket.listen((data){
        try{
          final message= jsonDecode(data);
          final type= message["type"];
          switch(type){
            case "join":{
              final room = message["room"];
              rooms.putIfAbsent(room, ()=><WebSocket>{});

              if(rooms[room]!.length >= 2){
                socket.add(jsonEncode({'type': 'status','message' : 'Room full'}));
                return;
              }

              rooms[room]!.add(socket);
              clientRooms[socket] = room;

              print("client entered room $room");
            }
            case "message":{
              final room = clientRooms[socket];
              final text = message["text"];

              if(room!=null && rooms.containsKey(room)){
                for(var client in rooms[room]!){
                  if(client!=socket){
                    client.add(jsonEncode({
                      "type" : "message",
                      "from" : "user",
                      "text" : text,
                    }));
                  }
                }
              }
            }
            case "create":{
              String name = message["name"];
              rooms.putIfAbsent(name, () => <WebSocket>{});
              print("Room '$name' created");
              socket.add(jsonEncode({'type': 'status', 'message': 'Room created successfully'}));

              print(rooms);
            }
            case "fetch_rooms":{
              final roomsList = rooms.entries.map((entry){
                return{
                  "name" : entry.key,
                  "occupancy" : entry.value.length,
                  "capacity" : 2
                };
              }).toList();

              socket.add(jsonEncode({
                "type" : "rooms_list",
                "rooms": roomsList,
              }));
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
        print(rooms);
      }
      );

    }else{
      request.response..statusCode = HttpStatus.forbidden..close();
    }
  }
}
