// WebSocket Singleton
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();
  late WebSocketChannel _channel;

  factory WebSocketManager() {
    return _instance;
  }

  WebSocketManager._internal() {
    // Initialiser votre connexion WebSocket ici
    _channel = IOWebSocketChannel.connect('wss://app.hideandstreet.furrball.fr/getPlayerlist');
  }

  WebSocketChannel get channel => _channel;
}
