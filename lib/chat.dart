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
  final ScrollController _scrollController = ScrollController();

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
            child : Padding(
              padding: EdgeInsets.all(24.0), // Ajouter un padding sur les bords de l'écran
              child: ListView.builder(
                controller: _scrollController,
                itemCount: chatModel.messages.length,
                itemBuilder: (context, index) {
                  // Récupérer le message, l'email et le nom d'utilisateur de l'utilisateur qui a envoyé le message
                  String message = chatModel.messages[index];
                  String email = chatModel.emails[index];
                  String username = chatModel.usernames[index];

                  // Vérifier si l'email de l'utilisateur actuel est le même que l'email de l'utilisateur qui a envoyé le message
                  bool isCurrentUser = widget.email == email;

                  // Vérifier si l'email de l'utilisateur qui a envoyé le message précédent est le même que l'email actuel
                  bool isNewUser = index == 0 || chatModel.emails[index - 1] != email;

                  // Créer une liste de widgets pour la colonne
                  List<Widget> columnWidgets = [];

                  // Ajouter le nom d'utilisateur uniquement si l'utilisateur actuel n'a pas envoyé le message et si c'est un nouvel utilisateur
                  if (!isCurrentUser && isNewUser) {
                    columnWidgets.add(Text(username + " : ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)));
                  }

                  // Ajouter le message
                  columnWidgets.add(
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 2.0), // Ajouter un padding vertical entre les messages
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isCurrentUser ? Colors.blue : Colors.black87,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(message, style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  );

                  // Retourner un widget Align avec le texte aligné à droite si l'utilisateur actuel a envoyé le message, sinon à gauche
                  return Align(
                    alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: columnWidgets,
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.go,
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
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }));
      _controller.clear();

      // Scroll to bottom
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }
}
