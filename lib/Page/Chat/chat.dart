
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../WebSocketManager.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:hide_and_street/components/input.dart';
import 'package:hide_and_street/Page/Game/GameUtilities/ModerationUtilities.dart';

import 'chat_model.dart';
import 'chat_controller.dart';


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
  final ScrollController _scrollController = ScrollController();
  final ChatController _chatController = ChatController();
  final ModerationUtilities _moderationUtilities = ModerationUtilities();

  @override
  void initState() {
    super.initState();
    WebSocketManager.connect(widget.email);
    _chatController.connect(widget.email);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var chatModel = Provider.of<ChatModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.titre_page_chat, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600, fontFamily: 'Poppins',)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              // Ajouter un padding sur les bords de l'écran
              child: ListView.builder(
                controller: _scrollController,
                itemCount: chatModel.messages.length,
                itemBuilder: (context, index) {
                  // Récupérer le message, l'email et le nom d'utilisateur de l'utilisateur qui a envoyé le message
                  String email = chatModel.emails[index];
                  String username = chatModel.usernames[index];
                  String message;
                  if (_moderationUtilities.isPlayerHidden(username).toString() == "true"){
                    message = AppLocalizations.of(context)!.message_masque;
                  } else {
                    message = chatModel.messages[index];
                  }

                  // Vérifier si l'email de l'utilisateur actuel est le même que l'email de l'utilisateur qui a envoyé le message
                  bool isCurrentUser = widget.email == email;

                  // Vérifier si l'email de l'utilisateur qui a envoyé le message précédent est le même que l'email actuel
                  bool isNewUser = index == 0 ||
                      chatModel.emails[index - 1] != email;

                  // Créer une liste de widgets pour la colonne
                  List<Widget> columnWidgets = [];

                  // Ajouter le nom d'utilisateur uniquement si l'utilisateur actuel n'a pas envoyé le message et si c'est un nouvel utilisateur
                  if (!isCurrentUser && isNewUser) {
                    columnWidgets.add(
                        Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  _moderationUtilities.openModerationMenu(username, context);
                                },
                                icon: Icon(Symbols.report_rounded, fill: 1, weight: 700, grade: 200, opticalSize: 24, size: 20)
                            ),
                            Text(
                                username + " : ",
                                style: const TextStyle( fontWeight: FontWeight.bold, fontSize: 16)
                            )
                          ],
                        )
                    );
                  }

                  // Ajouter le message
                  columnWidgets.add(
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 2.0),
                      // Ajouter un padding vertical entre les messages
                      padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isCurrentUser ? Color(0xFF373967) : Colors.black87,
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 15,
                            cornerSmoothing: 1,
                          ),
                      ),
                      child: Text(message, style: const TextStyle(
                          color: Colors.white, fontSize: 18, fontFamily: 'Montserrat',)),
                    ),
                  );

                  // Retourner un widget Align avec le texte aligné à droite si l'utilisateur actuel a envoyé le message, sinon à gauche
                  return Align(
                    alignment: isCurrentUser ? Alignment.centerRight : Alignment
                        .centerLeft,
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
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _controller,
                    scaleFactor: MediaQuery.of(context).textScaleFactor,
                    hintText: 'Send a message',
                    fontSize: 15,
                  ),
                ),
                SizedBox(width: 10,),
                IconButton(
                  icon: const Icon(Symbols.send_rounded, fill: 1, weight: 700, grade: 200, opticalSize: 24, size: 40,),
                  onPressed: () {
                    _chatController.sendMessage(widget.email, widget.gameCode, _controller.text, _controller);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 20,
                        cornerSmoothing: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(10),
                    backgroundColor: const Color(0xFF373967),
                    foregroundColor: Colors.white,

                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
