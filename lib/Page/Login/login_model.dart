import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:hide_and_street/WebSocketManager.dart';

class LoginModel {
  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return false;
    }

    try {
      await WebSocketManager.connect(email);

      Completer<bool> completer = Completer<bool>();

      WebSocketManager.getStream().listen((event) async {
        event = event.replaceAll(RegExp("'"), '"');
        var responseData = json.decode(event);

        if (responseData["status"] == 'wrong_mail' || responseData["status"] == 'wrong_pass') {
          await WebSocketManager.closeConnection();
          completer.complete(false);
        }

        if (responseData["status"] == 'success') {
          await WebSocketManager.closeConnection();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('loggedin', true);
          prefs.setString('userId', responseData["userId"]);
          prefs.setString('username', responseData["username"]);
          prefs.setString('email', responseData["email"]);
          prefs.setString('DateCreation', responseData["DateCreation"]);
          completer.complete(true);
        } else {
          await WebSocketManager.closeConnection();
          completer.complete(false);
        }
      });

      await WebSocketManager.sendData("'cmd':'login','email':'$email','hash':'$password'");

      return completer.future;
    } catch (e) {
      print("Erreur lors de la connexion au WebSocket: " + e.toString());
      return false;
    }
  }
}
