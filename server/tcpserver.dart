import 'dart:io';
import 'dart:convert';

class Room {
  final String name;
  final int capacity;
  final Set<Client> clients = {};
  final List<Map<String, dynamic>> messageHistory = [];

  Room(this.name, {this.capacity = 10});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'capacity': capacity,
      'occupancy': clients.length,
    };
  }
}

class Client {
  final Socket socket;
  final String id;
  String? currentRoom;
  StringBuffer buffer = StringBuffer();

  Client(this.socket, this.id);
}

class TCPServerForWidgets {
  ServerSocket? _server;
  final Map<String, Client> _clients = {};
  final Map<String, Room> _rooms = {};
  int _clientIdCounter = 0;

  TCPServerForWidgets() {
    // Create some default rooms
    _rooms['General'] = Room('General');
    _rooms['Gaming'] = Room('Gaming');
    _rooms['Tech Talk'] = Room('Tech Talk');
  }

  Future<void> start({String host = '0.0.0.0', int port = 1234}) async {
    _server = await ServerSocket.bind(host, port);
    print('TCP Server listening on $host:$port');
    print('Default rooms: ${_rooms.keys.join(', ')}');

    _server!.listen((Socket socket) {
      _handleNewClient(socket);
    });
  }

  void _handleNewClient(Socket socket) {
    final clientId = 'client_${++_clientIdCounter}';
    final client = Client(socket, clientId);
    _clients[clientId] = client;

    print('New client connected: $clientId from ${socket.remoteAddress.address}:${socket.remotePort}');

    // Send initial status
    _sendToClient(client, {
      'type': 'status',
      'message': 'Connected to server',
    });

    socket.listen(
          (data) {
        // Buffer incoming data to handle partial messages
        client.buffer.write(utf8.decode(data));

        // Process complete messages (delimited by newline)
        String bufferContent = client.buffer.toString();
        List<String> lines = bufferContent.split('\n');

        // Keep incomplete line in buffer
        client.buffer = StringBuffer(lines.removeLast());

        // Process complete lines
        for (String line in lines) {
          line = line.trim();
          if (line.isNotEmpty) {
            _handleClientMessage(client, line);
          }
        }
      },
      onError: (error) {
        print('Client $clientId error: $error');
        _removeClient(client);
      },
      onDone: () {
        print('Client $clientId disconnected');
        _removeClient(client);
      },
    );
  }

  void _handleClientMessage(Client client, String message) {
    try {
      Map<String, dynamic> data = jsonDecode(message);
      print('Received from ${client.id}: $data');

      switch (data['type']) {
        case 'fetch_rooms':
          _sendRoomsList(client);
          break;

        case 'create':
          _createRoom(client, data['name']);
          break;

        case 'join':
          _joinRoom(client, data['room']);
          break;

        case 'message':
          _broadcastToRoom(client, data['text']);
          break;

        default:
          _sendToClient(client, {
            'type': 'error',
            'message': 'Unknown message type: ${data['type']}',
          });
      }
    } catch (e) {
      print('Error parsing message from ${client.id}: $e');
      _sendToClient(client, {
        'type': 'error',
        'message': 'Invalid message format',
      });
    }
  }

  void _sendRoomsList(Client client) {
    List<Map<String, dynamic>> roomsList = [];
    _rooms.forEach((name, room) {
      roomsList.add(room.toJson());
    });

    _sendToClient(client, {
      'type': 'rooms_list',
      'rooms': roomsList,
    });
  }

  void _createRoom(Client client, String? roomName) {
    if (roomName == null || roomName.isEmpty) {
      _sendToClient(client, {
        'type': 'status',
        'message': 'Room name cannot be empty',
      });
      return;
    }

    if (_rooms.containsKey(roomName)) {
      _sendToClient(client, {
        'type': 'status',
        'message': 'Room "$roomName" already exists',
      });
      return;
    }

    _rooms[roomName] = Room(roomName);
    print('Room "$roomName" created by ${client.id}');

    _sendToClient(client, {
      'type': 'status',
      'message': 'Room "$roomName" created successfully',
    });

    // Notify all clients about the new room
    _notifyAllClients({
      'type': 'room_created',
      'room': roomName,
    });
  }

  void _joinRoom(Client client, String? roomName) {
    if (roomName == null || !_rooms.containsKey(roomName)) {
      _sendToClient(client, {
        'type': 'status',
        'message': 'Room not found',
      });
      return;
    }

    Room room = _rooms[roomName]!;

    // Check capacity
    if (room.clients.length >= room.capacity) {
      _sendToClient(client, {
        'type': 'status',
        'message': 'Room is full',
      });
      return;
    }

    // Leave current room if any
    if (client.currentRoom != null) {
      _leaveRoom(client);
    }

    // Join new room
    room.clients.add(client);
    client.currentRoom = roomName;

    print('${client.id} joined room "$roomName"');

    // Send success status
    _sendToClient(client, {
      'type': 'status',
      'message': 'Joined room "$roomName"',
    });

    // Send room history to new member
    for (var msg in room.messageHistory.take(20)) {
      _sendToClient(client, msg);
    }

    // Notify others in room
    _broadcastToRoomExcept(room, client, {
      'type': 'message',
      'from': 'System',
      'text': 'A user joined the room',
    });
  }

  void _leaveRoom(Client client) {
    if (client.currentRoom == null) return;

    Room? room = _rooms[client.currentRoom];
    if (room != null) {
      room.clients.remove(client);

      // Notify others
      _broadcastToRoomExcept(room, client, {
        'type': 'message',
        'from': 'System',
        'text': 'A user left the room',
      });
    }

    client.currentRoom = null;
  }

  void _broadcastToRoom(Client sender, String? text) {
    if (text == null || text.isEmpty) return;

    if (sender.currentRoom == null) {
      _sendToClient(sender, {
        'type': 'status',
        'message': 'You are not in any room',
      });
      return;
    }

    Room? room = _rooms[sender.currentRoom];
    if (room == null) return;

    Map<String, dynamic> messageData = {
      'type': 'message',
      'from': 'User${sender.id.split('_').last}',
      'text': text,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Add to history
    room.messageHistory.add(messageData);
    if (room.messageHistory.length > 100) {
      room.messageHistory.removeAt(0);
    }

    // Broadcast to all in room except sender
    for (Client client in room.clients) {
      if (client != sender) {
        _sendToClient(client, messageData);
      }
    }
  }

  void _broadcastToRoomExcept(Room room, Client except, Map<String, dynamic> data) {
    for (Client client in room.clients) {
      if (client != except) {
        _sendToClient(client, data);
      }
    }
  }

  void _notifyAllClients(Map<String, dynamic> data) {
    for (Client client in _clients.values) {
      _sendToClient(client, data);
    }
  }

  void _sendToClient(Client client, Map<String, dynamic> data) {
    try {
      String json = jsonEncode(data);
      client.socket.write('$json\n');
    } catch (e) {
      print('Error sending to client ${client.id}: $e');
    }
  }

  void _removeClient(Client client) {
    _leaveRoom(client);
    _clients.remove(client.id);
    try {
      client.socket.close();
    } catch (e) {
      // Socket might already be closed
    }
  }

  void stop() {
    for (Client client in _clients.values) {
      client.socket.close();
    }
    _clients.clear();
    _rooms.clear();
    _server?.close();
  }
}

void main() async {
  final server = TCPServerForWidgets();
  await server.start(host: '0.0.0.0', port: 1234);

  print('TCP Server is running on port 1234');
  print('Press Ctrl+C to stop.');

  // Keep server running
  await ProcessSignal.sigint.watch().first;

  print('\nShutting down server...');
  server.stop();
}