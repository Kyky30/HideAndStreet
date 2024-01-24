import 'dart:typed_data';
import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


// Classe pour gérer le stockage local des messages
class ChatLocalStorage {
  static const String _key = 'chat_messages';
  static const String _welcomeKey = 'welcome_message';

  static Future<void> saveMessages(List<Message> messages) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> messagesJson =
    messages.map((message) => json.encode(message.toJson())).toList();
    prefs.setStringList(_key, messagesJson);
  }

  static Future<List<Message>> loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? messagesJson = prefs.getStringList(_key);
    return messagesJson
        ?.map((jsonString) => Message.fromJson(json.decode(jsonString)))
        .toList() ??
        [];
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
  final int partieId;

  const Chat({Key? key, required this.partieId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat de la Partie'),
      ),
      body: ChatBody(partieId: partieId),
    );
  }
}

class ChatBody extends StatefulWidget {
  final int partieId;

  const ChatBody({Key? key, required this.partieId}) : super(key: key);

  @override
  _ChatBodyState createState() => _ChatBodyState(partieId: partieId);
}

class _ChatBodyState extends State<ChatBody> {
  late IOWebSocketChannel channel;
  final TextEditingController _messageController = TextEditingController();
  final List<Message> messages = [];
  late ScrollController _scrollController;
  late String username;
  final int partieId;
  bool isUserInChat = false;
  bool _isWelcomeMessageDisplayed = false;
  Uint8List? _capturedImage;

  _ChatBodyState({required this.partieId});






  // Fonction pour envoyer des données au serveur WebSocke
  void sendToServer(Map<String, dynamic> data) {
    channel.sink.add(jsonEncode(data));
  }

  /// Fonction pour faire défiler la liste de message
  void scrollToBottom() {
    Future.delayed(Duration(milliseconds: 900), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOut,
      );
      print('Scroll to bottom called');
    });

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  void initState() {

    AwesomeNotifications().isNotificationAllowed().then((isAllowed){
      if(!isAllowed){
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    void fetchUnreadMessages() {
      // Envoie une requête au serveur pour récupérer les messages non lus
      channel.sink.add(jsonEncode({'type': 'getUnreadMessages'}));
    }



    super.initState();


    // Initialiser le canal WebSocket et le contrôleur de défilement
    channel = IOWebSocketChannel.connect('ws://193.38.250.113:3000');
    _scrollController = ScrollController();

    // Récupère le pseudo de l'utilisateur depuis les SharedPreferences
    getUsername().then((userPseudo) {
      if (userPseudo != null) {
        setState(() {
          username = userPseudo;
        });
      }
    });


    // Charge les messages depuis le stockage local lorsque le widget est initialisé
    _loadMessages();

    // Déclenche le défilement vers le bas lors de l'entrée dans le chat
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      scrollToBottom();
    });

    channel.stream.listen((dynamic message) {
      print('Message reçu du serveur : $message');

      setState(() {
        if (message is String) {
          // Message texte
          Map<String, dynamic> decodedMessage = json.decode(message);
          String username = decodedMessage['username'] ?? 'Serveur';
          MessageStatus status = decodedMessage['status'] == 'MessageStatus.sent'
              ? MessageStatus.sent
              : MessageStatus.received;

          messages.add(Message(
            text: decodedMessage['text'],
            username: username,
            status: status,
            timestamp: DateTime.parse(decodedMessage['timestamp'] ?? ''),
            isUser: username != 'Serveur', // Correction ici
          ));
          // Émettre une notification pour le nouveau message
          triggerNotification('Nouveau message', decodedMessage['text']);


        } else if (message is Map<String, dynamic>) {
          // Message avec informations utilisateur (pseudo + contenu)
          print('Message utilisateur reçu : $message');
          String username = message['username'] ?? 'Serveur';
          MessageStatus status = message['status'] == 'MessageStatus.sent'
              ? MessageStatus.sent
              : MessageStatus.received;

          final userMessage = Message(
            text: message['text'],
            username: username,
            status: status,
            timestamp: DateTime.parse(message['timestamp'] ?? ''),
            isUser: username != 'Serveur', // Correction ici
          );
          messages.add(userMessage);

          // Émettre une notification pour le nouveau message
          triggerNotification('Nouveau message', message['text']);
        } else if (message is Uint8List) {
          // Message image
          String username = 'Serveur';
          messages.add(Message(
            imageBytes: message,
            username: username,
            status: MessageStatus.received,
            timestamp: DateTime.now(),
            isUser: username != 'Serveur', // Correction ici
          ));
          // Émettre une notification pour la nouvelle image
          triggerNotification('Nouvelle image', 'Vous avez reçu une nouvelle image');
        }
      });




      // Affiche la liste de messages mise à jour dans la console
      print('Liste de messages mise à jour :');
      messages.forEach((message) => print(message.toJson()));

      // Sauvegarde des messages en local
      _saveMessages();

      // Fait défiler les messages vers le bas
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        scrollToBottom();
      });
    });

// Vérifie si l'utilisateur a déjà vu le message de bienvenue
    ChatLocalStorage.hasSeenWelcomeMessage().then((hasSeenWelcome) {
      if (!hasSeenWelcome && !_isWelcomeMessageDisplayed) {
        setState(() {
          _displayWelcomeMessage();
          _isWelcomeMessageDisplayed = true; // Marque le message comme affiché
        });
      }
    });

  }

  // Fonction pour envoyer un message
  Future<void> _sendMessage() async {
    // Récupère le texte du message
    final messageText = _messageController.text.trim();

    // Vérifie si le message n'est pas vide
    if (messageText.isNotEmpty) {
      // Crée un nouvel objet Message avec la date et l'heure actuelles
      final userMessage = Message(
        text: messageText,
        isUser: true,
        username: username,
        status: MessageStatus.sent,
        timestamp: DateTime.now(),
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
        'status': userMessage.status.toString(),
      };

      print('Envoi du message au serveur : $messageWithTimestamp');
      channel.sink.add(utf8.encode(jsonEncode(messageWithTimestamp)));

      // Marquer le message comme "reçu" immédiatement
      setState(() {
        userMessage.status = MessageStatus.received;
        print('Message marqué comme reçu : ${userMessage.toJson()}');
      });

      // Sauvegarde des messages en local
      _saveMessages();

      // Fait défiler la liste vers le bas
      scrollToBottom();
    } else if (_capturedImage != null) {
      // Cas où une image a été capturée
      final userPhotoMessage = Message(
        imageBytes: _capturedImage,
        isUser: true,
        username: username,
        status: MessageStatus.sent,
      );

      setState(() {
        messages.add(userPhotoMessage);
      });

      // Fait défiler la liste vers le bas
      scrollToBottom();

      // Envoie le message image au serveur WebSocket
      channel.sink.add(_capturedImage!);

      // Marquer le message image comme "reçu" immédiatement
      setState(() {
        userPhotoMessage.status = MessageStatus.received;
        print('Message image marqué comme reçu : ${userPhotoMessage.toJson()}');
      });

      // Sauvegarde des messages en local
      _saveMessages();

      // Fait défiler la liste vers le bas
      scrollToBottom();

      // Réinitialise la variable _capturedImage
      setState(() {
        _capturedImage = null;
      });
    }

    // Efface le texte du contrôleur
    _messageController.clear();
  }



  Future<String?> getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }



  // Charge les messages localement
  Future<void> _loadMessages() async {
    // Load messages from local storage
    List<Message> loadedMessages = await ChatLocalStorage.loadMessages();
    setState(() {
      messages.clear(); // Clear existing message
      messages.addAll(loadedMessages);
    });

    // Scroll messages to the bottom
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      scrollToBottom();
    });
  }

  // Capture et envoie de photo
  Future<void> _captureAndSendPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final imageBytes =
      await testCompressList(await pickedFile.readAsBytes());
      final userPhotoMessage = Message(
        imageBytes: imageBytes,
        isUser: true,
        username: username,
        status: MessageStatus.sent,
      );

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
    final welcomeMessage = Message(
        text: 'Bienvenue dans le chat !',
        isUser: false,
        username: 'Server',
        status: MessageStatus.sent);
    setState(() {
      messages.add(welcomeMessage);
    });

    // Marque le message de bienvenue comme vu
    ChatLocalStorage.markWelcomeMessageSeen();

    // Fait défiler la liste vers le bas
    scrollToBottom();
  }

  // Fonction pour compresser une liste d'octets (image)
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

  // Fonction pour sauvegarder les messages localement
  Future<void> _saveMessages() async {
    // Save messages to local storage
    await ChatLocalStorage.saveMessages(messages);
  }

  // Widget pour afficher l'indicateur de statut des messages
  Widget buildStatusIndicator(MessageStatus status) {
    if (status == MessageStatus.sent) {
      return Icon(
        Icons.done_all,
        color: Colors.grey,
        size: 16.0,
      );
    } else if (status == MessageStatus.received) {
      return Icon(
        Icons.done_all,
        color: Colors.red,
        size: 16.0,
      );
    } else {
      return SizedBox.shrink();
    }
  }


// Nouvelle méthode pour construire l'indicateur de statut pour les images
  Widget buildImageStatusIndicator(MessageStatus status) {
    if (status == MessageStatus.sent) {
      return Icon(
        Icons.done_all,
        color: Colors.grey,
        size: 16.0,
      );
    } else if (status == MessageStatus.received) {
      return Icon(
        Icons.done_all,
        color: Colors.red,
        size: 16.0,
      );
    } else {
      return SizedBox.shrink();
    }
  }

// Widget pour construire l'élément d'affichage d'un message
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
            mainAxisAlignment: message.isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(left: message.isUser ? 0.0 : 20.0,
                    right: message.isUser ? 20.0 : 0.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: message.isUser ? Colors.blue : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.username ?? '', // Utilisez senderUsername
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: SizedBox(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.6,
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
                    buildImageStatusIndicator(message.status), // Utilisation de la nouvelle méthode
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Partie du code pour les messages texte
      return ListTile(
        title: Column(
          crossAxisAlignment: username == message.username
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: username == message.username ? 20.0 : 1.0,
                  right: username == message.username ? 1.0 : 20.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: username == message.username ? Colors.blue : Colors.grey[200],
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
                      color: username == message.username ? Colors.white : Colors.black,
                    ),
                  ),
                  buildStatusIndicator(message.status),
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



  // Fonction de nettoyage lorsque le widget est détruit
  @override
  void dispose() {
    // Ferme la connexion WebSocket et le contrôleur de texte lorsque le widget est détruit
    channel.sink.close();
    _messageController.dispose();
    super.dispose();
  }


  void triggerNotification(String title, String body) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel',
        title: title,
        body: body,
      ),
    );
  }

  // Construction de l'interface utilisateur pour l'écran de chat
  @override
  Widget build(BuildContext context) {
    print('Building chat screen...');
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

// Widget pour afficher une image en plein écran
class FullScreenImage extends StatelessWidget {
  final Uint8List imageBytes;
  final DateTime timestamp;

  const FullScreenImage(
      {Key? key, required this.imageBytes, required this.timestamp})
      : super(key: key);

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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _saveImageToGallery(context),
        tooltip: 'Save to Gallery',
        child: Icon(Icons.download),
      ),
    );
  }

  Future<void> _saveImageToGallery(BuildContext context) async {
    try {
      // Obtenir le répertoire temporaire pour stocker l'image
      final tempDir = await getTemporaryDirectory();
      final tempPath = tempDir.path;

      // Écrire l'image dans le répertoire temporaire
      final tempFile = File('$tempPath/${timestamp.toIso8601String()}.png');
      await tempFile.writeAsBytes(imageBytes);

      // Sauvegarder l'image dans la galerie
      final result = await ImageGallerySaver.saveFile(tempFile.path);

      // Afficher un message à l'utilisateur en fonction du résultat
      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image saved to gallery'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save image to gallery'),
          ),
        );
      }
    } catch (e) {
      print('Error saving image to gallery: $e');
    }
  }
}

enum MessageStatus {
  sent,
  received,
}

class Message {
  final String? text;
  final Uint8List? imageBytes;
  final bool isUser;
  final DateTime timestamp;
  final String? username;
  MessageStatus status;

  Message({
    this.text,
    required this.isUser,
    this.imageBytes,
    this.username,
    required this.status,
    DateTime? timestamp, // Ajout de la déclaration ici
  }) : timestamp = timestamp ?? DateTime
      .now(); // Initialisation avec la valeur actuelle si elle est nulle

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'imageBytes': imageBytes,
      'username': username,
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString(), // Ajoutez cette ligne
    };
  }


  factory Message.fromJson(Map<String, dynamic> json) {
    List<int>? imageBytesList = json['imageBytes']?.cast<int>();
    Uint8List? imageBytes = imageBytesList != null ? Uint8List.fromList(
        imageBytesList) : null;

    return Message(
      text: json['text'],
      isUser: json['isUser'],
      imageBytes: imageBytes,
      username: json['username'],
      status: json['status'] == 'MessageStatus.sent'
          ? MessageStatus.sent
          : MessageStatus.received,
      timestamp: DateTime.parse(json['timestamp'] ?? ''),
    );
  }
}