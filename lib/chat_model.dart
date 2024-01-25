import 'package:flutter/material.dart';

class ChatModel extends ChangeNotifier {
  final List<String> _messages = [];
  final List<String> _emails = [];
  final List<String> _usernames = [];

  List<String> get messages => _messages;
  List<String> get emails => _emails;
  List<String> get usernames => _usernames;

  void addMessage(String message, String email, String username) {
    _messages.add(message);
    _emails.add(email);
    _usernames.add(username);
    notifyListeners();
  }
}