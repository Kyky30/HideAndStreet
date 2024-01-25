import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class Chat extends StatefulWidget {
  @override
  final email;
  final gameCode;
  final Stream broadcastStream;


  const Chat({super.key, this.email, this.gameCode, required this.broadcastStream});
  _Chat createState() => _Chat();
}

class _Chat extends State<Chat> {
  final TextEditingController _controller = TextEditingController();
  final WebSocketChannel _channel = IOWebSocketChannel.connect('wss://app.hideandstreet.furrball.fr/getPlayerlist');
  final List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    widget.broadcastStream.listen((message) {
      print("🎈🥳 Message received: $message");
      final Map<String, dynamic> data = jsonDecode(message);
      if (data['cmd'] == 'ReceiveMessage') {
        setState(() {
          _messages.add(data['message']);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Page'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'Send a message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      _channel.sink.add(jsonEncode({
        'email': widget.email,
        'auth': 'chatappauthkey231r4',
        'gameCode' : widget.gameCode,
        'cmd': 'sendMessage',
        'message': _controller.text,
        'username': widget.email,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }));
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}