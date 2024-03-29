import 'package:flutter/material.dart';
import 'package:hide_and_street/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';

import '../../components/alertbox.dart';
import 'login_model.dart';

class LoginController {//
  final LoginModel _model = LoginModel();

  Future<void> login(BuildContext context, String email, String password) async {
    bool success = await _model.login(email, password);
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MyHomePage(),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog1(
            title: AppLocalizations.of(context)!.erreur,
            content: AppLocalizations.of(context)!.erreurconnexion,
            buttonText: AppLocalizations.of(context)!.ok,
            onPressed: () {
              Navigator.of(context).pop();
            },
            scaleFactor: MediaQuery.of(context).textScaleFactor,
          );
        },
      );
    }
  }
}
