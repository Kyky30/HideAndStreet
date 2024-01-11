// room_creation.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class RoomCreationPage extends StatelessWidget {
  const RoomCreationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.creerpartie),
      ),
      body: const Center(
        child: Text('Contenu de la création de la partie'),
      ),
    );
  }
}
