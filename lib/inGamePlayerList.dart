import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class inGamePlayerlist extends StatefulWidget {
  final String gameCode;

  const inGamePlayerlist({
    Key? key,
    required this.gameCode,
  }) : super(key: key);

  @override
  State<inGamePlayerlist> createState() => _inGamePlayerlist();
}

class _inGamePlayerlist extends State<inGamePlayerlist> {
  late WebSocketChannel _channel;
  late String email;
  late String userId;

  Map<String, dynamic> playerList = {};

  @override
  void initState() {
    super.initState();
    _getPref().then((_) {
      _channel = IOWebSocketChannel.connect('wss://app.hideandstreet.furrball.fr/getPlayerlist');
      _channel.sink.add('{"cmd":"getInGamePlayerlist","auth":"chatappauthkey231r4", "email":"$email" , "gameCode":"${widget.gameCode}"}');
      _channel.stream.listen((message) {
        setState(() {
          playerList = jsonDecode(message);
        });
      });
    });
  }

  Future<void> _getPref() async {
    print("🔎 Récupération des préférences...");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('email') ?? '';
    userId = prefs.getString('userId') ?? '';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('In Game Player List'),
      ),
      body: ListView.builder(
        itemCount: playerList.length,
        itemBuilder: (context, index) {
          String key = playerList.keys.elementAt(index);
          return ListTile(
            title: Text('Pseudo: $key'),
            subtitle: Text('Seeker: ${playerList[key]['Seeker']}, Found: ${playerList[key]['Found']}'),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}