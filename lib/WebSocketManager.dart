import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:async';

class WebSocketManager {
  static const String _authKey = "{'auth':'chatappauthkey231r4',";
  static IOWebSocketChannel? _channel;
  static final StreamController<dynamic> _streamController = StreamController<dynamic>.broadcast();

  // Méthode pour établir la connexion WebSocket
  static Future<void> connect(String email) async {
    if (_channel != null) {
      debugPrint("WebSocket is already connected.");
      return;
    }

    try {
      _channel = IOWebSocketChannel.connect('wss://app.hideandstreet.furrball.fr/');
      _channel!.stream.listen((data) {
        _streamController.add(data);
      });
      debugPrint("Connected to WebSocket.");
    } catch (e) {
      debugPrint("Error connecting to WebSocket: $e");
    }
  }

  // Méthode pour fermer la connexion WebSocket
  static Future<void> closeConnection() async {
    try {
      await _channel?.sink.close();
      _channel = null;
      _streamController.close();
      debugPrint("WebSocket connection closed.");
    } catch (e) {
      debugPrint("Error closing WebSocket connection: $e");
    }
  }

  // Méthode pour envoyer des données via WebSocket
  static Future<void> sendData(String data) async {
    if (_channel != null) {
      try {
        _channel!.sink.add("$_authKey$data}");
        debugPrint("Data sent: $_authKey$data}");
      } catch (e) {
        debugPrint("Error sending data: $e");
      }
    } else {
      debugPrint("Error: WebSocket connection is not established");
    }
  }

  // Méthode pour obtenir le flux de données de WebSocket
  static Stream<dynamic> getStream() {
    return _streamController.stream;
  }
}
