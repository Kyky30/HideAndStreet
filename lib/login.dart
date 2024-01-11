import 'package:flutter/material.dart';
import 'package:hide_and_street/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:figma_squircle/figma_squircle.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatelessWidget {
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

              // Champ de texte pour le mail
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 100, 15, 0),
                child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: AppLocalizations.of(context)!.mail,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Champ de texte pour le mot de passe
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: TextField(
                  obscureText: true, // Pour masquer le texte du mot de passe
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: AppLocalizations.of(context)!.mdp,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
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
                        builder: (context) => MyHomePage(),
                      ),
                    );
                  },
                  child: Text(
                    AppLocalizations.of(context)!.connexion,
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
                    backgroundColor: const Color(0xFF373967),
                    foregroundColor: const Color(0xFF212348),
                  ),
                ),
              ),
              // Bouton "Mot de passe oublié ?"
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: TextButton(
                  onPressed: () {
                    launch('https://www.bing.com');
                  },
                  child: Text(
                      AppLocalizations.of(context)!.mdpoublie,
                      style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins', backgroundColor: Colors.white )
                  ),
                ),
              ),
              // Bouton "Mot de passe oublié ?"
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: TextButton(
                  onPressed: () {
                    launch('https://www.bing.com');
                  },
                  child: Text(
                      AppLocalizations.of(context)!.inscription,
                      style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins', backgroundColor: Colors.white )
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
