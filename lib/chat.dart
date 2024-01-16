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

class Chat extends StatelessWidget {
  final String partieId;
  const Chat({Key? key, required this.partieId});

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
  final String partieId;
  const ChatBody({Key? key,required this.partieId}) : super(key: key);

  @override
  _ChatBodyState createState() => _ChatBodyState(partieId: partieId);
}

class _ChatBodyState extends State<ChatBody> {
  final channel = IOWebSocketChannel.connect('ws://193.38.250.113:3000');
  final TextEditingController _messageController = TextEditingController();
  final List<Message> messages = [];
  final ScrollController _scrollController = ScrollController();
  final String username = 'Pseudo';
  final String partieId;

  _ChatBodyState({required this.partieId});

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
    channel.sink.add(jsonEncode({'partie': partieId}));
    channel.stream.listen((dynamic message) {
      setState(() {
        if (message is String) {
          //Message texte
          messages.add(Message(text: message, isUser: false, username: 'Server', status: MessageStatus.received));
        } else if (message is Map<String, dynamic>) {
          //Message avec info
          final userMessage = Message(
            text: message['text'],
            isUser: true,
            username: message['username'],
            status: MessageStatus.received,
          );
          messages.add(userMessage);
        } else if (message is Uint8List) {
          messages.add(Message(imageBytes: message, isUser: false, username: 'Server', status: MessageStatus.received));
        }
      });

      WidgetsBinding.instance?.addPostFrameCallback((_) {
        scrollToBottom();
      });
    });
  }

  Future<void> _captureAndSendPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final imageBytes = await testCompressList(await pickedFile.readAsBytes());
      final userPhotoMessage = Message(imageBytes: imageBytes, isUser: true, username: username, status: MessageStatus.sent);


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
    final messageText = _messageController.text.trim();

    if (messageText.isNotEmpty) {
      final userMessage = Message(text: messageText, isUser: true, username: username, status: MessageStatus.sent);

      setState(() {
        messages.add(userMessage);
      });

      scrollToBottom();

      channel.sink.add(utf8.encode(userMessage.text!));

      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          userMessage.status = MessageStatus.received;
        });
      });
    }

    _messageController.clear();
  }

  Widget buildStatusIndicator(MessageStatus status) {
    if (status == MessageStatus.sent) {
      return Icon(
        Icons.check,
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
                    buildStatusIndicator(message.status),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
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

  @override
  void dispose() {
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

  Message({this.text, required this.isUser, this.imageBytes, this.username, required this.status})
      : timestamp = DateTime.now();
}
