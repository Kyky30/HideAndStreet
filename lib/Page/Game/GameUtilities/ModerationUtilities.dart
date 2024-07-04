import 'package:shared_preferences/shared_preferences.dart';
import 'package:hide_and_street/components/alertbox.dart';
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

  void hidePlayer(String username) {
    List<String> hiddenPlayers = prefs.getStringList('hiddenPlayers') ?? [];
    if (!hiddenPlayers.contains(username)) {
      hiddenPlayers.add(username);
      prefs.setStringList('hiddenPlayers', hiddenPlayers);
    }
  }

  bool isPlayerHidden(String username) {
    List<String> hiddenPlayers = prefs.getStringList('hiddenPlayers') ?? [];
    return hiddenPlayers.contains(username);
  }

  void unhidePlayer(String username) {
    List<String> hiddenPlayers = prefs.getStringList('hiddenPlayers') ?? [];
    if (hiddenPlayers.contains(username)) {
      hiddenPlayers.remove(username);
      prefs.setStringList('hiddenPlayers', hiddenPlayers);
    }
  }

  Future<void> openModerationMenu(String nomUtilisateurMessage, BuildContext context) async{
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog2(
          title: AppLocalizations.of(context)!.titre_popup_moderation,
          content: AppLocalizations.of(context)!.texte_popup_moderation,
          buttonText1: isPlayerHidden(nomUtilisateurMessage) ? AppLocalizations.of(context)!.bouton_demasquer : AppLocalizations.of(context)!.bouton_masquer,
          buttonText2: AppLocalizations.of(context)!.bouton_signaler,
          onPressed1: () {
            if (isPlayerHidden(nomUtilisateurMessage)) {
              unhidePlayer(nomUtilisateurMessage);
            } else {
              hidePlayer(nomUtilisateurMessage);
            }
            Navigator.pop(context, true);
          },
          onPressed2: () {
            Navigator.pop(context, true);
          },
          scaleFactor: MediaQuery.of(context).textScaleFactor,
        );
      },
    );

  }
}

