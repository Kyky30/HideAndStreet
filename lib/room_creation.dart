// room_creation.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class RoomCreationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer une partie'),
      ),
      body: Center(
        child: Text('Contenu de la création de la partie'),
      ),
    );
  }
}
