import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'ServerUtilities.dart';

class BlindUtilities {
  late ServerUtilities serverUtilities;
  final AudioPlayer player = AudioPlayer();

  void initialize(ServerUtilities serverUtilitiesInstance) {
    serverUtilities = serverUtilitiesInstance;
  }

  Future<void> blindHaptic(Map<String, bool> playerList, List<String> seekersIds, LatLng currentPosition) async {
    print("Fonction blindHaptic exécutée --------------------------------------------------------------------------------------------");

    List<String> hiderIds = playerList.keys.where((id) => seekersIds.contains(id) == false).toList();

    try {
      var response = await serverUtilities.getPositionForId(hiderIds);
      var responseData = jsonDecode(response) as Map<String, dynamic>;
      List<dynamic> positions = responseData['positions'];

      for (var position in positions) {
        String positionString = position['position'];
        List<String> positionParts = positionString.split(', ');

        double latitude = double.parse(positionParts[0].split(': ')[1]);
        double longitude = double.parse(positionParts[1].split(': ')[1]);

        double distance = Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          latitude,
          longitude,
        );

        // Si la distance entre le chercheur et le hider est inférieure à 50m alors on émet un bip et une vibration
        if (distance <= 10) {
          HapticFeedback.heavyImpact();
          // Play a sound
          await player.setSource(AssetSource('Beep.wav'));
          player.play(player.source!);
        }
      }
    } catch (e) {
      print("Error getting positions: $e");
    }
  }
}
