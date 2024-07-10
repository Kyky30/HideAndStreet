import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:HideAndStreet/Page/Game/GameModes/ClassicMode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:HideAndStreet/components/buttons.dart';
import 'package:HideAndStreet/components/alertbox.dart';
import 'package:HideAndStreet/Page/Game/GameUtilities/ServerUtilities.dart';
import 'package:HideAndStreet/main.dart';
import 'package:HideAndStreet/monetization/AdmobHelper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class inGamePlayerlist extends StatefulWidget {
  final String gameCode;

  const inGamePlayerlist({required this.gameCode});

  @override
  _inGamePlayerlist createState() => _inGamePlayerlist();
}

class _inGamePlayerlist extends State<inGamePlayerlist> {
  String email = '';
  final _playerListController = StreamController<List<dynamic>>();
  late ServerUtilities serverUtilities;

  @override
  void initState() {
    super.initState();
    _getPref();
    serverUtilities = ServerUtilities(gameCode: widget.gameCode);
    getPlayerList();
    ();
  }

  void getPlayerList() async{
    dynamic response = await serverUtilities.getPlayerList();
    List<dynamic> players = jsonDecode(response)['players'];
    _playerListController.add(players);
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
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyHomePage(),
                ),
                    (Route<dynamic> route) => false, // This predicate means "remove all routes"
              );

            },
            scaleFactor: MediaQuery.of(context).textScaleFactor,
          );
        },
      );
  }


  @override
  void dispose() {
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
          Container(
              child: AdWidget(
                ad: AdmobHelper.getBannerAd()..load(),
                key: UniqueKey(),
              ),
              height: 75
          ),
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
