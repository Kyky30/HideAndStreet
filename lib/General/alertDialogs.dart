import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hide_and_street/components/alertbox.dart';

void showPasswordMismatchDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomAlertDialog1(
        title: AppLocalizations.of(context)!.titre_popup_mdp,
        content: AppLocalizations.of(context)!.texte_popup_mdp,
        buttonText: AppLocalizations.of(context)!.ok,
        onPressed: () {
          Navigator.of(context).pop();
        },
        scaleFactor: MediaQuery.of(context).textScaleFactor,
      );
    },
  );
}

void showEmptyFieldDialog(BuildContext context) {
  print("🚫 Champ vide");
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomAlertDialog1(
        title: AppLocalizations.of(context)!.titre_popup_champ_vide,
        content: AppLocalizations.of(context)!.texte_popup_champ_vide,
        buttonText: AppLocalizations.of(context)!.ok,
        onPressed: () {
          Navigator.of(context).pop();
        },
        scaleFactor: MediaQuery.of(context).textScaleFactor,
      );
    },
  );
}

void showAgeRestrictionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomAlertDialog1(
        title: AppLocalizations.of(context)!.titre_popup_age,
        content: AppLocalizations.of(context)!.texte_popup_age,
        buttonText: AppLocalizations.of(context)!.ok,
        onPressed: () {
          Navigator.of(context).pop();
        },
        scaleFactor: MediaQuery.of(context).textScaleFactor,
      );
    },
  );
}

void showPasswordInsecureDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomAlertDialog1(
        title: AppLocalizations.of(context)!.titre_popup_mdp_insecure,
        content: AppLocalizations.of(context)!.texte_popup_mdp_insecure,
        buttonText: AppLocalizations.of(context)!.ok,
        onPressed: () {
          Navigator.of(context).pop();
        },
        scaleFactor: MediaQuery.of(context).textScaleFactor,
      );
    },
  );
}



