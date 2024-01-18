// account_settings.dart
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


class ForgotenPassword extends StatelessWidget {
  const ForgotenPassword({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.mdpOublieTitle),
      ),
      body: Column(
        children: [
          const SizedBox(height: 25),
          Expanded(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child: Text(
                        AppLocalizations.of(context)!.mail,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 8, 15, 0),
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[300],
                        hintText: AppLocalizations.of(context)!.whatmail,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: ElevatedButton(
              onPressed: () async {
                String email = 'dorianrochette@gmail.com';
                String auth = "chatappauthkey231r4";

                // Créer une connexion WebSocket
                WebSocketChannel channel = IOWebSocketChannel.connect('wss://app.hideandstreet.furrball.fr/resetPassword');

                // Envoyer la demande de réinitialisation du mot de passe au backend
                String resetData = '{"auth":"$auth","email":"$email","cmd":"resetPassword"}';
                print(resetData);
                channel.sink.add(resetData);

                // Fermer la connexion après envoi
                channel.sink.close();

                // Afficher un message à l'utilisateur
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Un email de réinitialisation a été envoyé.')),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 20,
                    cornerSmoothing: 1,
                  ),
                ),
                minimumSize: const Size(double.infinity, 70),
                backgroundColor: const Color(0xFF373967),
                foregroundColor: const Color(0xFF212348),
              ),
              child: Text(
                AppLocalizations.of(context)!.continuer,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }
}
