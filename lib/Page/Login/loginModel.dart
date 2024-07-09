import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hide_and_street/WebSocketManager.dart';

class LoginModel {
  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return false;
    }

    Completer<bool> completer = Completer<bool>();

    try {
      await WebSocketManager.connect(email);

      StreamSubscription? subscription;
      subscription = WebSocketManager.getStream().listen((event) async {
        event = event.replaceAll(RegExp("'"), '"');
        var responseData = json.decode(event);

        if (!completer.isCompleted) {
          if (responseData["status"] == 'wrong_mail' || responseData["status"] == 'wrong_pass') {
            completer.complete(false);
          } else if (responseData["status"] == 'success') {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool('loggedin', true);
            await prefs.setString('userId', responseData["userId"]);
            await prefs.setString('username', responseData["username"]);
            await prefs.setString('email', responseData["email"]);
            await prefs.setString('DateCreation', responseData["DateCreation"]);
            await prefs.setString('nbGames', responseData["nbGames"]);
            await prefs.setString('nbWonGames', responseData["nbWonGames"]);
            completer.complete(true);
          } else {
            completer.complete(false);
          }

          await subscription?.cancel();
        }
      });

      await WebSocketManager.sendData("'cmd':'login','email':'$email','hash':'$password'");

      return completer.future;
    } catch (e) {
      print("Erreur lors de la connexion au WebSocket: " + e.toString());
      if (!completer.isCompleted) {
        completer.complete(false);
      }
      return completer.future;
    }
  }
}
