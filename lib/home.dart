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
            title: Text(AppLocalizations.of(context)!.titre_popup_avertissement),
            content: Text(AppLocalizations.of(context)!.texte_popup_avertissement),
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

  double getScaleFactor(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    return mediaQueryData.textScaleFactor;
  }

  @override
  Widget build(BuildContext context) {
    final scaleFactor = getScaleFactor(context);

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo en haut de la page
                Container(
                  margin: EdgeInsets.fromLTRB(15, 75 * scaleFactor, 15, 0),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/logo_home_menu.png',
                        width: (MediaQuery.of(context).size.width - 150) * scaleFactor,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 10 * scaleFactor),
                    ],
                  ),
                ),
                SizedBox(height: 3 * scaleFactor),
                // Spacer pour remplir l'espace disponible
                Spacer(),
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
                        cornerRadius: 20 * scaleFactor,
                        cornerSmoothing: 1,
                      ),
                    ),
                    minimumSize: Size(MediaQuery.of(context).size.width - 30, 80 * scaleFactor),
                    backgroundColor: const Color(0xFF373967),
                    foregroundColor: const Color(0xFF212348),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.creerpartie,
                    style: TextStyle(fontSize: 20 * scaleFactor, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.white),
                  ),
                ),
                SizedBox(height: 16 * scaleFactor),
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
                        cornerRadius: 20 * scaleFactor,
                        cornerSmoothing: 1,
                      ),
                    ),
                    minimumSize: Size(MediaQuery.of(context).size.width - 30, 80 * scaleFactor),
                    backgroundColor: const Color(0xFF373967),
                    foregroundColor: const Color(0xFF212348),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.rejoindrepartie,
                    style: TextStyle(fontSize: 20 * scaleFactor, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.white),
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
