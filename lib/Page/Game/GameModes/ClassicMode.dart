import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hide_and_street/Page/Game/GameUtilities/LocationUtilities.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hide_and_street/Page/winPage.dart';



import '../GameUtilities/ServerUtilities.dart';
import '../GameUtilities/TimerUtilities.dart';

import '../../../Page/Chat/chat_model.dart';
import '../../../Page/Chat/chat.dart';
import 'package:provider/provider.dart';


class ClassicMode extends StatefulWidget {
  final LatLng center; // Center of the circle
  final double radius; // Radius of the circle
  final int gameDuration; // Duration of the game
  final int hidingDuration; // Duration of the hiding phase
  final int timeStamGameStart; // Timestamp of the game start in milliseconds since epoch
  final String gameCode;
  final Map<String, bool> playerList;

  const ClassicMode({
    Key? key,
    required this.center,
    required this.radius,
    required this.gameDuration,
    required this.hidingDuration,
    required this.timeStamGameStart,
    required this.gameCode,
    required this.playerList,
  }) : super(key: key);

  @override
  State<ClassicMode> createState() => _ClassicModeState();
}

class _ClassicModeState extends State<ClassicMode> {
  List<Marker> markers = [];
  TimerUtilities timerUtilities = TimerUtilities();
  late ServerUtilities serverUtilities;
  late LocationUtilities locationUtilities;
  late Position currentPosition;

  //Checks
  bool isLoading = true;

  // Chat variables
  bool chatIsOpen = false;
  bool newMessage = false;
  late SharedPreferences prefs;

  //Joueur
  bool amITheSeeker = false;
  bool amIFound = false;

  @override
  void initState() {
    super.initState();
    serverUtilities = ServerUtilities(gameCode: widget.gameCode);
    locationUtilities = LocationUtilities(serverUtilities);
    serverUtilities.outOfZoneStream.listen(_handleOutOfZone);
    serverUtilities.chatStream.listen(_handleChatUpdates);
    serverUtilities.seekerWinStream.listen(_handleSeekerWin);
    startHiddingTimer();
    isLoading = false;
    _getPref();
  }

  Future<void> _getPref() async {
    print("🔎 Récupération des préférences... ------------------");
    prefs = await SharedPreferences.getInstance();
  }

  void startHiddingTimer() {
    timerUtilities.startTimer(
      durationInMinutes: widget.hidingDuration,
      onEnd: startGame,
      startTime: DateTime.fromMillisecondsSinceEpoch(widget.timeStamGameStart),
      icon: Symbols.synagogue_rounded,
      timerName: 'Hiding phase : ',
    );
  }

  void startGame() {
    timerUtilities.startTimer(
      durationInMinutes: widget.gameDuration,
      onEnd: onEndGame,
      startTime: DateTime.now(),
      icon: Symbols.location_on_rounded,
      timerName: 'Game phase : ',
    );
    gameLoop();
  }


  void gameLoop() {
    Future.delayed(const Duration(seconds: 5), () async {
      currentPosition = await locationUtilities.updateMyPosition();
      if (amIOutOfZone() == true) {
        debugPrint('You are out of the zone');
        serverUtilities.setPlayerOutOfZone(currentPosition);
      }
      gameLoop();
    });
  }

  bool amIOutOfZone(){
    return Geolocator.distanceBetween(
      widget.center.latitude, widget.center.longitude,
      currentPosition.latitude, currentPosition.longitude,
    ) > widget.radius;
  }

  void _handleOutOfZone(Map<String, dynamic> data) {
    if(data['playerId'] != serverUtilities.userId){
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
        child: Stack(
          children: <Widget>[
            const Align(
              alignment: Alignment.center,
              child: Icon(
                Symbols.location_on_rounded,
                fill: 1,
                weight: 700,
                grade: 200,
                opticalSize: 24,
                color: Colors.red,
                size: 30,
              ),
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
      );


      print('Adding marker: $marker');
      setState(() {
        markers.add(marker);
      });

      Timer? periodicTimer;

      periodicTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        setState(() {
          if (markers.contains(marker)) {
            markers.remove(marker);
          } else {
            markers.add(marker);
          }
        });
      });

      Timer(const Duration(milliseconds: 9400), () {
        periodicTimer?.cancel(); // Arrête le timer périodique après 4900 ms
        setState(() {
          markers.remove(marker);
        });
      });
    }
  }

  void onEndGame() {
    debugPrint('Game ended');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) =>
          winPage(isSeekerWin: false, amISeeker: amITheSeeker)),
          (Route<dynamic> route) => false,
    );
  }

  void _handleChatUpdates(Map<String, dynamic> data) {
    if(chatIsOpen == false)
    {
      newMessage = true;

      setState(() {});
    }
    Provider.of<ChatModel>(context, listen: false).addMessage(data['message'], data['email'], data['username']);
  }

  void _handleSeekerWin(Map<String, dynamic> data) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => winPage(isSeekerWin: true, amISeeker: amITheSeeker)),
          (Route<dynamic> route) => false,
    );
  }


  @override
  void dispose() {
    timerUtilities.dispose();
    serverUtilities.dispose();
    super.dispose();
    Provider.of<ChatModel>(context, listen: false).ResetMessage();
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
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TimerDisplay(
                    timerUtilities: timerUtilities,
                  ),
                ),
                Expanded(
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: widget.center,
                      initialZoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      ),
                      CircleLayer(circles: [
                        CircleMarker(
                          point: widget.center,
                          color: Colors.blue.withOpacity(0.3),
                          borderStrokeWidth: 2,
                          borderColor: Colors.blue,
                          useRadiusInMeter: true,
                          radius: widget.radius,
                        ),
                      ]),
                      MarkerLayer(markers: markers),
                      CurrentLocationLayer(),
                    ],
                  ),
                ),
                //Bouton de chat--------------------
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
                              email: prefs.getString('email') ?? '',
                              gameCode: widget.gameCode,
                              broadcastChannel: serverUtilities.chatStream,
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
              ],
            ),
          ),
        );
      }
    });
  }
}
