import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hide_and_street/main.dart';
import 'package:hide_and_street/password_forgoten.dart';
import 'package:web_socket_channel/io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:hide_and_street/components/buttons.dart';
import 'package:hide_and_street/components/input.dart';
import 'package:hide_and_street/components/alertbox.dart';


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
    return _channel?.stream ?? const Stream.empty();
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Déclarez les variables email et password ici
  String email = '';
  String password = '';

  // Declare the controllers for the email and password fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Listen for changes in the text fields
    emailController.addListener(() {
      email = emailController.text;
    });

    passwordController.addListener(() {
      password = passwordController.text;
    });
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }


  Future<void> login(BuildContext context) async {
    if (email.isEmpty || password.isEmpty) {
      print("❓ Champ vide");

      showDialog(
        context: context,
        builder: (BuildContext context) {

            return CustomAlertDialog1
            (
              title: AppLocalizations.of(context)!.titre_popup_champ_vide,
              content: AppLocalizations.of(context)!.texte_popup_champ_vide,
              buttonText: "OK",
              onPressed: () {
                Navigator.of(context).pop();
              },
              scaleFactor: MediaQuery.of(context).textScaleFactor,
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

              return CustomAlertDialog1
                (
                  title: AppLocalizations.of(context)!.popup_titre_email_mdp_incorrect,
                  content: AppLocalizations.of(context)!.popup_texte_email_mdp_incorrect,
                  buttonText: "OK",
                  onPressed: () {
                      Navigator.of(context).pop();
                    },
                  scaleFactor: MediaQuery.of(context).textScaleFactor,
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
              builder: (context) => const MyHomePage(),
            ),
          );
        } else {
          await WebSocketManager.closeConnection();
          print("🚫 " + "connexion " + responseData["status"]);
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
                  margin: EdgeInsets.fromLTRB(15, 0.1 * MediaQuery.of(context).size.height, 15, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/logo_connect.png',
                        width: 0.8 * MediaQuery.of(context).size.width,
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
                        style: TextStyle(fontSize: 0.05 * MediaQuery.of(context).size.width, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Container(
                          height: 0.08 * MediaQuery.of(context).size.height,
                          width: 0.9 * MediaQuery.of(context).size.width,
                          child:
                            CustomTextField(
                              hintText: AppLocalizations.of(context)!.mail,
                              controller: emailController,
                              scaleFactor: MediaQuery.of(context).textScaleFactor,
                              onChanged: (e) => email = e,
                            ),
                        ),
                      ),
                      SizedBox(height: 0.02 * MediaQuery.of(context).size.height),
                      Text(
                        AppLocalizations.of(context)!.mdp,
                        style: TextStyle(fontSize: 0.05 * MediaQuery.of(context).size.width, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Container(
                          height: 0.08 * MediaQuery.of(context).size.height,
                          width: 0.9 * MediaQuery.of(context).size.width,
                          child:
                          CustomTextField(
                            hintText: AppLocalizations.of(context)!.mdp,
                            controller: passwordController,
                            obscureText: true,
                            scaleFactor: MediaQuery.of(context).textScaleFactor,
                            onChanged: (e) => password = e,
                          ),
                        ),
                      ),
                      SizedBox(height: 0.02 * MediaQuery.of(context).size.height),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Positioned(
                bottom: 0.04 * MediaQuery.of(context).size.height,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child:
                        CustomButton(
                          text: AppLocalizations.of(context)!.connexion,
                          onPressed: () {
                            login(context);
                          },
                          scaleFactor: MediaQuery.of(context).textScaleFactor,
                        ),
                      ),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                                style: TextStyle(color: Colors.black, fontSize: 0.04 * MediaQuery.of(context).size.width, fontWeight: FontWeight.w600, fontFamily: 'Poppins', backgroundColor: Colors.white),
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
                                style: TextStyle(color: Colors.black, fontSize: 0.04 * MediaQuery.of(context).size.width, fontWeight: FontWeight.w600, fontFamily: 'Poppins', backgroundColor: Colors.white),
                              ),
                            ),
                          ],
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