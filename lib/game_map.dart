import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hide_and_street/winPage.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'chat.dart';
import 'PreferencesManager.dart';
import 'chatWebSocket.dart';
import 'chat_model.dart';


import 'package:hide_and_street/components/inGamePlayerList.dart';
import 'package:hide_and_street/components/buttons.dart';
import 'package:hide_and_street/components/alertbox.dart';

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
  late Stream broadcastStream;

  //Joueur
  bool amITheSeeker = false;
  bool amIFound = false;

  //Joueurs
  late List<String> seekersIds = [];

  List<Marker> seekerMarkers = [];
  List<Marker> markers = [];

  bool chatIsOpen = false;
  bool newMessage = false;

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
    timerCachette = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    timerPartie = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (DateTime.now().millisecondsSinceEpoch >= endTimePartie) {
          // Timer partie ended, do something
          print('Game Over!');
          timerPartie.cancel(); // Stop timerPartie
        }
      });
    });
  }

  void _checkSeekers() async {
    print(widget.playerList);
    //Parcourir la liste des joueurs selectionnés
    widget.playerList.forEach((player, value) {
      if (player == userId && value == true) {
        amITheSeeker = true;
        seekersIds.add(player);
      } else if (player != userId && value == true) {
        seekersIds.add(player);
      }
    });
    print("🔎 Je suis le seeker : $amITheSeeker");
    print("🔎 Liste des seekers : $seekersIds");
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
        _channel = WebSocketManager().channel;
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
    _checkSeekers();
    _startLocationCheckTimer();
    _startTimers();

    // Convert the stream to a broadcast stream
    broadcastStream = _channel.stream.asBroadcastStream();

    broadcastStream.listen((message) {

      print('Received message: $message');
      Map<String, dynamic> data = jsonDecode(message);
      if (data['cmd'] == 'ReceiveMessage') {
        // Utilisez le modèle de chat existant pour ajouter le message
        print("?? ${data['message']}");
        if(chatIsOpen == false)
        {
          newMessage = true;
          setState(() {});
        }
        Provider.of<ChatModel>(context, listen: false).addMessage(data['message'], data['email'], data['username']);
      }
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
                const Align(
                  alignment: Alignment.center,
                  child: Icon(Symbols.location_on_rounded, fill: 1, weight: 700, grade: 200, opticalSize: 24, color: Colors.red, size: 30),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    data['playerName'],
                    style: const TextStyle(
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

        Timer(const Duration(seconds: 5), () {
          print('Removing marker: $marker');
          setState(() {
            markers.remove(marker);
          });
        });
      }
      if(data['cmd'] == 'seekerWin')
      {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const winPage(isSeekerWin: true)),
              (Route<dynamic> route) => false,
        );
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

  Future<void> getSeekersPositions(List<String> seekerIds) async {
    print("📡 Récupération des positions des seekers... ------------------");
    String auth = "chatappauthkey231r4";
    Map<String, dynamic> command = {
      'email': email,
      'auth': auth,
      'cmd': 'getPositionForId',
      'gameCode': widget.gameCode,
      'ids': seekerIds,
    };

    // Send the command
    _channel.sink.add(jsonEncode(command));

    // Wait for the server response
    String serverResponse = await broadcastStream.first;
    Map<String, dynamic> data = jsonDecode(serverResponse);
    print("📡 Server response get SEEker: $serverResponse");

    // Clear the old seeker markers
    seekerMarkers.clear();

    // Iterate over each position in the 'positions' list
    for (var positionData in data['positions']) {
      // Check if the current user's id is not equal to the user id of the marker
      print((userId != positionData['userId'].toString()) == true);
      if ((userId != positionData['userId'].toString()) == true) {
        // Extract the list of positions from the server response
        String positionString = positionData['position'];
        List<String> positionParts = positionString.split(', ');

        String latitudePart = positionParts[0];
        double latitude = double.parse(latitudePart.split(': ')[1]);

        String longitudePart = positionParts[1];
        double longitude = double.parse(longitudePart.split(': ')[1]);

        // Add new markers for each position
        seekerMarkers.add(
          Marker(
            point: LatLng(latitude, longitude),
            width: 80,
            height: 80,
            child: Container(
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      positionData['username'].toString(), // replace with the actual username
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    print("📡 Seeker markers: ${seekerMarkers.length}");
    // Update the state to reflect the changes in the UI
    setState(() {});
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
        'position':position,
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


  void _startLocationCheckTimer() {
    timer1seconde = Timer.periodic(const Duration(seconds: 5), (timer) {
      print("1️⃣ Timer tick...  ------------------");
      _updatePosition();
      _checkPlayerLocation();
    });
    timer5secondes = Timer.periodic(const Duration(seconds: 5), (timer) {
      print("5️⃣ Timer tick...  ------------------");
      _sendPosToServer();
      _updateSeekersPositions();
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

    if (isOutsideZoneNotifier.value && amITheSeeker == false) {
      _sendOutOfZoneCommand();
    }
    print("📡 Je suis le seeker: $amITheSeeker");
    if(amITheSeeker == true)
    {
      print("📡 Je suis le seeker, je récupère les positions des autres seekers...");
      // Get the positions of other seekers
      List<String> seekerIds = widget.playerList.keys.where((id) => widget.playerList[id] == true).toList();
      getSeekersPositions(seekerIds);
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
      'position': position,
      'gameCode': gameCode,
      'playerId': userId,
    };

    // Send the command
    _channel.sink.add(jsonEncode(command));

    print("📡 Commande SetOutOfZone envoyée");
  }

  //TODO: A rendre fonctionnel
  Future<void> _updateSeekersPositions() async {
    List<Position> positionseeker = await getPositionForId(seekersIds);

    positionseeker.forEach((position) {
      Marker marker = Marker(
        point: LatLng(position.latitude, position.longitude),
        width: 80,
        height: 80,
        child: Container(
          child: const Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Icon(Symbols.location_on_rounded, fill: 1, weight: 700, grade: 200, opticalSize: 24, color: Colors.blue, size: 30),
              ),
            ],
          ),
        ),
      );
      setState(() {
        markers.add(marker);
      });
      Timer(const Duration(seconds: 5), () {
        print('Removing marker: $marker');
        setState(() {
          markers.remove(marker);
        });
      });
    });
  }


  @override
  Widget build(BuildContext context) {
      return Consumer<ChatModel>(
          builder: (context, chatModel, child) {
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
                          const SizedBox(height: 40),
                          Center(
                            child:
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isCachetteActive
                                      ? AppLocalizations.of(context)!.timer_cachette
                                      : AppLocalizations.of(context)!.timer_chasse,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Poppins",
                                  ),
                                ),
                                CountdownTimer(
                                  endTime: isCachetteActive
                                      ? endTimeCachette
                                      : endTimePartie,
                                  textStyle: const TextStyle(fontSize: 25,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Poppins"),
                                  onEnd: () {
                                    print('Timer ${isCachetteActive
                                        ? 'Cachette'
                                        : 'Partie'} ended');
                                    if (!isCachetteActive) {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(builder: (context) =>
                                            const winPage(isSeekerWin: false)),
                                            (Route<dynamic> route) => false,
                                      );
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
                    const SizedBox(height: 20),
                    Expanded(
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(
                              currentPosition.latitude,
                              currentPosition.longitude),
                          initialZoom: 15,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          ),
                          CurrentLocationLayer(),
                          MarkerLayer(markers: markers),
                          MarkerLayer(markers: seekerMarkers),
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
                          isOutsideZone
                              ? AppLocalizations.of(context)!.etat_en_dehors_de_la_zone
                              : AppLocalizations.of(context)!.etat_dans_la_zone,
                          style: TextStyle(fontSize: 22.0,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w600,
                              color: isOutsideZone ? Colors.red : Colors.green),
                        );
                      },
                    ),
                    if (isBlindModeEnabled == true)
                      CustomButton(
                          text: AppLocalizations.of(context)!.connexion,
                          onPressed: () async {
                            bool? result = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return CustomAlertDialog2(
                                    title: AppLocalizations.of(context)!.confirmer,
                                    content: AppLocalizations.of(context)!.confirmer_trouve,
                                    buttonText1: AppLocalizations.of(context)!.non,
                                    buttonText2: AppLocalizations.of(context)!.oui,
                                    onPressed1: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    onPressed2: () {
                                      Navigator.of(context).pop(true);
                                    },
                                    scaleFactor: MediaQuery.of(context).textScaleFactor,
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

                              //Local
                              amIFound = true;
                            }
                          },
                          scaleFactor: MediaQuery.of(context).textScaleFactor
                      )
                  ],
                ),
                floatingActionButton: isBlindModeEnabled == false
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (amITheSeeker == false && amIFound == false)
                      FloatingActionButton(
                        heroTag: 'button1',
                        onPressed: () async {
                          bool? result = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomAlertDialog2(
                                title: AppLocalizations.of(context)!.confirmer,
                                content: AppLocalizations.of(context)!.confirmer_trouve,
                                buttonText1: AppLocalizations.of(context)!.non,
                                buttonText2: AppLocalizations.of(context)!.oui,
                                onPressed1: () {
                                  Navigator.of(context).pop(false);
                                },
                                onPressed2: () {
                                  Navigator.of(context).pop(true);
                                },
                                scaleFactor: MediaQuery.of(context).textScaleFactor,
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

                          //Local
                          amIFound = true;
                        }
                      },
                      child: const Icon(Symbols.hand_gesture, fill: 1,
                          weight: 700,
                          grade: 200,
                          opticalSize: 24),
                    ),
                    const SizedBox(height: 10),
                  Stack(
                    children: [
                      FloatingActionButton(
                        heroTag: 'button2',
                        onPressed: () async {
                          // Naviguer vers l'écran Chat
                          chatIsOpen = true;
                          newMessage = false;
                          setState(() {}); // Mettre à jour l'interface utilisateur

                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Chat(
                                email: email,
                                gameCode: widget.gameCode,
                                broadcastChannel: broadcastStream,
                              ),
                            ),
                          );

                          // Mettre à jour l'état après le retour du Chat
                          chatIsOpen = false;
                          setState(() {});
                        },
                        child: const Icon(Symbols.chat_rounded, fill: 1, weight: 700, grade: 200, opticalSize: 24),
                      ),
                      if (newMessage)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                    const SizedBox(height: 10),
                  FloatingActionButton(
                    heroTag: 'button3',
                    onPressed: () {
                      //TODO: Naviguer vers la liste des joueurs
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>
                            inGamePlayerlist(gameCode: widget.gameCode,)),
                      );
                    },
                    child: const Icon(Symbols.people_rounded, fill: 1,
                        weight: 700,
                        grade: 200,
                        opticalSize: 24),
                  ),
                    const SizedBox(height: 40),
                ],
              )
                  : null,

            );
          }
        });
  }
}