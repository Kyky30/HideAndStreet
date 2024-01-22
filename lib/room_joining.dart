import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hide_and_street/waitingScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez entrer un code de partie valide.'),
        ),
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
              builder: (context) => WaitingScreen(gameCode: gameCode),
            ),
          );
        } else {
          // Gérer le cas où le serveur n'a pas renvoyé le code de la partie
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Réponse du serveur incomplète. Veuillez réessayer.'),
            ),
          );
        }
      } else {
        // Gérer d'autres états, par exemple, afficher un message d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible de rejoindre la partie. Vérifiez le code de la partie.'),
          ),
        );
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
            TextField(
              controller: _gameCodeController,
              decoration: InputDecoration(
                labelText: 'Code de la partie',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _joinGame,
              child: Text('Rejoindre la partie'),
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
