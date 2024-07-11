import 'dart:async';
import 'dart:convert';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:share/share.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../PreferencesManager.dart';
import 'package:HideAndStreet/monetization/AdmobHelper.dart';
import 'package:HideAndStreet/monetization/PremiumStatus.dart';
import '../WebSocketManager.dart';
import 'Game/GameModes/ClassicMode.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:HideAndStreet/components/alertbox.dart';

class WaitingScreen extends StatefulWidget {
  final String gameCode;
  final bool isAdmin;

  const WaitingScreen({required this.gameCode, required this.isAdmin});

  @override
  _WaitingScreenState createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  AdmobHelper admobHelper = AdmobHelper();
  late Future<List<String>> _playerList;
  String email = '';
  String id = '';
  List<String> selectedPlayers = [];
  final _playerListController = StreamController<List<String>>.broadcast();
  final _selectedPlayersController = StreamController<List<String>>.broadcast();
  late List<dynamic> playersData;
  late StreamSubscription _webSocketSubscription;

  // Music
  AudioPlayer musique = AudioPlayer();

  @override
  void initState() {
    super.initState();

    if (PremiumStatus().isPremium == false) {
      admobHelper.createInterstitialAd().then((_) {
        admobHelper.showInterstitialAd();
      });
    }

    // Connect to WebSocket using WebSocketManager
    initWebSocketConnection();

    _getPref();
    _playerList = getPlayerList(widget.gameCode);
    _initWebSocket();

    initializeMusic();
  }

  initializeMusic() async {
    musique.setSourceAsset('Waiting.mp3');
    musique.setReleaseMode(ReleaseMode.loop);
    double volume = await PreferencesManager.getMusicVolume();
    musique.play(musique.source!, volume: volume);
  }

  Future<void> initWebSocketConnection() async {
    debugPrint("websocket manager init");
    await WebSocketManager.connect(email);
  }

  void _initWebSocket() {
    _webSocketSubscription = WebSocketManager.getStream().listen((message) {
      final Map<String, dynamic> data = jsonDecode(message);
      print('Received message from server: $message');
      if (data['cmd'] == 'getPlayerlist' || data['cmd'] == 'UpdatePlayerlist') {
        if (data['status'] == 'success') {
          playersData = data['players'];
          List<String> players = playersData.map((player) => player.toString()).toList();
          _playerListController.add(players);

          // Envoyer une commande pour obtenir le statut des Seekers après avoir mis à jour la liste des joueurs
          WebSocketManager.sendData('"email":"$email","cmd":"getSeekerStatus", "gameCode":"${widget.gameCode}"');
        } else {
          print('Error in response: ${data['message']}');
        }
      } else if (data['cmd'] == 'partyStartInfo') {
        if (data.containsKey('data') && data['data'].containsKey('center') &&
            data['data'].containsKey('radius')) {
          Map<String, double> centerCoordinates = Map<String, double>.from(
              data['data']['center']);
          LatLng center = LatLng(
              centerCoordinates['lat']!, centerCoordinates['lng']!);
          double radius = (data['data']['radius'] as num).toDouble();
          Map<String, bool> playerList = Map<String, bool>.from(
              data['data']['players']);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) =>
                ClassicMode(
                  center: center,
                  radius: radius,
                  gameDuration : data['data']['duration'],
                  hidingDuration : data['data']['hidingDuration'],
                  timeStamGameStart : data['data']['startingTimeStamp'],
                  gameCode: widget.gameCode,
                  playerList: playerList,
                )),
                (Route<dynamic> route) => false,
          );
        }
      } else if (data['cmd'] == 'playerJoined') {
        _updatePlayerList();
        _updateSelectedPlayersToServer();
      } else if (data['cmd'] == 'seekerStatusUpdated') {
        print('Seeker status updated');
        _handleSeekerStatusUpdated(data['selectedPlayers']);
      } else if (data['cmd'] == 'getSeekerStatus') { // Ajoutez cette ligne
        if (data['status'] == 'success') {
          _handleSeekerStatusUpdated(data['seekers']);
        } else {
          print('Error in response: ${data['message']}');
        }
      }
    });
  }


  void _startGame() {
    if (selectedPlayers.length < 1) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog1(
            title: AppLocalizations.of(context)!.titre_popup_pas_assez_chercheurs,
            content: AppLocalizations.of(context)!.texte_popup_pas_assez_chercheurs,
            buttonText: AppLocalizations.of(context)!.ok,
            onPressed: () {
              Navigator.of(context).pop();
            },
            scaleFactor: MediaQuery.of(context).textScaleFactor,
          );
        },
      );
      return;
    } else if (selectedPlayers.length > (playersData.length - 1)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog1(
            title: AppLocalizations.of(context)!.titre_popup_pas_assez_cacheurs,
            content: AppLocalizations.of(context)!.texte_popup_pas_assez_cacheurs,
            buttonText: AppLocalizations.of(context)!.ok,
            onPressed: () {
              Navigator.of(context).pop();
            },
            scaleFactor: MediaQuery.of(context).textScaleFactor,
          );
        },
      );
      return;
    }

    musique.dispose();
    WebSocketManager.sendData('"email":"$email","cmd":"startGame", "gameCode":"${widget.gameCode}", "startingTimeStamp": ${DateTime.now().millisecondsSinceEpoch}');
  }

  void _handleSeekerStatusUpdated(List<dynamic> selectedPlayersData) {
    List<String> updatedSelectedPlayers = selectedPlayersData.map((player) => player.toString()).toList();
    print('Updated selected players: $updatedSelectedPlayers');
    if (mounted) {
      setState(() {
        selectedPlayers = updatedSelectedPlayers;
      });
      _selectedPlayersController.add(updatedSelectedPlayers);
    }
  }

  void _updatePlayerList() {
    WebSocketManager.sendData('"email":"$email","cmd":"UpdatePlayerlist", "gameCode":"${widget.gameCode}"');
  }

  void _getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email')!;
      id = prefs.getString('id')!;
    });
  }

  void _shareGameCode() {
    Share.share('${AppLocalizations.of(context)!.partagerCodePartieMessage} ${widget.gameCode}');
  }

  Future<List<String>> getPlayerList(String gameCode) async {
    WebSocketManager.sendData('"email":"$email","cmd":"getPlayerlist", "gameCode":"${widget.gameCode}"');
    final data = await WebSocketManager.getStream().first;
    final Map<String, dynamic> decodedData = jsonDecode(data);
    if (decodedData['cmd'] == 'getPlayerlist' && decodedData['status'] == 'success') {
      List<String> players = (decodedData['players'] as List<dynamic>).map((player) => player.toString()).toList();

      // Demande le statut des Seekers après avoir reçu la liste des joueurs
      WebSocketManager.sendData('"email":"$email","cmd":"getSeekerStatus", "gameCode":"${widget.gameCode}"');

      return players;
    } else {
      throw Exception('Failed to load player list');
    }
  }


  void _togglePlayerSelection(String playerName) {
    setState(() {
      if (selectedPlayers.contains(playerName)) {
        selectedPlayers.remove(playerName);
      } else {
        selectedPlayers.add(playerName);
      }
    });

    _updateSelectedPlayersToServer();
  }

  void _updateSelectedPlayersToServer() {
    WebSocketManager.sendData('"email":"$email","cmd":"updateSeekerStatus","gameCode":"${widget.gameCode}", "selectedPlayers": ${jsonEncode(selectedPlayers)}');
  }

  @override
  void dispose() {
    _webSocketSubscription.cancel();
    _playerListController.close();
    _selectedPlayersController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.waitingRoomTitle , style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins',)),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: AdWidget(
              ad: AdmobHelper.getBannerAd()..load(),
              key: UniqueKey(),
            ),
            height: 75
          ),

          const SizedBox(height: 20),

          Center(
            child: Container(
              width: MediaQuery.of(context).size.width - 30,
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width - 30,
                    child: Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.joueurs,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              backgroundColor: Colors.white),
                        ),
                        const Spacer(),
                        Text(
                          AppLocalizations.of(context)!.seekers,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              backgroundColor: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder<List<String>>(
                    stream: _playerListController.stream,
                    initialData: const [],
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return PlayerList(
                            players: snapshot.data!,
                            onTogglePlayer: _togglePlayerSelection,
                            isAdmin: widget.isAdmin,
                            selectedPlayers: selectedPlayers,
                            selectedPlayersStream: _selectedPlayersController.stream);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),

          ElevatedButton(
            onPressed: _shareGameCode,
            style: ElevatedButton.styleFrom(
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius(
                  cornerRadius: 20,
                  cornerSmoothing: 1,
                ),
              ),
              minimumSize: Size(MediaQuery.of(context).size.width - 30, 60),
              backgroundColor: const Color(0xFF5A5C98),
              foregroundColor: const Color(0xFF212348),
            ),
            child: Container(
                width: MediaQuery.of(context).size.width - 80,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.partagerCodePartie + ' : ',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Poppins', color: Colors.white),
                      ),
                      Text(
                        widget.gameCode,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: Colors.white),
                      ),
                    ],
                  ),
                )),
          ),

          const SizedBox(height: 16),

          // Afficher le bouton "Start Game" et les cases à cocher si l'utilisateur est un administrateur
          if (widget.isAdmin)
            ElevatedButton(
              onPressed: _startGame,
              child: Text(
                AppLocalizations.of(context)!.start_game,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.white),
              ),
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
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class PlayerList extends StatelessWidget {
  final List<String> players;
  final Function(String) onTogglePlayer;
  final bool isAdmin;
  final List<String> selectedPlayers;
  final Stream<List<String>> selectedPlayersStream;

  const PlayerList({required this.players, required this.onTogglePlayer, required this.isAdmin, required this.selectedPlayers, required this.selectedPlayersStream});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: players.map((player) => PlayerListItem(playerName: player, onTogglePlayer: onTogglePlayer, isAdmin: isAdmin, isSelectable: isAdmin, selectedPlayers: selectedPlayers, selectedPlayersStream: selectedPlayersStream)).toList(),
    );
  }
}

class PlayerListItem extends StatefulWidget {
  final String playerName;
  final Function(String) onTogglePlayer;
  final bool isAdmin;
  final bool isSelectable;
  final List<String> selectedPlayers;
  final Stream<List<String>> selectedPlayersStream;

  const PlayerListItem({
    required this.playerName,
    required this.onTogglePlayer,
    required this.isAdmin,
    required this.isSelectable,
    required this.selectedPlayers,
    required this.selectedPlayersStream,
    Key? key,
  }) : super(key: key);

  @override
  _PlayerListItemState createState() => _PlayerListItemState();
}

class _PlayerListItemState extends State<PlayerListItem> {
  late bool isChecked;
  late StreamSubscription _selectedPlayersSubscription;

  @override
  void initState() {
    super.initState();
    WebSocketManager.connect('email');
    isChecked = widget.selectedPlayers.contains(widget.playerName);
    _selectedPlayersSubscription =
        widget.selectedPlayersStream.listen((selectedPlayers) {
          setState(() {
            isChecked = selectedPlayers.contains(widget.playerName);
          });
        });
  }

  @override
  void dispose() {
    _selectedPlayersSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          widget.playerName,
          style: const TextStyle(color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',),
        ),
        trailing: Checkbox(
          value: isChecked,
          onChanged: widget.isAdmin ? (value) {
            widget.onTogglePlayer(widget.playerName);
            setState(() {
              isChecked = value!;
              print('Checkbox state updated for ${widget
                  .playerName}: $isChecked');
            });
          } : null,
        ),
      ),
    );
  }
}
