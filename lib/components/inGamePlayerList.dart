import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class inGamePlayerlist extends StatefulWidget {
  final String gameCode;

  const inGamePlayerlist({required this.gameCode});

  @override
  _inGamePlayerlist createState() => _inGamePlayerlist();
}

class _inGamePlayerlist extends State<inGamePlayerlist> {
  late WebSocketChannel _channel;
  String email = '';
  final _playerListController = StreamController<List<dynamic>>();

  @override
  void initState() {
    super.initState();
    _channel = IOWebSocketChannel.connect(
        'wss://app.hideandstreet.furrball.fr/getInGamePlayerlist');
    _getPref();
    _initWebSocket();
  }

  void _initWebSocket() {
    _channel.stream.listen((message) {
      print('📥 Received message: $message'); // Print incoming message
      final Map<String, dynamic> data = jsonDecode(message);
      if (data['cmd'] == 'returnPlayerList') {
        print(
            '🎉 Success! Players data: ${data['players']}'); // Print success message and players data
        _playerListController.add(data['players']);
      }
    });
    print('📤 Sending request to server...'); // Print outgoing message
    _channel.sink.add(
        '{"email":"$email","auth":"chatappauthkey231r4","cmd":"getInGamePlayerlist", "gameCode":"${widget
            .gameCode}"}');
  }

  void _getPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email')!;
    });
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
        title: const Text('In-Game Player List'),
      ),
      body: StreamBuilder<List<dynamic>>(
        stream: _playerListController.stream,
        initialData: const [],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            var data = snapshot.data ?? [];
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                var player = data[index];
                return Card(
                  child: ListTile(
                    leading: Icon(
                        player['seeker'] ? Symbols.search_rounded : Symbols.person_rounded,
                        fill: 1,
                        weight: 700,
                        grade: 200,
                        opticalSize: 24,
                        color: player['found'] ? Colors.red : Colors.blue,
                    ),
                    title: Text(player['username'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                    subtitle: Text(player['seeker'] ? AppLocalizations.of(context)!.seekers : (player['found'] ? AppLocalizations.of(context)!.etat_trouve : AppLocalizations.of(context)!.etat_non_trouve), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, fontFamily: 'Poppins')),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}