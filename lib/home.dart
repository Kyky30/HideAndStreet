import 'package:flutter/material.dart';

import 'package:hide_and_street/Page/map_conf_screen.dart';

import 'package:hide_and_street/room_joining.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hide_and_street/components/buttons.dart';
import 'package:hide_and_street/components/alertbox.dart';

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
          return CustomAlertDialog1(
              title: AppLocalizations.of(context)!.titre_popup_avertissement,
              content: AppLocalizations.of(context)!.texte_popup_avertissement,
              buttonText: 'OK',
              onPressed: () {
                Navigator.of(context).pop();
              },
              scaleFactor: getScaleFactor(context));
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
                const Spacer(),
                // Boutons pour créer et rejoindre une partie

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
                    scaleFactor: scaleFactor
                ),

                SizedBox(height: 16 * scaleFactor),

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
                    scaleFactor: scaleFactor
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
