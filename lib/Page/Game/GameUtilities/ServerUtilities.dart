import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../WebSocketManager.dart';

class ServerUtilities with ChangeNotifier {
  StreamSubscription<dynamic>? _subscription;
  late String email;
  final String gameCode;

  // Position variables
  late Position latestPositionSentToServer;
  late Position currentPosition;

  // StreamController for WebSocket data
  final _webSocketController = StreamController<dynamic>.broadcast();

  ServerUtilities({required this.gameCode}) {
    _init();
  }

  Future<void> _init() async {
    await _getPrefs();
    await _connectWebSocket();
    debugPrint('websocket connected');
  }

  Future<void> _getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email') ?? '';
  }

  Future<void> _connectWebSocket() async {
    await WebSocketManager.connect(email);
    _subscription = WebSocketManager.getStream().listen((data) {
      _handleIncomingData(data);
    });
  }

  // Get game data
  Future<dynamic> getPositionForId(List<String> ids) async {
    final Completer<dynamic> completer = Completer<dynamic>();

    // Declare the subscription variable before using it
    late StreamSubscription subscription;

    // Add a listener to the StreamController for the first response
    subscription = _webSocketController.stream.listen((data) {
      debugPrint("🛬 Received response: $data");
      completer.complete(data); // Complete the future with the received data
      subscription.cancel(); // Cancel the subscription after receiving the first response
    });

    String data = "'cmd':'getPositionForId','gameCode':'$gameCode','ids':$ids";
    await WebSocketManager.sendData(data);
    debugPrint("🛫 Sent data: $data");

    return completer.future; // Return the future that completes with the response data
  }

  // Handle incoming data
  void _handleIncomingData(dynamic data) {
    debugPrint("🛬 Received data: $data");
    _webSocketController.add(data); // Add data to the StreamController
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _webSocketController.close();
    WebSocketManager.closeConnection();
    super.dispose();
  }
}
