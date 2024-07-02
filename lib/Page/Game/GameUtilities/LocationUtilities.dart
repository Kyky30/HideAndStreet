import 'package:geolocator/geolocator.dart';
import 'ServerUtilities.dart';

class LocationUtilities {
  static Position? _currentPosition;
  final ServerUtilities serverUtilities;

  LocationUtilities(this.serverUtilities);

  static Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifier si les services de localisation sont activés
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Les services de localisation sont désactivés.');
    }

    // Vérifier les permissions de localisation
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Les permissions de localisation sont refusées');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Les permissions de localisation sont définitivement refusées, nous ne pouvons pas demander les permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  // Mettre à jour ma position
  Future<Position> updateMyPosition() async {
    Position newPosition = await determinePosition();

    if (_currentPosition == null) {
      // Si la position actuelle est nulle, on la met à jour directement
      _currentPosition = newPosition;
      await serverUtilities.setPosition(newPosition);
      return newPosition;
    } else {
      // Calculer la distance entre la nouvelle position et la position actuelle
      final double distanceInMeters = Geolocator.distanceBetween(
        _currentPosition!.latitude, _currentPosition!.longitude,
        newPosition.latitude, newPosition.longitude,
      );

      if (distanceInMeters > 2.5) {
        // Si la distance est supérieure à 2.5 mètres, on met à jour la position
        _currentPosition = newPosition;
        await serverUtilities.setPosition(newPosition);
      }
      return _currentPosition!;
    }
  }
}
