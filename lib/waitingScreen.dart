import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


import 'dart:developer' as developer;

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

  @override
  void initState() {
    super.initState();
    _channel = IOWebSocketChannel.connect('wss://app.hideandstreet.furrball.fr/getPlayerlist');
    _getPref();
    _playerList = getPlayerList(widget.gameCode);
  }
  void _getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email')!;
    });
  }
  void _shareGameCode() {
    Share.share('Join my game with code: ${widget.gameCode}');
  }

  Future<List<String>> getPlayerList(String gameCode) async {
    // Send a request to the server
    String auth = "chatappauthkey231r4";
    _channel.sink.add('{"email":"$email","auth":"$auth","cmd":"getPlayerlist", "gameCode":"$gameCode"}');

    // Create a StreamController to handle incoming messages
    final StreamController<List<String>> controller =
    StreamController<List<String>>();

    // Listen for messages from the server
    _channel.stream.listen((message) {
      // Parse the incoming message
      final Map<String, dynamic> data = jsonDecode(message);

      // Handle different types of messages
      if (data['cmd'] == 'getPlayerlist') {
        if (data['status'] == 'success') {
          List<dynamic> playersData = data['players'];
          developer.log(data['players'].toString(), name: 'my.app.category');
          List<String> players =
          playersData.map((player) => player.toString()).toList();
          controller.add(players);
        } else {
          controller.addError(data['message']);
        }
      }
    });

    // Return the stream as a Future
    return controller.stream.first;
  }

  @override
  void dispose() {
    _channel.sink.close();
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
          Text('Game Code: ${widget.gameCode}'),
          ElevatedButton(
            onPressed: _shareGameCode,
            child: Text('Share Game Code'),
          ),
          SizedBox(height: 20),
          Text('Players in the Game:'),
          FutureBuilder<List<String>>(
            future: _playerList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return PlayerList(players: snapshot.data!);
              }
            },
          ),
        ],
      ),
    );
  }
}

class PlayerList extends StatelessWidget {
  final List<String> players;

  PlayerList({required this.players});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: players.map((player) => PlayerListItem(playerName: player)).toList(),
    );
  }
}

class PlayerListItem extends StatelessWidget {
  final String playerName;

  PlayerListItem({required this.playerName});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(playerName),
      // Add checkbox or any other widgets as needed
    );
  }
}
