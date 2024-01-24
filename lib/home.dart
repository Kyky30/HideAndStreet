import 'package:flutter/material.dart';
import 'package:hide_and_street/chat.dart';
import 'package:hide_and_street/game_map.dart';

import 'package:hide_and_street/map_conf_screen.dart';

import 'package:hide_and_street/room_joining.dart';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:hide_and_street/api/AdmobHelper.dart';
import 'package:hide_and_street/api/PremiumStatus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    _showFirstLaunchDialog();
  }

  Future<void> _showFirstLaunchDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    if (isFirstLaunch) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Bienvenue'),
            content: Text('Ceci est votre premier lancement de l\'application.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      await prefs.setBool('isFirstLaunch', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          // Image de fond
          Positioned.fill(
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
            ),
          ),
          // Contenu de la page
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align content at the top and bottom
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo en haut de la page
                Container(
                  margin: const EdgeInsets.fromLTRB(15, 75, 15, 0),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/logo_home_menu.png',
                        width: MediaQuery.of(context).size.width - 150,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                // Spacer to fill the available space
                const Spacer(),

                // Boutons pour créer et rejoindre une partie
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapConfScreen(),
                      ),
                    );
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
                    AppLocalizations.of(context)!.creerpartie,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoomJoiningPage(),
                      ),
                    );
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
                    AppLocalizations.of(context)!.rejoindrepartie,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );


  }
}
