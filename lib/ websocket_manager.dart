// websocket_manager.dart
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketManager {
  // Singleton instance
  static final WebSocketManager _singleton = WebSocketManager._internal();

  // WebSocket channel
  late WebSocketChannel _channel;

  // Factory method to return the same instance
  factory WebSocketManager() {
    return _singleton;
  }

  // Internal constructor
  WebSocketManager._internal() {
    _channel = IOWebSocketChannel.connect('wss://app.hideandstreet.furrball.fr/getPlayerlist');
  }

  // Getter for the WebSocket channel
  WebSocketChannel get channel => _channel;
}