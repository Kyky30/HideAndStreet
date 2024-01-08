// home.dart
import 'package:flutter/material.dart';
import 'package:hide_and_street/map_conf_screen.dart'; // Assurez-vous d'importer correctement la page map_conf_screen.dart

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 50),
            child: Image.asset(
              'assets/your_image.jpg', // Remplacez par le chemin de votre image
              width: MediaQuery.of(context).size.width - 200, // Largeur ajustée
              fit: BoxFit.contain,
            ),
          ),
          Expanded(
            child: Center(
              child: Text('Home Page Content'),
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
        ],
      ),
    );
  }
}
