import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class inGamePlayerlist extends StatefulWidget {
  final String gameCode;

  inGamePlayerlist({required this.gameCode});

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
    _channel = IOWebSocketChannel.connect('wss://app.hideandstreet.furrball.fr/getInGamePlayerlist');
    _getPref();
    _initWebSocket();
  }

  void _initWebSocket() {
    _channel.stream.listen((message) {
      print('📥 Received message: $message'); // Print incoming message
      final Map<String, dynamic> data = jsonDecode(message);
      if (data['cmd'] == 'returnPlayerList') {
          print('🎉 Success! Players data: ${data['players']}'); // Print success message and players data
          _playerListController.add(data['players']);
      }
    });
    print('📤 Sending request to server...'); // Print outgoing message
    _channel.sink.add('{"email":"$email","auth":"chatappauthkey231r4","cmd":"getInGamePlayerlist", "gameCode":"${widget.gameCode}"}');
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
        title: Text('In-Game Player List'),
      ),
      body: StreamBuilder<List<dynamic>>(
        stream: _playerListController.stream,
        initialData: [],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child : CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var player = snapshot.data![index];
                return Hero(
                  tag: 'playerItem$index',
                  child: ListTile(
                    title: Text('Username: ${player['username']}'),
                    subtitle: Text('Seeker: ${player['seeker']}, Found: ${player['found']}'),
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