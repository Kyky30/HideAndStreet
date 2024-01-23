import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'chat.dart';
import 'PreferencesManager.dart';

class GameMap extends StatefulWidget {
  final LatLng center;
  final double radius;

  const GameMap({
    Key? key,
    required this.center,
    required this.radius,
  }) : super(key: key);

  @override
  State<GameMap> createState() => _GameMapState();
}
class _GameMapState extends State<GameMap> {
  late Position currentPosition;
  late LatLng tapPosition;
  bool isLoading = true; // Suivre l'état de chargement
  late double radius;
  int countdownSeconds = 600;
  bool isBlindModeEnabled = true;
  bool isOutsideZone = false; // Indicateur si le joueur est en dehors de la zone

  late Timer timer;

  ValueNotifier<bool> isOutsideZoneNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _initializeState();
  }
  @override
  void dispose() {
    timer.cancel(); // Annulez le timer lorsqu'il n'est plus nécessaire
    super.dispose();
  }

  Future<void> _initializeState() async {
    await _loadBlindModeStatus();
    await _determinePosition().then((position) {
      setState(() {
        currentPosition = position;
        tapPosition = widget.center; // Set tapPosition to the center passed to the widget
        isLoading = false;
        radius = widget.radius; // Set radius to the radius passed to the widget
      });
    });
    _startLocationCheckTimer();
  }

  Future<void> _loadBlindModeStatus() async {
    isBlindModeEnabled = await PreferencesManager.getBlindToggle();
    setState(() {});
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Les services de localisation sont désactivés.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Les autorisations de localisation sont refusées");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Les autorisations de localisation sont refusées de manière permanente, nous ne pouvons pas demander les autorisations.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _updatePosition() async {
    currentPosition = await _determinePosition();
    _checkPlayerLocation();
  }

  void _startLocationCheckTimer() {
    print("Starting timer...");
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      print("Timer tick...");
      _updatePosition();
      _checkPlayerLocation();
    });
  }


  void _checkPlayerLocation() {
    double distance = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      tapPosition.latitude,
      tapPosition.longitude,
    );

    isOutsideZoneNotifier.value = distance > radius;

    print("Distance: $distance");
    print("Radius: $radius");
    print(currentPosition);
    print(isOutsideZoneNotifier.value);
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
            SizedBox(height: 20),
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
                  style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, fontFamily: "Poppins"),
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
            ValueListenableBuilder<bool>(
              valueListenable: isOutsideZoneNotifier,
              builder: (context, isOutsideZone, child) {
                return Text(
                  isOutsideZone ? "Vous êtes en dehors de la zone" : "Vous êtes dans la zone",
                  style: TextStyle(fontSize: 26.0, fontFamily: "Poppins", fontWeight: FontWeight.w600,color: isOutsideZone ? Colors.red : Colors.green),
                );
              },
            ),
          ],
        ),
        floatingActionButton: isBlindModeEnabled == false
            ? FloatingActionButton(
          onPressed: () {
            // Naviguer vers l'écran Chat
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Chat()),
            );
          },
          child: Icon(Icons.chat),
        )
            : null,
      );
    }
  }
}
