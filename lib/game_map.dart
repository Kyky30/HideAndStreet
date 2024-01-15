import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'chat.dart';

class GameMap extends StatefulWidget {
  const GameMap({Key? key}) : super(key: key);

  @override
  State<GameMap> createState() => _GameMapState();
}

class _GameMapState extends State<GameMap> {
  late Position currentPosition;
  late LatLng tapPosition;
  bool isLoading = true; // Suivre l'état de chargement
  late double radius;
  int countdownSeconds = 600;

  @override
  void initState() {
    super.initState();
    _determinePosition().then((position) {
      setState(() {
        currentPosition = position;
        tapPosition = LatLng(currentPosition.latitude, currentPosition.longitude);
        isLoading = false; // Définir l'état de chargement sur false lorsque la position est déterminée
        radius = 150;
      });
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Teste si les services de localisation sont activés.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Les services de localisation ne sont pas activés, ne continuez pas
      // à accéder à la position et demandez aux utilisateurs de l'application d'activer les services de localisation.
      return Future.error('Les services de localisation sont désactivés.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Les autorisations sont refusées, la prochaine fois, vous pourriez essayer
        // de demander à nouveau des autorisations (c'est aussi là que
        // shouldShowRequestPermissionRationale d'Android est retourné vrai. Selon les directives d'Android
        // votre application doit maintenant afficher une interface utilisateur explicative.
        return Future.error("Les autorisations de localisation sont refusées");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Les autorisations sont refusées pour toujours, gérez-les de manière appropriée.
      return Future.error(
          'Les autorisations de localisation sont refusées de manière permanente, nous ne pouvons pas demander les autorisations.');
    }

    // Lorsque nous arrivons ici, les autorisations sont accordées et nous pouvons
    // continuer à accéder à la position du périphérique.
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return Scaffold(
        body: Column(
          children: [
            CountdownTimer(
              endTime: DateTime.now().millisecondsSinceEpoch + countdownSeconds * 1000,
              widgetBuilder: (_, CurrentRemainingTime? time) {
                if (time == null) {
                  return const Text("00:00",
                    style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                  );
                }
                return Text(
                  '${time.min}:${time.sec}',
                  style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                );
              },
            ),
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(
                      currentPosition.latitude, currentPosition.longitude),
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),
                  CurrentLocationLayer(),
                  CircleLayer(circles: [
                    CircleMarker(
                      point: tapPosition,
                      color: Colors.grey.withOpacity(0.5),
                      borderColor: Colors.black,
                      borderStrokeWidth: 2,
                      useRadiusInMeter: true,
                      radius: radius, //en mètres
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Naviguer vers l'écran Chat
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Chat()),
            );
          },
          child: Icon(Icons.chat),
        ),
      );
    }
  }
}
