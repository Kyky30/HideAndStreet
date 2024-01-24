import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hide_and_street/waitingScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

import 'package:figma_squircle/figma_squircle.dart';

class RoomJoiningPage extends StatefulWidget {
  const RoomJoiningPage({Key? key}) : super(key: key);

  @override
  _RoomJoiningPageState createState() => _RoomJoiningPageState();
}

class _RoomJoiningPageState extends State<RoomJoiningPage> {
  final TextEditingController _gameCodeController = TextEditingController();
  late final IOWebSocketChannel _channel;
  String email = '';
  String userID = '';

  @override
  void initState() {
    super.initState();
    _channel = IOWebSocketChannel.connect('wss://app.hideandstreet.furrball.fr/joinGame');
    _getPref();
    _channel.stream.listen((message) {
      _handleServerResponse(message);
    }, onError: (error) {
      // Gérer les erreurs éventuelles
      print('Erreur de streaming: $error');
    });
  }

  void _getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email')!;
      userID = prefs.getString('userId') ?? '';
    });
  }

  void _joinGame() {
    String gameCode = _gameCodeController.text;
    String auth = "chatappauthkey231r4";

    if (gameCode.isNotEmpty) {
      // Envoyer la commande joinGame avec le code de la partie au serveur via WebSocket
      _channel.sink.add('{"email": "$email","auth":"$auth", "cmd":"joinGame","userId":"$userID", "gameCode":"$gameCode"}');
      print('{"email": "$email", "auth":"$auth", "cmd":"joinGame","gameCode":"$gameCode"}');
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.titre_popup_code_partie_invalide),
            content: Text(AppLocalizations.of(context)!.texte_popup_code_partie_invalide),
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
    }
  }

  void _handleServerResponse(String response) {
    final Map<String, dynamic> data = jsonDecode(response);
    print(data);
    if (data['cmd'] == 'joinGame') {
      if (data['status'] == 'success') {
        if (data.containsKey('gameCode')) {
          String gameCode = data['gameCode'];
          // Naviguer vers la page WaitingScreen en cas de succès
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WaitingScreen(gameCode: gameCode, isAdmin: false),
            ),
          );
        } else {
          // Gérer le cas où le serveur n'a pas renvoyé le code de la partie
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(AppLocalizations.of(context)!.titre_popup_reponse_incomplete_serveur),
                content: Text(AppLocalizations.of(context)!.texte_popup_reponse_incomplete_serveur),
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
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.rejoindrepartie),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.codePartie,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _gameCodeController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[300],
                hintText: AppLocalizations.of(context)!.exempleCodePartie,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _joinGame,
              style: ElevatedButton.styleFrom(
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 20,
                    cornerSmoothing: 1,
                  ),
                ),
                minimumSize: const Size(double.infinity, 80),
                backgroundColor: const Color(0xFF373967),
                foregroundColor: const Color(0xFF212348),
              ),
              child: Text(
                AppLocalizations.of(context)!.rejoindre,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}
