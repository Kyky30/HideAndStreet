import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'chat.dart';
import 'PreferencesManager.dart';

class GameMap extends StatefulWidget {
  final LatLng center;
  final double radius;
  final int tempsDePartie;
  final int tempsDeCachette;
  final int timeStampDebutPartie;
  final String gameCode;

  const GameMap({
    Key? key,
    required this.center,
    required this.radius,
    required this.tempsDePartie,
    required this.tempsDeCachette,
    required this.timeStampDebutPartie,
    required this.gameCode,
  }) : super(key: key);

  @override
  State<GameMap> createState() => _GameMapState();
}
class _GameMapState extends State<GameMap> {

  //Positions
  late Position latestPositionSentToServer;
  late Position currentPosition;
  late int timeStampDebutPartie;
  late int tempsDePartie;
  late int tempsDeCachette;

  //Zone
  late LatLng tapPosition;
  late double radius;

  //Checks
  bool isLoading = true; // Suivre l'état de chargement
  bool isBlindModeEnabled = true;
  bool isOutsideZone = false; // Indicateur si le joueur est en dehors de la zone
  ValueNotifier<bool> isOutsideZoneNotifier = ValueNotifier<bool>(false);
  bool isFirsUpdate = true;
  //Timer
  late Timer timer1seconde;
  late Timer timer5secondes;

  late WebSocketChannel _channel;
  late String email;
  late String userId;


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
      _channel = IOWebSocketChannel.connect('wss://app.hideandstreet.furrball.fr/getPlayerlist');
      timeStampDebutPartie = widget.timeStampDebutPartie;
      tempsDePartie = widget.tempsDePartie;
      tempsDeCachette = widget.tempsDeCachette;
      tapPosition = widget.center;
      radius = widget.radius; //en mètres
      isLoading = false;
    });
  });
  await _getPref();
  _sendPosToServer();
  _startLocationCheckTimer();
}

  Future<void> _getPref() async {
    print("🔎 Récupération des préférences... ------------------");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email') ?? '';
    userId = prefs.getString('userId') ?? '';
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
    if (distance >= 2.5 || isFirsUpdate == true) {
      isFirsUpdate = false;
      latestPositionSentToServer = currentPosition;
      print("📡 Envoi de la position au serveur...");
      //TODO: Envoyer la position au serveur
      String auth = "chatappauthkey231r4";
      String position = currentPosition.toString(); // Convert the Position object to a string
      String gameCode = widget.gameCode;
      print("🔎 userID : $userId");
      // Prepare the command
      Map<String, String> command = {
        'email': email,
        'auth': auth,
        'cmd': 'setPositionPlayer',
        'position': currentPosition.toString(),
        'gameCode': gameCode,
        'playerId': userId,
      };

      // Send the command
      _channel.sink.add(jsonEncode(command));

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
    print("‼️Temps de partie : $tempsDePartie");
    print("☎️Temps de cachette : $tempsDeCachette");
    print("♻️Timestamp debut partie : $timeStampDebutPartie");
    print("🌱 GameCode : ${widget.gameCode}");

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
