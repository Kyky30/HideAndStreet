import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:figma_squircle/figma_squircle.dart';

class WaitingScreen extends StatefulWidget {
  final String gameCode;

  WaitingScreen({required this.gameCode});

  @override
  _WaitingScreenState createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  late WebSocketChannel _channel;
  late Future<List<String>> _playerList;
  String email = '';
  List<String> selectedPlayers = [];
  final _playerListController = StreamController<List<String>>();

  @override
  void initState() {
    super.initState();
    _channel = IOWebSocketChannel.connect('wss://app.hideandstreet.furrball.fr/getPlayerlist');
    _getPref();
    _playerList = getPlayerList(widget.gameCode);
    _initWebSocket();
  }

  void _initWebSocket() {
    _channel.stream.listen((message) {
      final Map<String, dynamic> data = jsonDecode(message);
      print('Received message from server: $message'); // Ajoutez cette ligne pour journaliser le message

      if (data['cmd'] == 'getPlayerlist') {
        if (data['status'] == 'success') {
          List<dynamic> playersData = data['players'];
          List<String> players =
          playersData.map((player) => player.toString()).toList();
          _playerListController.add(players);
        } else {
          // Gérer les erreurs ici
          print('Error in response: ${data['message']}'); // Ajoutez cette ligne pour journaliser l'erreur
        }
      } else if (data['cmd'] == 'playerJoined') {
        // Gérer la notification de joueur rejoint ici
        // Vous pouvez mettre à jour la liste des joueurs à ce stade
        _updatePlayerList();
      }
    });
  }

  void _updatePlayerList() {
    // Envoyez une nouvelle demande pour obtenir la liste des joueurs mise à jour
    _channel.sink.add('{"email":"$email","auth":"chatappauthkey231r4","cmd":"getPlayerlist", "gameCode":"${widget.gameCode}"}');
  }

  void _getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email')!;
    });
  }

  void _shareGameCode() {
    Share.share('${AppLocalizations.of(context)!.partagerCodePartieMessage} ${widget.gameCode}');
  }

  Future<List<String>> getPlayerList(String gameCode) async {
    final StreamController<List<String>> controller =
    StreamController<List<String>>();

    _channel.sink.add('{"email":"$email","auth":"chatappauthkey231r4","cmd":"getPlayerlist", "gameCode":"${widget.gameCode}"}');

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
  }

  void _startGame() {
    // Envoyer la liste des joueurs sélectionnés au serveur avec la commande 'startGame'
    String auth = "chatappauthkey231r4";
    _channel.sink.add('{"email":"$email","auth":"$auth","cmd":"startGame", "selectedPlayers": ${jsonEncode(selectedPlayers)}}');
  }

  @override
  void dispose() {
    _channel.sink.close();
    _playerListController.close();
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
          Text(
            AppLocalizations.of(context)!.game_code(widget.gameCode),
            style: const TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.w600, fontFamily: 'Poppins', backgroundColor: Colors.white),
          ),
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
            child: Text(
                AppLocalizations.of(context)!.partagerCodePartie,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.white),
            ),
          ),
          Spacer(),
          Text(
              AppLocalizations.of(context)!.listeDesJoueurs,
              style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins', backgroundColor: Colors.white),

          ),
          StreamBuilder<List<String>>(
            stream: _playerListController.stream,
            initialData: [],
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return PlayerList(players: snapshot.data!, onTogglePlayer: _togglePlayerSelection);
              }
            },
          ),
          Spacer(),
          ElevatedButton(
            onPressed: _startGame,
            child: Text(
                AppLocalizations.of(context)!.start_game,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.white),

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
        ],
      ),
    );
  }
}

class PlayerList extends StatelessWidget {
  final List<String> players;
  final Function(String) onTogglePlayer;

  PlayerList({required this.players, required this.onTogglePlayer});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: players.map((player) => PlayerListItem(playerName: player, onTogglePlayer: onTogglePlayer)).toList(),
    );
  }
}

class PlayerListItem extends StatefulWidget {
  final String playerName;
  final Function(String) onTogglePlayer;

  PlayerListItem({required this.playerName, required this.onTogglePlayer, Key? key})
      : super(key: key);

  @override
  _PlayerListItemState createState() => _PlayerListItemState();
}

class _PlayerListItemState extends State<PlayerListItem> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        widget.playerName,
        style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Poppins', backgroundColor: Colors.white),

      ),
      trailing: Checkbox(
        value: isChecked,
        onChanged: (value) {
          widget.onTogglePlayer(widget.playerName);
          setState(() {
            isChecked = value!;
          });
        },
      ),
    );
  }
}
