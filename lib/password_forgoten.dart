// account_settings.dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:hide_and_street/components/buttons.dart';
import 'package:hide_and_street/components/input.dart';
import 'package:hide_and_street/components/alertbox.dart';

class ForgotenPassword extends StatelessWidget {
  const ForgotenPassword({Key? key});

  double getScaleFactor(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    return mediaQueryData.textScaleFactor;
  }

  @override
  Widget build(BuildContext context) {
    final scaleFactor = getScaleFactor(context);

    String email = '';
    final emailController = TextEditingController();

    @override
    void initState() {
      // Listen for changes in the text fields
      emailController.addListener(() {
        email = emailController.text;
      });

    }

    @override
    void dispose() {
      // Clean up the controllers when the widget is disposed
      emailController.dispose();
    }

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
                      padding: EdgeInsets.fromLTRB(15 * scaleFactor, 0, 15 * scaleFactor, 0),
                      child: Text(
                        AppLocalizations.of(context)!.mail,
                        style: TextStyle(
                          fontSize: 18 * scaleFactor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(15 * scaleFactor, 8 * scaleFactor, 15 * scaleFactor, 0),
                    child:
                    CustomTextField(
                      hintText: AppLocalizations.of(context)!.whatmail,
                      controller: emailController,
                      scaleFactor: scaleFactor,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(15 * scaleFactor, 0, 15 * scaleFactor, 0),
            child: CustomButton(
              text: AppLocalizations.of(context)!.continuer,
              onPressed: () async {
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
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomAlertDialog1
                        (
                          title: AppLocalizations.of(context)!.titre_popup_mail_envoye,
                          content: AppLocalizations.of(context)!.texte_popup_mail_envoye,
                          buttonText: "OK",
                          onPressed: ()
                          {
                            Navigator.of(context).pop();
                          },
                          scaleFactor: scaleFactor
                      );
                    },
                  );
                },
              scaleFactor: scaleFactor,
            ),
          ),
          SizedBox(height: 25 * scaleFactor),
        ],
      ),
    );
  }
}
