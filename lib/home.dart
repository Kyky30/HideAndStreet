import 'package:flutter/material.dart';
import 'package:hide_and_street/chat.dart';
import 'package:hide_and_street/game_map.dart';

import 'package:hide_and_street/map_conf_screen.dart';

import 'package:hide_and_street/map_conf_screen.dart';
import 'package:hide_and_street/room_joining.dart';

import 'package:hide_and_street/premium_page.dart';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

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

                // Boutons de navigation
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MapConfScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(MediaQuery.of(context).size.width - 30, 50),
                      ),
                      child: const Text('Aller à la carte'),
                    ),
                    const SizedBox(height: 6),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PremiumPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(MediaQuery.of(context).size.width - 30, 50),
                      ),
                      child: const Text('Aller à la page premium'),
                    ),
                    const SizedBox(height: 6),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Chat(partieId: 0),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(MediaQuery.of(context).size.width - 30, 50),
                      ),
                      child: const Text('Chat'),
                    ),
                    const SizedBox(height: 6),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GameMap(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(MediaQuery.of(context).size.width - 30, 50),
                      ),
                      child: const Text('Game Map'),
                    ),
                  ],
                ),

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
                    minimumSize: const Size(double.infinity, 80),
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
                    minimumSize: const Size(double.infinity, 80),
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
