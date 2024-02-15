import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:hide_and_street/waitingScreen.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';


// ... (imports restants)

class RoomCreationPage extends StatefulWidget {
  final LatLng initialTapPosition;
  final double initialRadius;

  const RoomCreationPage({
    required this.initialTapPosition,
    required this.initialRadius,
  });

  @override
  _RoomCreationPageState createState() => _RoomCreationPageState();
}

class _RoomCreationPageState extends State<RoomCreationPage> {
  PageController _pageController = PageController(initialPage: 0);
  late IOWebSocketChannel channel;
  String creatorId = '';
  String email = '';

  double getScaleFactor(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    return mediaQueryData.textScaleFactor;
  }

  @override
  void initState() {
    super.initState();
    getCreatorId();
    // Établir la connexion WebSocket sécurisée
    channel = IOWebSocketChannel.connect('wss://app.hideandstreet.furrball.fr/createGame');
  }

  void _createGame() async {
    double initialRadius = widget.initialRadius;
    LatLng initialTapPosition = widget.initialTapPosition;

    // Logique pour créer la partie et envoyer des données via WebSocket sécurisé
    String auth = "chatappauthkey231r4";

    // Create a Completer to await the game code response
    Completer<String?> gameCodeCompleter = Completer<String?>();

    // Declare the StreamSubscription as nullable
    StreamSubscription<dynamic>? streamSubscription;

    // Add a listener to the WebSocket stream to handle incoming messages
    streamSubscription = channel.stream.listen(
          (message) {
        // Parse the incoming message as JSON
        Map<String, dynamic> data = json.decode(message);

        // Check if the received message contains the game code
        if (data.containsKey('gameCode')) {
          String receivedGameCode = data['gameCode'];

          // Complete the Completer with the received game code
          gameCodeCompleter.complete(receivedGameCode);

          // Cancel the stream subscription as we have received the game code
          streamSubscription?.cancel();
        }
      },
      onError: (error) {
        print("❓ WebSocket error: $error");

        // Complete the Completer with an error
        gameCodeCompleter.completeError(error);

        // Cancel the stream subscription in case of an error
        streamSubscription?.cancel();
      },
      onDone: () {
        print('❌ WebSocket connection closed');
      },
    );

    // Send the game creation command to the server
    channel.sink.add('{"email":"$email","auth":"$auth","cmd":"createGame","radius": "$initialRadius", "creatorId": "$creatorId", "center": {"lat": ${initialTapPosition.latitude}, "lng": ${initialTapPosition.longitude}}, "duration": $dureePartie, "hidingDuration": "$dureeCachette"}');

    try {
      // Wait for the game code response or an error
      String? receivedGameCode = await gameCodeCompleter.future;

      // Check if the game code is not null before navigating
      if (receivedGameCode != null) {
        // Redirect to the waiting screen with the received game code
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WaitingScreen(gameCode: receivedGameCode, isAdmin: true),
          ),
        );
      } else {
        // Handle the case where the game code is null (error scenario)
        // You can show an error message or take appropriate action
        print('🤳 Game code is null');
      }
    } catch (error) {
      // Handle errors thrown during the waiting process
      // You can show an error message or take appropriate action
      print('Error waiting for game code: $error');
    }
  }

  void getCreatorId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      creatorId = prefs.getString('userId') ?? ''; // Utilisez la clé correcte
      email = prefs.getString('email') ?? '';
    });
  }

  @override
  void dispose() {
    // Fermer la connexion WebSocket lorsque le widget est détruit
    channel.sink.close();
    super.dispose();
  }

  int dureePartie = 0;
  int dureeCachette = 0;

  List<GlobalKey<FormFieldState<String>>> dureeKey = [GlobalKey<FormFieldState<String>>()];
  List<GlobalKey<FormFieldState<String>>> dureeCachetteKey = [GlobalKey<FormFieldState<String>>()];

  List<RoomCreationStep> _steps(BuildContext context) => [
    RoomCreationStep(
      title: AppLocalizations.of(context)!.titre_conf_duree,
      background: 'assets/background_white.jpg',
      buttonText: AppLocalizations.of(context)!.confirmer,
      logo: 'assets/logo_connect.png',
      fields: [
        RoomCreationField(label: AppLocalizations.of(context)!.champ_conf_duree, hint: AppLocalizations.of(context)!.texte_champ_conf_duree, key: dureeKey[0], keyboardType: TextInputType.number),
      ],
      onTap: () {
        var duree = dureeKey[0].currentState?.value ?? "";
        if (duree.isEmpty) {
          _showEmptyFieldDialog(context);
        } else {
          dureePartie = int.parse(duree);
          print(dureePartie);
          _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        }
      },
    ),
    RoomCreationStep(
      title: AppLocalizations.of(context)!.titre_conf_duree_cachette,
      background: 'assets/background_white.jpg',
      buttonText: AppLocalizations.of(context)!.confirmer,
      logo: 'assets/logo_connect.png',
      fields: [
        RoomCreationField(label: AppLocalizations.of(context)!.champ_conf_duree_cachette, hint: AppLocalizations.of(context)!.texte_champ_conf_duree_cachette, key: dureeCachetteKey[0], keyboardType: TextInputType.number),
      ],
      onTap: () {
        var dureeCach = dureeCachetteKey[0].currentState?.value ?? "";
        if (dureeCach.isEmpty) {
          _showEmptyFieldDialog(context);
        } else {
          dureeCachette = int.parse(dureeCach);
          print(dureeCachette);
          _createGame();
          _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        }
      },
    ),
  ];

  Widget build(BuildContext context) {
    final scaleFactor = getScaleFactor(context);

    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: _steps(context).length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return _buildStepPage(_steps(context)[index], scaleFactor);
        },
      ),
    );
  }

  Widget _buildStepPage(RoomCreationStep step, double scaleFactor) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          Image.asset(
            step.background,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.fromLTRB(15 * scaleFactor, 75 * scaleFactor, 15 * scaleFactor, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    step.logo,
                    width: MediaQuery.of(context).size.width - 150 * scaleFactor,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0 * scaleFactor),
                    child: Text(
                      step.title,
                      style: TextStyle(fontSize: 24.0 * scaleFactor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  for (var field in step.fields)
                    Padding(
                      padding: EdgeInsets.all(16.0 * scaleFactor),
                      child: TextFormField(
                        key: field.key,
                        keyboardType: field.keyboardType,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[300],
                          hintText: field.hint,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(20.0 * scaleFactor),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20 * scaleFactor,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.all(16.0 * scaleFactor),
              child: ElevatedButton(
                onPressed: () {
                  if (step.onTap != null) {
                    step.onTap!();
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 20 * scaleFactor,
                      cornerSmoothing: 1,
                    ),
                  ),
                  minimumSize: Size(double.infinity, 80 * scaleFactor),
                  backgroundColor: const Color(0xFF373967),
                  foregroundColor: const Color(0xFF212348),
                ),
                child: Text(
                  step.buttonText,
                  style: TextStyle(fontSize: 20 * scaleFactor, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEmptyFieldDialog(BuildContext context) {
    print("🚫 Champ vide");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.titre_popup_champ_vide),
          content: Text(AppLocalizations.of(context)!.texte_popup_champ_vide),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}

class RoomCreationStep {
  final String title;
  final String background;
  final String buttonText;
  final String logo;
  final List<RoomCreationField> fields;
  final VoidCallback? onTap;

  RoomCreationStep({
    required this.title,
    required this.background,
    required this.buttonText,
    required this.logo,
    this.fields = const [],
    this.onTap,
  });
}

class RoomCreationField {
  final String label;
  final String? hint;
  final GlobalKey<FormFieldState<String>>? key;
  final TextInputType? keyboardType; // Add this property for keyboard type

  RoomCreationField({
    required this.label,
    this.hint,
    this.key,
    this.keyboardType = TextInputType.text, // Set the default keyboard type to text
  });
}



