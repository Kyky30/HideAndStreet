import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hide_and_street/Page/Game/GameUtilities/GlobalUtilities.dart';
import 'package:hide_and_street/Page/Game/GameUtilities/LocationUtilities.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hide_and_street/Page/winPage.dart';
import 'package:hide_and_street/components/alertbox.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../GameUtilities/ServerUtilities.dart';
import '../GameUtilities/TimerUtilities.dart';
import '../../../Page/Chat/chat_model.dart';
import '../../../Page/Chat/chat.dart';
import 'package:provider/provider.dart';
import 'package:hide_and_street/components/inGamePlayerList.dart';

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

  // Page controller
  PageController _pageController = PageController();

  // Current index for the bottom navigation bar
  int _currentIndex = 1;

  // Checks
  bool isLoading = true;

  // Chat variables
  bool chatIsOpen = false;
  bool newMessage = false;
  late SharedPreferences prefs;

  // Joueur
  bool amITheSeeker = false;
  List<String> seekerList = [];
  bool amIFound = false;

  // Variable to control the game loop
  bool isGameActive = true;

  @override
  void initState() {
    super.initState();
    _initializePreferences();

    // Initialiser l'index et le PageController pour commencer sur la page de la carte
    _currentIndex = 1;
    _pageController = PageController(initialPage: _currentIndex);

    serverUtilities = ServerUtilities(gameCode: widget.gameCode);
    locationUtilities = LocationUtilities(serverUtilities);

    seekerList = GlobalUtilities().getSeekers(widget.playerList);

    serverUtilities.outOfZoneStream.listen(_handleOutOfZone);
    serverUtilities.chatStream.listen(_handleChatUpdates);
    serverUtilities.seekerWinStream.listen(_handleSeekerWin);
    serverUtilities.leavegameStream.listen(_handleLeaveGame);
    startHiddingTimer();
  }

  Future<void> _initializePreferences() async {
    prefs = await SharedPreferences.getInstance();
    amITheSeeker = seekerList.contains(prefs.getString('userId'));
    setState(() {
      isLoading = false;
    });
  }

  void startHiddingTimer() {
    timerUtilities.startTimer(
      durationInMinutes: widget.hidingDuration,
      onEnd: startGame,
      startTime: DateTime.fromMillisecondsSinceEpoch(widget.timeStamGameStart),
      icon: Symbols.run_circle,
      timerName: 'Hiding phase : ',
    );
  }

  void startGame() {
    setState(() {
      isGameActive = true;
    });

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
    if (!isGameActive) return; // Exit the loop if the game is not active

    Future.delayed(const Duration(seconds: 5), () async {
      if (!isGameActive) return; // Check again if the game is still active

      currentPosition = await locationUtilities.updateMyPosition();

      if (!amITheSeeker && !amIFound) {
        if (amIOutOfZone()) {
          serverUtilities.setPlayerOutOfZone(currentPosition);
        }
      }
      if (amITheSeeker && seekerList.length > 1) {
        displayOtherSeekerPosition();
      }
      gameLoop();
    });
  }

  bool amIOutOfZone() {
    return Geolocator.distanceBetween(
      widget.center.latitude,
      widget.center.longitude,
      currentPosition.latitude,
      currentPosition.longitude,
    ) > widget.radius;
  }

  void displayOtherSeekerPosition() {
    // Envoyer la liste des seekers pour récupérer les positions
    serverUtilities.getPositionForId(seekerList).then((response) {
      // Convertir la réponse en map et accéder à la clé 'positions'
      var responseData = jsonDecode(response) as Map<String, dynamic>;
      List<dynamic> dataList = responseData['positions']; // Extraire la liste de positions

      // Nouveau set de marqueurs
      List<Marker> newMarkers = [];

      for (var data in dataList) {
        if (data['userId'].toString() != serverUtilities.userId) {
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
                    color: Colors.blue,
                    size: 30,
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    data['username'],
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins",
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          );

          newMarkers.add(marker);
        }
      }

      // Mettre à jour l'état avec le nouveau set de marqueurs
      setState(() {
        markers = newMarkers;
      });
    }).catchError((error) {
      debugPrint('Error getting positions for seekers: $error');
    });
  }

  void _handleOutOfZone(Map<String, dynamic> data) {
    if (data['playerId'] != serverUtilities.userId) {
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

      periodicTimer =
          Timer.periodic(const Duration(milliseconds: 500), (timer) {
            setState(() {
              if (markers.contains(marker)) {
                markers.remove(marker);
              } else {
                markers.add(marker);
              }
            });
          });

      Timer(const Duration(milliseconds: 9400), () {
        periodicTimer?.cancel(); // Arrête le timer périodique après 9400 ms
        setState(() {
          markers.remove(marker);
        });
      });
    }
  }

  void _handleLeaveGame(Map<String, dynamic> data)
  {
    setState(() {
      isGameActive = false; // Stop the game loop
    });

    // Appeler la méthode dispose pour libérer les ressources
    dispose();
  }

  void onEndGame() {
    debugPrint('Game ended');

    setState(() {
      isGameActive = false; // Stop the game loop
    });

    // Appeler la méthode dispose pour libérer les ressources
    dispose();

    // Naviguer vers la page de victoire et supprimer toutes les routes précédentes
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (context) => winPage(isSeekerWin: false, amISeeker: amITheSeeker)
      ),
          (Route<dynamic> route) => false,
    );
  }

  void _handleChatUpdates(Map<String, dynamic> data) {
    if (chatIsOpen == false) {
      newMessage = true;

      setState(() {});
    }
    Provider.of<ChatModel>(context, listen: false)
        .addMessage(data['message'], data['email'], data['username']);
  }

  void _handleSeekerWin(Map<String, dynamic> data) {
    setState(() {
      isGameActive = false; // Stop the game loop
    });

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) =>
              winPage(isSeekerWin: true, amISeeker: amITheSeeker)),
          (Route<dynamic> route) => false,
    );
  }

  @override
  void dispose() {
    timerUtilities.dispose();
    serverUtilities.dispose();
    Provider.of<ChatModel>(context, listen: false).ResetMessage();
    isGameActive = false; // Stop the game loop if the widget is disposed
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    // Nettoyer les ressources et réinitialiser l'état
    timerUtilities.dispose();
    serverUtilities.dispose();
    Provider.of<ChatModel>(context, listen: false).ResetMessage();
    setState(() {
      isGameActive = false; // Stop the game loop
    });
    return true; // Permet de quitter la page
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return Consumer<ChatModel>(builder: (context, chatModel, child) {
        return WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            body: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                Chat(
                  email: prefs.getString('email') ?? '',
                  gameCode: widget.gameCode,
                  broadcastChannel: serverUtilities.chatStream,
                ),
                buildMapScreen(),
                inGamePlayerlist(gameCode: widget.gameCode),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                _pageController.jumpToPage(index);
                setState(() {
                  _currentIndex = index;
                });
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Symbols.chat_rounded, fill: 1, weight: 700, grade: 200, opticalSize: 24),
                  label: AppLocalizations.of(context)!.chat,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Symbols.map_rounded, fill: 1, weight: 700, grade: 200, opticalSize: 24),
                  label: AppLocalizations.of(context)!.carte,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Symbols.people_rounded, fill: 1, weight: 700, grade: 200, opticalSize: 24),
                  label: AppLocalizations.of(context)!.joueurs,
                ),
              ],
              selectedFontSize: 20,
              unselectedFontSize: 18,
              iconSize: 30,
            ),
          ),
        );
      });
    }
  }

  Widget buildMapScreen() {
    return Column(
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
                urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
      ],
    );
  }
}
