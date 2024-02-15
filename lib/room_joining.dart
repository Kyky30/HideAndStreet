import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hide_and_street/Page/waitingScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:hide_and_street/components/alertbox.dart';
import 'package:hide_and_street/components/input.dart';

// Importez votre gestionnaire de WebSocket
import 'WebSocketManager.dart';

class RoomJoiningPage extends StatefulWidget {
  const RoomJoiningPage({Key? key}) : super(key: key);

  @override
  _RoomJoiningPageState createState() => _RoomJoiningPageState();
}

class _RoomJoiningPageState extends State<RoomJoiningPage> {
  final TextEditingController _gameCodeController = TextEditingController();
  String email = '';
  String userID = '';

  double getScaleFactor(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    return mediaQueryData.textScaleFactor;
  }

  @override
  void initState() {
    super.initState();
    WebSocketManager.connect(email);
    _getPref();
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

    if (gameCode.isNotEmpty) {
      WebSocketManager.sendData('"email": "$email", "cmd":"joinGame","userId":"$userID", "gameCode":"$gameCode"');

      // Écoutez les réponses du serveur
      WebSocketManager.getStream().listen((message) {
        Map<String, dynamic> data = json.decode(message);
        print(data);

        if (data['cmd'] == 'joinGame') {
          if (data['status'] == 'success') {
            if (data.containsKey('gameCode')) {
              String gameCode = data['gameCode'];
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WaitingScreen(gameCode: gameCode, isAdmin: false),
                ),
              );
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CustomAlertDialog1(
                    title: AppLocalizations.of(context)!.erreur,
                    content: AppLocalizations.of(context)!.erreurconnexion,
                    buttonText: AppLocalizations.of(context)!.ok,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    scaleFactor: getScaleFactor(context),
                  );
                },
              );
            }
          }
        }
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog1(
            title: AppLocalizations.of(context)!.erreur,
            content: AppLocalizations.of(context)!.erreurconnexion,
            buttonText: AppLocalizations.of(context)!.erreurconnexion,
            onPressed: () {
              Navigator.of(context).pop();
            },
            scaleFactor: getScaleFactor(context),
          );
        },
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final scaleFactor = getScaleFactor(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.rejoindrepartie),
      ),
      body: Padding(
        padding: EdgeInsets.all(16 * scaleFactor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.codePartie,
              style: TextStyle(fontSize: 24 * scaleFactor, fontWeight: FontWeight.bold),
            ),
            CustomTextField(
              controller: _gameCodeController,
              hintText: AppLocalizations.of(context)!.exempleCodePartie,
              scaleFactor: scaleFactor,
            ),
            SizedBox(height: 16.0 * scaleFactor),
            ElevatedButton(
              onPressed: _joinGame,
              style: ElevatedButton.styleFrom(
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 20 * scaleFactor,
                    cornerSmoothing: 1,
                  ),
                ),
                minimumSize: Size(double.infinity, 80 * scaleFactor),
                backgroundColor: const Color(0xFF373967),
                foregroundColor: const Color(0xFF212348),
              ),
              child: Text(
                AppLocalizations.of(context)!.rejoindre,
                style: TextStyle(fontSize: 20 * scaleFactor, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Fermez la connexion WebSocket lorsque la page est détruite
    WebSocketManager.closeConnection();
    super.dispose();
  }
}
