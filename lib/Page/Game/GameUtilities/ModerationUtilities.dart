import 'package:shared_preferences/shared_preferences.dart';
import 'package:HideAndStreet/PreferencesManager.dart';
import 'package:HideAndStreet/components/alertbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ModerationUtilities {
  late SharedPreferences prefs;

  ModerationUtilities() {
    _getPrefs();
  }

  Future<void> _getPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> reportMessages(String reporterEmail, String messages) async {
    // Implémentation de l'envoi de message de signalement
  }

  Future<void> hidePlayer(String username) async {
    List<String> hiddenPlayers = await PreferencesManager.getMaskedPlayers();
    if (!hiddenPlayers.contains(username)) {
      hiddenPlayers.add(username);
      await PreferencesManager.setMaskedPlayers(hiddenPlayers);
    }
  }

  Future<bool> isPlayerHidden(String username) async {
    List<String> hiddenPlayers = await PreferencesManager.getMaskedPlayers();
    return hiddenPlayers.contains(username);
  }

  Future<void> unhidePlayer(String username) async {
    List<String> hiddenPlayers = await PreferencesManager.getMaskedPlayers();
    if (hiddenPlayers.contains(username)) {
      hiddenPlayers.remove(username);
      await PreferencesManager.setMaskedPlayers(hiddenPlayers);
    }
  }

  Future<void> openModerationMenu(
      String nomUtilisateurMessage, BuildContext context) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog1(
          title: AppLocalizations.of(context)!.titre_popup_moderation,
          content: AppLocalizations.of(context)!.texte_popup_moderation,
          buttonText: AppLocalizations.of(context)!.bouton_signaler,
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CustomAlertDialog1(
                  title: AppLocalizations.of(context)!
                      .titre_popup_confirmation_signalement,
                  content: AppLocalizations.of(context)!
                      .texte_popup_confirmation_signalement,
                  buttonText: 'OK',
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  scaleFactor: MediaQuery.of(context).textScaleFactor,
                );
              },
            );
          },
          scaleFactor: MediaQuery.of(context).textScaleFactor,
        );

        // return CustomAlertDialog2(
        //   title: AppLocalizations.of(context)!.titre_popup_moderation,
        //   content: AppLocalizations.of(context)!.texte_popup_moderation,
        //   buttonText1: isPlayerHidden(nomUtilisateurMessage).toString() == "true" ? AppLocalizations.of(context)!.bouton_demasquer : AppLocalizations.of(context)!.bouton_masquer,
        //   buttonText2: AppLocalizations.of(context)!.bouton_signaler,
        //   onPressed1: () {
        //     if (isPlayerHidden(nomUtilisateurMessage).toString() == "true") {
        //       unhidePlayer(nomUtilisateurMessage);
        //     } else {
        //       hidePlayer(nomUtilisateurMessage);
        //     }
        //     Navigator.pop(context, true);
        //   },
        //   onPressed2: () {
        //     showDialog(
        //         context: context,
        //         builder: (BuildContext context) {
        //           return CustomAlertDialog1(
        //             title: AppLocalizations.of(context)!.titre_popup_confirmation_signalement,
        //             content: AppLocalizations.of(context)!.texte_popup_confirmation_signalement,
        //             buttonText: 'OK',
        //             onPressed: () {
        //               Navigator.of(context).pop();
        //             },
        //             scaleFactor: MediaQuery.of(context).textScaleFactor,
        //           );
        //         },
        //     );
        //   },
        //   scaleFactor: MediaQuery.of(context).textScaleFactor,
        // );
      },
    );
  }
}
