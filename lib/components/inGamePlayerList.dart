import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hide_and_street/components/buttons.dart';
import 'package:hide_and_street/components/alertbox.dart';
import 'package:hide_and_street/Page/Game/GameUtilities/ServerUtilities.dart';
import 'package:hide_and_street/main.dart';

class inGamePlayerlist extends StatefulWidget {
  final String gameCode;

  const inGamePlayerlist({required this.gameCode});

  @override
  _inGamePlayerlist createState() => _inGamePlayerlist();
}

class _inGamePlayerlist extends State<inGamePlayerlist> {
  late WebSocketChannel _channel;
  String email = '';
  final _playerListController = StreamController<List<dynamic>>();
  late ServerUtilities serverUtilities;

  @override
  void initState() {
    super.initState();
    _channel = IOWebSocketChannel.connect(
        'wss://app.hideandstreet.furrball.fr/getInGamePlayerlist');
    _getPref();
    _initWebSocket();
    serverUtilities = ServerUtilities(gameCode: widget.gameCode);

  }

  void _initWebSocket() {
    _channel.stream.listen((message) {
      print('📥 Received message: $message'); // Print incoming message
      final Map<String, dynamic> data = jsonDecode(message);
      if (data['cmd'] == 'returnPlayerList') {
        print(
            '🎉 Success! Players data: ${data['players']}'); // Print success message and players data
        _playerListController.add(data['players']);
      }
    });
    print('📤 Sending request to server...'); // Print outgoing message
    _channel.sink.add(
        '{"email":"$email","auth":"chatappauthkey231r4","cmd":"getInGamePlayerlist", "gameCode":"${widget.gameCode}"}');
  }

  void _getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email')!;
    });
  }

  Future<void> _disconnectGamePopUp() async {
      bool? result = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog2(
            title: AppLocalizations.of(context)!.titre_popup_deconnexion,
            content: AppLocalizations.of(context)!.texte_popup_deconnexion,
            buttonText1: AppLocalizations.of(context)!.non,
            buttonText2: AppLocalizations.of(context)!.oui,
            onPressed1: () {
              Navigator.of(context).pop(false);
            },
            onPressed2: () {
              Navigator.of(context).pop(true);
              serverUtilities.leaveGame();
              //Ramener à la page d'accueil
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyHomePage(),
                ),
              );

            },
            scaleFactor: MediaQuery.of(context).textScaleFactor,
          );
        },
      );
  }


  @override
  void dispose() {
    _channel.sink.close();
    _playerListController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.listeDesJoueurs,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<dynamic>>(
              stream: _playerListController.stream,
              initialData: const [],
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  var data = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      var player = data[index];
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            player['seeker']
                                ? Symbols.search_rounded
                                : Symbols.person_rounded,
                            fill: 1,
                            weight: 700,
                            grade: 200,
                            opticalSize: 24,
                            color: player['found'] ? Colors.red : Colors.blue,
                          ),
                          title: Text(
                            player['username'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          subtitle: Text(
                            player['seeker']
                                ? AppLocalizations.of(context)!.seekers
                                : (player['found']
                                ? AppLocalizations.of(context)!.etat_trouve
                                : AppLocalizations.of(context)!.etat_non_trouve),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomButtonWithSymbol(
              text: AppLocalizations.of(context)!.deconnexion,
              onPressed: _disconnectGamePopUp,
              scaleFactor: MediaQuery.of(context).textScaleFactor,
              widthMinus: 30,
              backgroundColor: Colors.red,
              icon: Symbols.logout_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
