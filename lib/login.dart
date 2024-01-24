import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hide_and_street/home.dart';
import 'package:hide_and_street/main.dart';
import 'package:hide_and_street/password_forgoten.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


import 'register.dart';

class WebSocketManager {
  static IOWebSocketChannel? _channel;

  static Future<void> connect(String email) async {
    _channel = IOWebSocketChannel.connect('wss://app.hideandstreet.furrball.fr/login$email');
  }

  static Future<void> closeConnection() async {
    _channel?.sink.close();
  }

  static Future<void> sendLoginData(String auth, String email, String password) async {
    if (_channel != null) {
      String loginData = "{'auth':'$auth','cmd':'login','email':'$email','hash':'$password'}";
      _channel!.sink.add(loginData);
    }
  }

  static Stream<dynamic> getStream() {
    return _channel?.stream ?? Stream.empty();
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key? key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Déclarez les variables email et password ici
  String email = '';

  String password = '';



  Future<void> login(BuildContext context) async {
    if (email.isEmpty || password.isEmpty) {
      print("❓ Champ vide");

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.titre_popup_champ_vide),
            content: Text(AppLocalizations.of(context)!.texte_popup_champ_vide),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    String auth = "chatappauthkey231r4";

    try {
      await WebSocketManager.connect(email);

      WebSocketManager.getStream().listen((event) async {
        event = event.replaceAll(RegExp("'"), '"');
        var responseData = json.decode(event);

        if (responseData["status"] == 'wrong_mail' || responseData["status"] == 'wrong_pass') {
          await WebSocketManager.closeConnection();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(AppLocalizations.of(context)!.popup_titre_email_mdp_incorrect),
                content: Text(AppLocalizations.of(context)!.popup_texte_email_mdp_incorrect),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );

          print("🚫 " + responseData["status"]);
          return;
        }

        if (responseData["status"] == 'success') {
          await WebSocketManager.closeConnection();
          print("✅ " + "connexion " + responseData["status"]);

          // Mettez à jour les SharedPreferences avec le statut de connexion
          SharedPreferences prefs = await SharedPreferences.getInstance();
          print(responseData["userId"]);
          prefs.setBool('loggedin', true);
          prefs.setString('userId', responseData["userId"]);
          prefs.setString('username', responseData["username"]);
          prefs.setString('email', responseData["email"]);
          prefs.setString('DateCreation', responseData["DateCreation"]);

          // Effectuer des actions après une connexion réussie
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MyHomePage(),
            ),
          );
        } else {
          await WebSocketManager.closeConnection();
          print("Erreur lors de la connexion");
        }
      });

      await WebSocketManager.sendLoginData(auth, email, password);
    } catch (e) {
      print("Erreur lors de la connexion au WebSocket: " + e.toString());
      // Gérer l'erreur de connexion, par exemple, afficher un message d'erreur à l'utilisateur
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(15, 75, 15, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/logo_connect.png',
                        width: MediaQuery.of(context).size.width - 150,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.mail,
                        style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Container(
                          height: 80,
                          width: MediaQuery.of(context).size.width - 30,
                          child: TextField(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[300],
                              hintText: AppLocalizations.of(context)!.mail,
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            onChanged: (e) => email = e,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.mdp,
                        style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Container(
                          height: 80,
                          width: MediaQuery.of(context).size.width - 30,
                          child: TextField(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[300],
                              hintText: AppLocalizations.of(context)!.mdp,
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            onChanged: (e) => password = e,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),


                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: ElevatedButton(
                          onPressed: () {
                            login(context);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 20,
                                cornerSmoothing: 1,
                              ),
                            ),
                            minimumSize: Size(MediaQuery.of(context).size.width - 30, 80),
                            backgroundColor: const Color(0xFF373967),
                            foregroundColor: const Color(0xFF212348),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.connexion,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.white),
                          ),
                        ),
                      ),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Ajoutez cette ligne
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RegisterPage(),
                                  ),
                                );
                              },
                              child: Text(
                                AppLocalizations.of(context)!.inscription,
                                style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins', backgroundColor: Colors.white),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ForgotenPassword(),
                                  ),
                                );
                              },
                              child: Text(
                                AppLocalizations.of(context)!.mdpoublie,
                                style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins', backgroundColor: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // TODO: supprimer ce bouton avant version finale
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyHomePage(),
                              ),
                            );
                          },
                          child: Text(
                            "Passer connexion -> dev",
                            style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins', backgroundColor: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
