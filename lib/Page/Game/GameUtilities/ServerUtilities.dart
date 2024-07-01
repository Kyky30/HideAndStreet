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

  ServerUtilities({required this.gameCode}) {
    _init();
  }

  Future<void> _init() async {
    await _getPrefs();
    await _connectWebSocket();
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
    String data = "'cmd':'getPositionForId','gameCode':'$gameCode','ids':$ids";
    await WebSocketManager.sendData(data);
    debugPrint("Sent data: $data");

    // Wait for the first response from the WebSocket
    var response = await WebSocketManager.getStream().first;
    debugPrint("Received response: $response");

    return response;
  }

  // Handle incoming data
  void _handleIncomingData(dynamic data) {
    debugPrint("Received data: $data");

    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    WebSocketManager.closeConnection();
    super.dispose();
  }
}
