import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketManager {
  static String auth = "{'auth':'chatappauthkey231r4',";
  static IOWebSocketChannel? _channel;
  static final StreamController<dynamic> _streamController = StreamController.broadcast();

  static Future<IOWebSocketChannel> connect(String email) async {
    _channel = IOWebSocketChannel.connect('wss://app.hideandstreet.furrball.fr/');
    _channel!.stream.listen((data) {
      _streamController.add(data);
    });
    return _channel!;
  }

  static Future<void> closeConnection() async {
    await _channel?.sink.close();
    await _streamController.close();
    debugPrint("fermeture de la connexion");
  }

  static Future<void> sendData(String data) async {
    if (_channel != null) {
      _channel!.sink.add("$auth$data}"); // Add the auth key to the data
    } else {
      debugPrint("Error: WebSocket connection is not established");
    }
  }

  static Stream<dynamic> getStream() {
    return _streamController.stream;
  }
}
