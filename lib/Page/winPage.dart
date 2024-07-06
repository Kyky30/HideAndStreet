import 'package:flutter/material.dart';
import 'package:hide_and_street/Page/map_conf_screen.dart';
import 'package:hide_and_street/main.dart';
import 'package:hide_and_street/room_joining.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hide_and_street/WebSocketManager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';


import '../components/buttons.dart';

class winPage extends StatefulWidget {
  final bool isSeekerWin;
  final bool amISeeker;

  winPage({required this.isSeekerWin, required this.amISeeker});

  @override
  _WinPageState createState() => _WinPageState();
}


class _WinPageState extends State<winPage> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init () async{
    debugPrint('🚨-------------------------------------------------------------------------------🚨');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    debugPrint('Envoi de la commande addPlayedGameForId pour le joueur ${prefs.getString('userId')??''}');
    await WebSocketManager.connect(prefs.getString('email')??'');
    await WebSocketManager.sendData("'cmd':'addPlayedGameForId','playerId':'${prefs.getString('userId')??''}'");



    if(widget.isSeekerWin && widget.amISeeker){
      debugPrint('Envoi de la commande addWonGameForId pour le joueur ${prefs.getString('userId')??''}');
      await WebSocketManager.sendData("'cmd':'addWonGameForId','playerId':'${prefs.getString('userId')??''}'");
    } else if (!widget.isSeekerWin && !widget.amISeeker){
      debugPrint('Envoi de la commande addWonGameForId pour le joueur ${prefs.getString('userId')??''}');
      await WebSocketManager.sendData("'cmd':'addWonGameForId','playerId':'${prefs.getString('userId')??''}'");
    }
    debugPrint('🚨-------------------------------------------------------------------------------🚨');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            AppLocalizations.of(context)!.game_over,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.black),
          ),
          Text(
            widget.isSeekerWin ? AppLocalizations.of(context)!.victoire_chercheur : AppLocalizations.of(context)!.victoire_cacheur,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w500, fontFamily: 'Poppins', color: Colors.blue),
          ),
          SizedBox(height: 300 * MediaQuery.of(context).textScaleFactor),
          Center(
            child: Column(
              children: [
                CustomButton(
                    text: AppLocalizations.of(context)!.creerpartie,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MapConfScreen(),
                        ),
                      );
                    },
                    scaleFactor: MediaQuery.of(context).textScaleFactor,
                ),

                SizedBox(height: 16 * MediaQuery.of(context).textScaleFactor),

                CustomButton(
                    text: AppLocalizations.of(context)!.rejoindrepartie,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RoomJoiningPage(),
                        ),
                      );
                    },
                    scaleFactor: MediaQuery.of(context).textScaleFactor,
                ),

                SizedBox(height: 16 * MediaQuery.of(context).textScaleFactor),

                CustomButton(
                    text: AppLocalizations.of(context)!.accueil,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyHomePage(),
                        ),
                      );
                    },
                    scaleFactor: MediaQuery.of(context).textScaleFactor,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
