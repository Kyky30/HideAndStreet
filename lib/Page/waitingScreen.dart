import 'dart:async';
import 'dart:convert';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:hide_and_street/game_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:share/share.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hide_and_street/monetization/AdmobHelper.dart';
import 'package:hide_and_street/monetization/PremiumStatus.dart';
import '../WebSocketManager.dart';


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
  final _playerListController = StreamController<List<String>>();
  final _selectedPlayersController = StreamController<List<String>>.broadcast();
  late List<dynamic> playersData;

  @override
  void initState() {
    super.initState();

    if (PremiumStatus().isPremium) {
      admobHelper.createInterstitialAd().then((_) {
        admobHelper.showInterstitialAd();
      });
    }

    // Connect to WebSocket using WebSocketManager
    initWebSocketConnection();

    _getPref();
    _playerList = getPlayerList(widget.gameCode);
    _initWebSocket();
  }

  Future<void> initWebSocketConnection() async {
    await WebSocketManager.connect(email);
  }
  void _initWebSocket() {
    WebSocketManager.getStream().listen((message) {
      final Map<String, dynamic> data = jsonDecode(message);
      print('Received message from server: $message');
      if (data['cmd'] == 'getPlayerlist' || data['cmd'] == 'UpdatePlayerlist') {
        if (data['status'] == 'success') {
          playersData = data['players'];
          List<String> players = playersData.map((player) => player.toString()).toList();
          _playerListController.add(players);
        } else {
          print('Error in response: ${data['message']}');
        }
      } else if (data['cmd'] == 'partyStartInfo') {
        if (data.containsKey('data') && data['data'].containsKey('center') &&
            data['data'].containsKey('radius')) {
          // Parse the center and radius values
          Map<String, double> centerCoordinates = Map<String, double>.from(
              data['data']['center']);
          LatLng center = LatLng(
              centerCoordinates['lat']!, centerCoordinates['lng']!);
          double radius = (data['data']['radius'] as num).toDouble();
          print("⛷️⛷️⛷️⛷️⛷️");
          Map<String, bool> playerList = Map<String, bool>.from(
              data['data']['players']);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) =>
                GameMap(
                  center: center,
                  radius: radius,
                  tempsDePartie: data['data']['duration'],
                  tempsDeCachette: data['data']['hidingDuration'],
                  timeStampDebutPartie: data['data']['startingTimeStamp'],
                  gameCode: widget.gameCode,
                  playerList: playerList,
                )),
                (Route<dynamic> route) => false,
          );
        }
      } else if (data['cmd'] == 'playerJoined') {
        _updatePlayerList();
      } else if (data['cmd'] == 'seekerStatusUpdated') {
        print('Seeker status updated');
        _handleSeekerStatusUpdated(data['selectedPlayers']);
      }
    });
  }

  void _startGame() {
    if (selectedPlayers.length < 1) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.titre_popup_pas_assez_chercheurs),
            content: Text(AppLocalizations.of(context)!.texte_popup_pas_assez_chercheurs),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    } else if (selectedPlayers.length > (playersData.length - 1)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.titre_popup_pas_assez_cacheurs),
            content: Text(AppLocalizations.of(context)!.texte_popup_pas_assez_cacheurs),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    String auth = "chatappauthkey231r4";
    WebSocketManager.sendData('"email":"$email","cmd":"startGame", "gameCode":"${widget.gameCode}", "startingTimeStamp": ${DateTime.now().millisecondsSinceEpoch}');
  }

  void _handleSeekerStatusUpdated(List<dynamic> selectedPlayersData) {
    List<String> updatedSelectedPlayers = selectedPlayersData.map((player) => player.toString()).toList();
    print('Updated selected players: $updatedSelectedPlayers');
    setState(() {
      selectedPlayers = updatedSelectedPlayers;
    });
    _selectedPlayersController.add(updatedSelectedPlayers);
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
    final StreamController<List<String>> controller =
    StreamController<List<String>>();

    WebSocketManager.sendData('"email":"$email","cmd":"getPlayerlist", "gameCode":"${widget.gameCode}"');

    return controller.stream.first;
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
    WebSocketManager.closeConnection();
    _playerListController.close();
    _selectedPlayersController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.waitingRoomTitle),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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