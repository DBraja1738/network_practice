import 'dart:io';

void main() async {
  final server = await HttpServer.bind("0.0.0.0", 1234);
  print("Server is running");

  final clients = <WebSocket>{};

  await for (HttpRequest request in server){
    if(WebSocketTransformer.isUpgradeRequest(request)){
      final websocket = await WebSocketTransformer.upgrade(request);
      clients.add(websocket);

      print("Client connected, total clients: ${clients.length}");

      websocket.listen(
          (message){
            for (final client in clients){
              if(client != websocket) {
                client.add(message);
              }
            }
          },
          onDone: (){
            clients.remove(websocket);
            print("Client disconnected");
          }
      );
    } else
    {
      request.response..statusCode = HttpStatus.forbidden..write("websocket connections only")..close();
    }
  }
}