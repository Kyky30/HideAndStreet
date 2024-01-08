// home.dart
import 'package:flutter/material.dart';
import 'package:hide_and_street/map_conf_screen.dart';
import 'package:hide_and_street/room_creation.dart';
import 'package:hide_and_street/room_joining.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(15, 75, 15, 0),
            child: Column(
              children: [
                Image.asset(
                  'assets/logo_home_menu.png',
                  width: MediaQuery.of(context).size.width - 150, // Largeur ajustée
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 10), // Espacement de 10 pixels
              ],
            ),
          ),
          Expanded(
            child: Center(
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Naviguer vers la page map_conf_screen.dart
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapConfScreen(),
                  ),
                );
              },
              child: Text('Aller à la carte'),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Naviguer vers la page room_creation.dart
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoomCreationPage(),
                    ),
                  );
                },
                child: Text('Créer une partie'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Naviguer vers la page room_joining.dart
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoomJoiningPage(),
                    ),
                  );
                },
                child: Text('Rejoindre une partie'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
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
