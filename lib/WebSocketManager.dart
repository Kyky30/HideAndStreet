import 'package:web_socket_channel/io.dart';

class WebSocketManager {
  static String auth = "{'auth':'chatappauthkey231r4',";
  static IOWebSocketChannel? _channel;

  static Future<void> connect(String email) async {
    _channel = IOWebSocketChannel.connect('wss://app.hideandstreet.furrball.fr/');
  }

  static Future<void> closeConnection() async {
    _channel?.sink.close();
  }

  static Future<void> sendData(String data) async {
    if (_channel != null) {
      _channel!.sink.add( "$auth$data}"); // Add the auth key to the data
    }
  }

  static Stream<dynamic> getStream() {
    return _channel?.stream ?? const Stream.empty();
  }
}