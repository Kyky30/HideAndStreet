import 'package:flutter/material.dart';
import '../../WebSocketManager.dart';

import 'chat_model.dart';


class ChatController {
  final ChatModel _model = ChatModel();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void connect(String email) {
    WebSocketManager.connect(email);
  }

  void sendMessage(String email, String gameCode, String message, TextEditingController controller) {
    if (message.isNotEmpty) {
      WebSocketManager.sendData('"email": "$email", "gameCode" : "$gameCode", "cmd": "sendMessage", "message": "$message", "timestamp" : "${DateTime.now().millisecondsSinceEpoch}"');
      controller.clear();

      // Scroll to bottom
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }
}