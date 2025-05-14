import 'dart:io';

class Player{
  WebSocket socket;
  String? move;

  Player(this.socket);
}

void main() async{
  final players = <Player>[];

  final server = await HttpServer.bind(InternetAddress.anyIPv4, 1234);
  print("server running on ws://${server.address.address}:1234");

  await for(HttpRequest request in server){
    if(WebSocketTransformer.isUpgradeRequest(request)){
      final socket = await WebSocketTransformer.upgrade(request);
      print("Client connected");
      final player = Player(socket);
      players.add(player);

      socket.listen((data){
        player.move=data;
        _tryResolveGame(players);
      },
      onDone: (){
        players.remove(player);
        print("client disconnected");
      }

      );
    }else{
      request.response..statusCode=HttpStatus.forbidden..write("Websocket only")..close();
    }
  }
}


void _tryResolveGame(List<Player> players){

  if(players.length >= 2 && players[0].move != null && players[1].move != null){
    final p1 = players[0];
    final p2 = players[1];
    final result = _determineWinner(p1.move,p2.move);

    p1.socket.add(result);
    p2.socket.add(_reverseResult(result));

    p1.move=null;
    p2.move=null;
  }

}

String _determineWinner(String? m1, String? m2){
  if(m1==m2) return "Draw";

  if((m1 == 'rock') && (m2=='scissors') || (m1=='scissors' && m2=='paper') || (m1=='paper' && m2=="rock") ){
    return "You win";
  }
  return "You lose";

}

String _reverseResult(String result){
  if(result=="Draw") return "Draw";
  return result == "You win" ? "You lose" : "You win";
}