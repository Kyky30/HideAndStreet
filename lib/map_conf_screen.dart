// map_conf_screen.dart
import 'package:flutter/material.dart';

class MapConfScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Configuration'),
      ),
      body: const Center(
        child: Text('Contenu de la configuration de la carte'),
      ),
    );
  }
}