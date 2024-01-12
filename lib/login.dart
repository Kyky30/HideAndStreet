import 'package:flutter/material.dart';
import 'package:hide_and_street/main.dart';
import 'package:hide_and_street/password_forgoten.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:figma_squircle/figma_squircle.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
        SingleChildScrollView(
          child:
      Stack(
        children: [
          // Image de fond
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
                padding: const EdgeInsets.fromLTRB(15, 8, 15, 0),
                child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[300],
                    hintText: AppLocalizations.of(context)!.mdp,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
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
                    AppLocalizations.of(context)!.connexion,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.white),
                  ),
                ),
              ),
              // Bouton "Mot de passe oublié ?"
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotenPassword(),
                      ),
                    );
                  },
                  child: Text(
                      AppLocalizations.of(context)!.mdpoublie,
                      style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins', backgroundColor: Colors.white )
                  ),
                ),
              ),
              // Bouton "Mot de passe oublié ?"
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: TextButton(
                  onPressed: () {
                    launchUrl('https://www.bing.com' as Uri);
                  },
                  child: Text(
                      AppLocalizations.of(context)!.inscription,
                      style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins', backgroundColor: Colors.white )
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
        ),
    );
  }
}
