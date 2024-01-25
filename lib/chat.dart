import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'chatWebSocket.dart';
import 'chat_model.dart';


class Chat extends StatefulWidget {
  final String email;
  final String gameCode;
  final Stream broadcastChannel;

  const Chat({
    Key? key,
    required this.email,
    required this.gameCode,
    required this.broadcastChannel,
  }) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _controller = TextEditingController();
  late final WebSocketChannel _channel;

  @override
  void initState() {
    _channel = WebSocketManager().channel;
    super.initState();
    // N'écoutez pas les messages dans initState, cela sera géré ailleurs
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Utiliser la même instance de WebSocketChannel partagée
  }

  @override
  Widget build(BuildContext context) {
    var chatModel = Provider.of<ChatModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Page'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatModel.messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(chatModel.messages[index]),
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
