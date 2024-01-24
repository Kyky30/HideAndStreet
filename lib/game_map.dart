import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'chat.dart';
import 'PreferencesManager.dart';
import 'inGamePlayerList.dart';

class GameMap extends StatefulWidget {
  final LatLng center;
  final double radius;
  final int tempsDePartie;
  final int tempsDeCachette;
  final int timeStampDebutPartie;
  final String gameCode;
  final Map<String, bool> playerList;

  const GameMap({
    Key? key,
    required this.center,
    required this.radius,
    required this.tempsDePartie,
    required this.tempsDeCachette,
    required this.timeStampDebutPartie,
    required this.gameCode,
    required this.playerList,
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

  //Countdowns
  late Timer timerCachette;
  late Timer timerPartie;
  late int endTimeCachette;
  late int endTimePartie;
  late bool isCachetteActive;

  //Sockets
  late WebSocketChannel _channel;
  late String email;
  late String userId;

  //Joueur
  bool amITheSeeker = false;
  bool amIFound = false;

  //Joueurs
  late List<String> seekersIds = [];

  List<Marker> seekerMarkers = [];
  List<Marker> markers = [];

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  void _startTimers() {
    // Set endTime for timerCachette
    endTimeCachette = DateTime.now().millisecondsSinceEpoch +
        (tempsDeCachette * 60 * 1000);

    // Start timerCachette
    timerCachette = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (DateTime.now().millisecondsSinceEpoch >= endTimeCachette) {
          // Timer cachette ended, switch to timerPartie
          isCachetteActive = false;
          endTimePartie = endTimeCachette +
              (tempsDePartie * 60 * 1000);
          timerCachette.cancel(); // Stop timerCachette
          _startTimerPartie();
        }
      });
    });
  }

  void _startTimerPartie() {
    // Start timerPartie
    timerPartie = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (DateTime.now().millisecondsSinceEpoch >= endTimePartie) {
          // Timer partie ended, do something
          print('Game Over!');
          timerPartie.cancel(); // Stop timerPartie
        }
      });
    });
  }

  @override
  void dispose() {
    timerCachette.cancel();
    timerPartie.cancel();
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
        isCachetteActive = true;

    });
  });
  await _getPref();
  _sendPosToServer();
  _startLocationCheckTimer();
  _startTimers();

  _channel.stream.listen((message) {
    print('Received message: $message');
    Map<String, dynamic> data = jsonDecode(message);
    if (data['cmd'] == 'playerOutOfZone' && data['playerId'] != userId) {
      print('Player out of zone: ${data['playerId']}');

      // Parse latitude and longitude from the position string
      String positionString = data['position'];
      List<String> positionParts = positionString.split(', ');

      String latitudePart = positionParts[0];
      double latitude = double.parse(latitudePart.split(': ')[1]);

      String longitudePart = positionParts[1];
      double longitude = double.parse(longitudePart.split(': ')[1]);

      Marker marker = Marker(
        point: LatLng(latitude, longitude),
        width: 80,
        height: 80,
        child: Container(
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Icon(Symbols.location_on_rounded, fill: 1, weight: 700, grade: 200, opticalSize: 24, color: Colors.red, size: 30),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  data['playerName'],
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poppins",
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      print('Adding marker: $marker');
      setState(() {
        markers.add(marker);
      });

      Timer(Duration(seconds: 5), () {
        print('Removing marker: $marker');
        setState(() {
          markers.remove(marker);
        });
      });
    }
  });
}

  Future<void> _getPref() async {
    print("🔎 Récupération des préférences... ------------------");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email') ?? '';
    userId = prefs.getString('userId') ?? '';
  }

  Future<List<Position>> getPositionForId(List<String> ids) async {
    // Créer la requête au serveur
    String auth = "chatappauthkey231r4";
    Map<String, dynamic> command = {
      'email': email,
      'auth': auth,
      'cmd': 'getPositionForId',
      'gameCode': widget.gameCode,
      'ids': ids,
    };

    // Envoyer la requête au serveur
    _channel.sink.add(jsonEncode(command));

    // Attendre la réponse du serveur
    String serverResponse = await _channel.stream.first;
    print("📡 Réponse du serveur: $serverResponse");
    // Extraire la liste des positions à partir de la réponse du serveur
    Map<String, dynamic> data = jsonDecode(serverResponse);
    List<Position> positions = data['positions'].map((position) => Position.fromMap(position)).toList();

    // Retourner la liste des positions
    return positions;
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
      String auth = "chatappauthkey231r4";
      String position = currentPosition.toString(); // Convert the Position object to a string
      String gameCode = widget.gameCode;
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


  Future<void> _checkPlayerLocation() async {
    double distance = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      tapPosition.latitude,
      tapPosition.longitude,
    );

    isOutsideZoneNotifier.value = distance > radius;

    if (isOutsideZoneNotifier.value) {
      _sendOutOfZoneCommand();
    }

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

  void _sendOutOfZoneCommand() {
    print("📡 Envoi de la commande SetOutOfZone...");
    String auth = "chatappauthkey231r4";
    String position = currentPosition.toString(); // Convert the Position object to a string
    String gameCode = widget.gameCode;

    // Prepare the command
    Map<String, String> command = {
      'email': email,
      'auth': auth,
      'cmd': 'setOutOfZone',
      'position': currentPosition.toString(),
      'gameCode': gameCode,
      'playerId': userId,
    };

    // Send the command
    _channel.sink.add(jsonEncode(command));

    print("📡 Commande SetOutOfZone envoyée");
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
            Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 40),
                  Center(
                    child:
                    Row (
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isCachetteActive ? 'Timer Cachette : ' : 'Timer Partie : ' ,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: "Poppins"),
                        ),
                        CountdownTimer(
                          endTime: isCachetteActive ? endTimeCachette : endTimePartie,
                          textStyle: TextStyle(fontSize: 25, color: Colors.red, fontWeight: FontWeight.bold, fontFamily: "Poppins"),
                          onEnd: () {
                            print('Timer ${isCachetteActive ? 'Cachette' : 'Partie'} ended');
                            if (!isCachetteActive) {
                              //TODO: Procédure de fin de partie
                              print("🚨🚨🚨FIN DE PARTIE🚨🚨🚨");
                            }
                            else {
                              //TODO: Procédure de fin de cachette
                              print("🚨🚨FIN DE CACHETTE🚨🚨");
                            }

                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
                  MarkerLayer(markers: markers),
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
                  style: TextStyle(fontSize: 22.0, fontFamily: "Poppins", fontWeight: FontWeight.w600,color: isOutsideZone ? Colors.red : Colors.green),
                );
              },
            ),
            if (isBlindModeEnabled == true)
              ElevatedButton(
                onPressed: () {
                  print("���");
                },
                style: ElevatedButton.styleFrom(
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 20,
                      cornerSmoothing: 1,
                    ),
                  ),
                  minimumSize: Size(MediaQuery.of(context).size.width - 30, 80),
                  backgroundColor: const Color(0xFF373967),
                  foregroundColor: const Color(0xFF212348),
                ),
                child: Text(
                  AppLocalizations.of(context)!.connexion,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.white),
                ),
              ),
          ],
        ),
        floatingActionButton: isBlindModeEnabled == false
            ? Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'button2',
              onPressed: () async {
                bool? result = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirmation'),
                      content: Text('Have you been found?'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('No'),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        TextButton(
                          child: Text('Yes'),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  },
                );

                if (result == true) {
                  // Send 'ihavebeenfound' command to the server
                  String auth = "chatappauthkey231r4";
                  String gameCode = widget.gameCode;

                  // Prepare the command
                  Map<String, String> command = {
                    'email': email,
                    'auth': auth,
                    'cmd': 'setFoundStatus',
                    'gameCode': gameCode,
                    'playerId': userId,
                  };

                  // Send the command
                  _channel.sink.add(jsonEncode(command));
                }
              },
              child: const Icon(Symbols.hand_gesture, fill: 1, weight: 700, grade: 200, opticalSize: 24),
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'button2',
              onPressed: () {
                //TODO: Naviguer vers l'écran Chat
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Chat()),
                );
              },
              child: const Icon(Symbols.chat_rounded, fill: 1, weight: 700, grade: 200, opticalSize: 24),
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'button3',
              onPressed: () {
                //TODO: Naviguer vers la liste des joueurs
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => inGamePlayerlist(gameCode: widget.gameCode,)),
                );
              },
              child: const Icon(Symbols.people_rounded, fill: 1, weight: 700, grade: 200, opticalSize: 24),
            ),
            SizedBox(height: 40),
          ],
        )
            : null,

      );
    }
  }
}
