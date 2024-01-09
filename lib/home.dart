import 'package:flutter/material.dart';
import 'package:hide_and_street/map_conf_screen.dart';
import 'package:hide_and_street/room_creation.dart';
import 'package:hide_and_street/room_joining.dart';
import 'package:figma_squircle/figma_squircle.dart';

class HomePage extends StatelessWidget {
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
              const SizedBox(height: 16),

              // Bouton pour naviguer vers la page map_conf_screen.dart
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapConfScreen(),
                      ),
                    );
                  },
                  child: const Text('Aller à la carte'),
                ),
              ),
              const SizedBox(height: 16),

              // Bouton pour naviguer vers la page room_creation.dart
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 100, 15, 0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoomCreationPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Créer une partie',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 20,
                        cornerSmoothing: 1,
                      ),
                    ),
                    minimumSize: const Size(double.infinity, 80),
                    backgroundColor: const Color(0xFF17195E),
                    foregroundColor: const Color(0xFF212348),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Bouton pour naviguer vers la page room_joining.dart
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoomJoiningPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Rejoindre une partie',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 20,
                        cornerSmoothing: 1,
                      ),
                    ),
                    minimumSize: const Size(double.infinity, 80),
                    backgroundColor: const Color(0xFF17195E),
                    foregroundColor: const Color(0xFF212348),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
