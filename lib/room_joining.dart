// room_joining.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class RoomJoiningPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.rejoindrepartie),
      ),
      body: Center(
        child: Text('Contenu de la page de rejoindre la partie'),
      ),
    );
  }
}
