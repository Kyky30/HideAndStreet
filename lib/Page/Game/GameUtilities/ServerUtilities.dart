import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../WebSocketManager.dart';

class ServerUtilities with ChangeNotifier {
  StreamSubscription<dynamic>? _subscription;
  late String email;
  late String userId;
  final String gameCode;

  // StreamController for WebSocket data
  final _webSocketController = StreamController<dynamic>.broadcast();
  final _outOfZoneController = StreamController<Map<String, dynamic>>.broadcast();
  final _chatController = StreamController<Map<String, dynamic>>.broadcast();
  final _seekerWinController = StreamController<Map<String, dynamic>>.broadcast();

  ServerUtilities({required this.gameCode}) {
    _init();
  }

  Stream<Map<String, dynamic>> get outOfZoneStream => _outOfZoneController.stream;
  Stream<Map<String, dynamic>> get chatStream => _chatController.stream;
  Stream<Map<String, dynamic>> get seekerWinStream => _seekerWinController.stream;

  Future<void> _init() async {
    await _getPrefs();
    await _connectWebSocket();
  }

  Future<void> _getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email') ?? '';
    userId = prefs.getString('userId') ?? '';
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

  Future<void> setPosition(Position newPosition) async {
    String data = "'cmd':'setPositionPlayer','gameCode':'$gameCode','playerId':'$userId', 'position':'$newPosition'";
    await WebSocketManager.sendData(data);
    debugPrint("🛫 Sent data: $data");
  }

  Future<void> setPlayerOutOfZone(Position currentPosition) async {
    String data = "'cmd':'setOutOfZone','gameCode':'$gameCode','playerId':'$userId', 'position':'$currentPosition'";
    await WebSocketManager.sendData(data);
    debugPrint("🛫 Sent data: $data");
  }

  Future<void> setPlayerFound() async {
    String data = "'cmd':'setFoundStatus','gameCode':'$gameCode','playerId':'$userId'";
    await WebSocketManager.sendData(data);
    debugPrint("🛫 Sent data: $data");
  }

  // Handle incoming data
  void _handleIncomingData(dynamic data) {
    debugPrint("🛬 Received data: $data");

    // Parse data to check for 'setOutOfZone' command
    var parsedData = jsonDecode(data);
    if (parsedData['cmd'] == 'playerOutOfZone') {
      _outOfZoneController.add(parsedData);
    }
    if (parsedData['cmd'] == 'ReceiveMessage') {
      _chatController.add(parsedData);
    }
    if(parsedData['cmd'] == 'seekerWin') {
      _seekerWinController.add(parsedData);
    }

    _webSocketController.add(data); // Add data to the StreamController
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _webSocketController.close();
    _outOfZoneController.close();
    _chatController.close();
    _seekerWinController.close();
    WebSocketManager.closeConnection();
    super.dispose();
  }
}
