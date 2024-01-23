import 'dart:async';
import 'dart:math';
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
  const GameMap({Key? key}) : super(key: key);

  @override
  State<GameMap> createState() => _GameMapState();
}

class _GameMapState extends State<GameMap> {

  //Positions
  late Position latestPositionSentToServer;
  late Position currentPosition;

  //Zone
  late LatLng tapPosition;
  late double radius;

  //Checks
  bool isLoading = true; // Suivre l'état de chargement
  bool isBlindModeEnabled = true;
  bool isOutsideZone = false; // Indicateur si le joueur est en dehors de la zone
  ValueNotifier<bool> isOutsideZoneNotifier = ValueNotifier<bool>(false);

  //Timer
  late Timer timer1seconde;
  late Timer timer5secondes;

  //Temps de partie
  //TODO: Récupérer le temps de partie depuis le serveur
  int timeStampDebutPartie = DateTime.now().millisecondsSinceEpoch; //En milisecondes
  //TODO: Récupérer le temps de cachette et de partie depuis le serveur
  int tempsDePartie = 300; // 5 minutes
  int tempsDeCachette = 60; // 1 minute



  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  @override
  void dispose() {
    timer1seconde.cancel();
    timer5secondes.cancel();
    super.dispose();
  }

  Future<void> _initializeState() async {
    await _loadBlindModeStatus();
    await _determinePosition().then((position) {
      setState(() {
        currentPosition = position;
        latestPositionSentToServer = position;
        //TODO: Envoyer la position au serveur

        //TODO: Récupérer la position du centre de la zone depuis le serveur
        tapPosition = LatLng(currentPosition.latitude, currentPosition.longitude);
        radius = 5; //en mètres
        isLoading = false;
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

  void _sendPosToServer() {
    double distance = Geolocator.distanceBetween(
      latestPositionSentToServer.latitude,
      latestPositionSentToServer.longitude,
      currentPosition.latitude,
      currentPosition.longitude,
    );
    print(" ");
    print("🚨 CHECK D'ENVOI DE POS AU SERVEUR 🚨 ------------------");
    print("⏲️ Dernière pos au serveur : $latestPositionSentToServer");
    print("📍 Pos actuelle : $currentPosition");
    print("📏 Distance : $distance");

    if (distance >= 2.5) {
      latestPositionSentToServer = currentPosition;
      print("📡 Envoi de la position au serveur...");
      //TODO: Envoyer la position au serveur


      print("📡 Position envoyée: $latestPositionSentToServer");
    }
    print(" ");
    print(" ");

  }

  _lancerTempsDeCachette() {
    CountdownTimer hideTimer = CountdownTimer(
      endTime: timeStampDebutPartie + tempsDeCachette * 1000,
      onEnd: () {
        print('Temps de cachette terminé');
        //TODO: Afficher un message de fin de temps de cachette et lancer le temps de partie
      },
    );
  }

  _lancerTempsDePartie() {
    CountdownTimer gameTimer = CountdownTimer(
        endTime: timeStampDebutPartie + tempsDePartie * 1000,
        onEnd: () {
          print('Temps de partie terminé');
          //TODO: Afficher un message de fin de partie et lancer la procédure de fin de partie
        }
    );
  }

  void _startLocationCheckTimer() {
    timer1seconde = Timer.periodic(Duration(seconds: 5), (timer) {
      print("1️⃣ Timer tick...  ------------------");
      _updatePosition();
      _checkPlayerLocation();
    });
    timer5secondes = Timer.periodic(Duration(seconds: 5), (timer) {
      print("5️⃣ Timer tick...  ------------------");
      _sendPosToServer();
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

    print(" ");
    print("🚨 CHECK DE ZONE 🚨 ------------------");
    print("📏 Distance du centre : $distance");
    print("⭕ Radius : $radius");
    print("📍 Pos actuelle : $currentPosition");
    print("🔀 Joueur en dehors : $isOutsideZoneNotifier.value");
    print(" ");
    print(" ");

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
