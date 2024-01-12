import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter WebSocket Chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Chat de la Partie'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final channel = IOWebSocketChannel.connect('ws://193.38.250.113:3000');
  final TextEditingController _messageController = TextEditingController();
  final List<Message> messages = [];
  final ScrollController _scrollController = ScrollController();
  final String username = 'Pseudo';

  void scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
    );
  }

  @override
  void initState() {
    super.initState();
    // Écoute les messages WebSocket du serveur
    channel.stream.listen((dynamic message) {
      setState(() {
        if (message is String) {
          // Message texte
          messages.add(Message(text: message, isUser: false, username: 'Server'));
        } else if (message is Map<String, dynamic>) {
          // Message avec informations utilisateur (pseudo + contenu)
          final userMessage = Message(
            text: message['text'],
            isUser: true,
            username: message['username'],
          );
          messages.add(userMessage);
        } else if (message is Uint8List) {
          // Message image
          messages.add(Message(imageBytes: message, isUser: false, username: 'Server'));
        }
      });
      scrollToBottom();
    });
  }

  Future<void> _captureAndSendPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final imageBytes = await testCompressList(await pickedFile.readAsBytes());
      final userPhotoMessage = Message(imageBytes: imageBytes, isUser: true);
      channel.sink.add(imageBytes);

      setState(() {
        messages.add(userPhotoMessage);
      });

      scrollToBottom();
    }
  }

  Future<Uint8List> testCompressList(Uint8List list) async {
    var result = await FlutterImageCompress.compressWithList(
      list,
      minHeight: 1920,
      minWidth: 1080,
      quality: 30,
    );
    print(list.length);
    print(result.length);
    return result;
  }


  void _sendMessage() {
    // Récupère le texte du message
    final messageText = _messageController.text.trim();

    // Vérifie si le message n'est pas vide
    if (messageText.isNotEmpty) {
      // Envoye le message au serveur WebSocket
      final userMessage = Message(text: messageText, isUser: true, username: username);

      setState(() {
        messages.add(userMessage);
      });

      // Fait défiler la liste vers le bas
      scrollToBottom();

      channel.sink.add(utf8.encode(userMessage.text!));
    }

    // Efface le texte du contrôleur
    _messageController.clear();
  }




  @override
  void dispose() {
    // Ferme la connexion WebSocket et le contrôleur de texte lorsque le widget est détruit
    channel.sink.close();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];

                if (message.imageBytes != null) {
                  // Utilisez le widget GestureDetector pour détecter les clics sur l'image
                  return GestureDetector(
                    onTap: () {
                      // Affichez l'image en plein écran
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImage(
                            imageBytes: message.imageBytes!,
                            timestamp: message.timestamp,
                          ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: 'imageHero$index',
                      child: Image.memory(message.imageBytes!),
                    ),
                  );
                } else {
                  return ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: message.isUser ? Colors.blue : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.username ?? '', // Affichez le nom d'utilisateur ici
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                message.text!,
                                style: TextStyle(
                                  color: message.isUser ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          DateFormat.Hm().format(message.timestamp),
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: _captureAndSendPhoto,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final Uint8List imageBytes;
  final DateTime timestamp;

  const FullScreenImage({Key? key, required this.imageBytes, required this.timestamp}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              // Fermez l'image en plein écran lorsqu'on clique dessus
              onTap: () => Navigator.pop(context),
              child: Hero(
                tag: 'imageHero', // Utilisez le même tag qu'à l'écran principal
                child: Image.memory(imageBytes),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              DateFormat.Hm().format(timestamp),
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Message {
  final String? text;
  final Uint8List? imageBytes;
  final bool isUser;
  final DateTime timestamp;
  final String? username;

  Message({this.text, required this.isUser, this.imageBytes, this.username})
      : timestamp = DateTime.now();
}
