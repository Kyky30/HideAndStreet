// chat.dart
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatLocalStorage {
  static const String _key = 'chat_messages';
  static const String _welcomeKey = 'welcome_message';

  static Future<void> saveMessages(List<Message> messages) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> messagesJson = messages.map((message) => json.encode(message.toJson())).toList();
    prefs.setStringList(_key, messagesJson);
  }

  static Future<List<Message>> loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? messagesJson = prefs.getStringList(_key);
    return messagesJson?.map((jsonString) => Message.fromJson(json.decode(jsonString))).toList() ?? [];
  }

  static Future<void> clearMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(_key);
  }

  static Future<bool> hasSeenWelcomeMessage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_welcomeKey) ?? false;
  }

  static Future<void> markWelcomeMessageSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_welcomeKey, true);
  }
}

class Chat extends StatelessWidget {
  const Chat({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat de la Partie'),
      ),
      body: ChatBody(),
    );
  }
}

class ChatBody extends StatefulWidget {
  const ChatBody({Key? key}) : super(key: key);

  @override
  _ChatBodyState createState() => _ChatBodyState();
}

class _ChatBodyState extends State<ChatBody> {
  final channel = IOWebSocketChannel.connect('ws://193.38.250.113:3000');
  final TextEditingController _messageController = TextEditingController();
  final List<Message> messages = [];
  final ScrollController _scrollController = ScrollController();
  final String username = 'Pseudo';
  bool _isWelcomeMessageDisplayed = false;

  void scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Vérifie si l'utilisateur a déjà vu le message de bienvenue
    ChatLocalStorage.hasSeenWelcomeMessage().then((hasSeenWelcome) {
      if (!hasSeenWelcome && !_isWelcomeMessageDisplayed) {
        _displayWelcomeMessage();
        _isWelcomeMessageDisplayed = true; // Marque le message comme affiché
      }
    });
  }

  @override
  void initState() {
    super.initState();

    // Charge les messages sauvegardés
    _loadMessages();

    // Écoute les messages WebSocket du serveur
    channel.stream.listen((dynamic message) {
      setState(() {
        // Gestion des différents types de messages...
      });

      // Fait défiler les messages vers le bas
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        scrollToBottom();
      });
    });
  }

  Future<void> _loadMessages() async {
    List<Message> loadedMessages = await ChatLocalStorage.loadMessages();
    setState(() {
      messages.addAll(loadedMessages);
    });
    scrollToBottom();
  }

  Future<void> _captureAndSendPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final imageBytes = await testCompressList(await pickedFile.readAsBytes());
      final userPhotoMessage = Message(imageBytes: imageBytes, isUser: true, username: username);

      channel.sink.add(imageBytes);

      setState(() {
        messages.add(userPhotoMessage);
      });

      scrollToBottom();

      _saveMessages();
    }
  }

  void _displayWelcomeMessage() {
    // Affiche le message de bienvenue
    final welcomeMessage = Message(text: 'Bienvenue dans le chat !', isUser: false, username: 'Server');
    setState(() {
      messages.add(welcomeMessage);
    });

    // Marque le message de bienvenue comme vu
    ChatLocalStorage.markWelcomeMessageSeen();

    // Fait défiler la liste vers le bas
    scrollToBottom();
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
      // Crée un nouvel objet Message avec la date et l'heure actuelles
      final userMessage = Message(
        text: messageText,
        isUser: true,
        username: username,
        timestamp: DateTime.now(), // Ajoutez cette ligne
      );

      setState(() {
        messages.add(userMessage);
      });

      // Fait défiler la liste vers le bas
      scrollToBottom();

      // Envoie le message au serveur WebSocket
      final messageWithTimestamp = {
        'text': messageText,
        'isUser': true,
        'username': username,
        'timestamp': userMessage.timestamp.toIso8601String(),
      };

      channel.sink.add(utf8.encode(jsonEncode(messageWithTimestamp)));

      _saveMessages();
    }

    // Efface le texte du contrôleur
    _messageController.clear();
  }

  Future<void> _saveMessages() async {
    await ChatLocalStorage.saveMessages(messages);
  }

  Widget buildMessageWidget(Message message) {
    if (message.imageBytes != null) {
      return GestureDetector(
        onTap: () {
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(left: message.isUser ? 0.0 : 20.0, right: message.isUser ? 20.0 : 0.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: message.isUser ? Colors.blue : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.username ?? '',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: Hero(
                          tag: 'image_${message.timestamp}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.memory(
                              message.imageBytes!,
                            ),
                          ),
                        ),
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
              ),
            ],
          ),
        ),
      );
    } else {
      // Le reste du code pour les messages texte
      return ListTile(
        title: Column(
          crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: message.isUser ? 20.0 : 1.0, right: message.isUser ? 1.0 : 20.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.username ?? '',
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
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                DateFormat.Hm().format(message.timestamp),
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12.0,
                ),
              ),
            ),
          ],
        ),
      );
    }
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
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return buildMessageWidget(message);
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
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: PhotoView(
            imageProvider: MemoryImage(imageBytes),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            backgroundDecoration: BoxDecoration(
              color: Colors.transparent,
            ),
          ),
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

  Message({
    this.text,
    required this.isUser,
    this.imageBytes,
    this.username,
    DateTime? timestamp, // Mettez à jour ici
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'imageBytes': imageBytes,
      'username': username,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['text'],
      isUser: json['isUser'],
      imageBytes: json['imageBytes'],
      username: json['username'],
      timestamp: DateTime.parse(json['timestamp'] ?? ''),
    );
  }
}
