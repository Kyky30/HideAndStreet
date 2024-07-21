import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:HideAndStreet/Page/waitingScreen.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../WebSocketManager.dart';
import '../components/alertbox.dart';
import '../components/buttons.dart';
import '../components/input.dart';

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
    WebSocketManager.connect(email); // Establish WebSocket connection

    // Listen for changes in the text fields
    dureePartieController.addListener(() {
      dureePartie = int.parse(dureePartieController.text);
    });

    dureeCachetteController.addListener(() {
      dureeCachette = int.parse(dureeCachetteController.text);
    });
  }

  void _createGame() async {
    double initialRadius = widget.initialRadius;
    LatLng initialTapPosition = widget.initialTapPosition;

    String data = '"email":"$email","cmd":"createGame","radius": "$initialRadius", "creatorId": "$creatorId", "center": {"lat": ${initialTapPosition.latitude}, "lng": ${initialTapPosition.longitude}}, "duration": $dureePartie, "hidingDuration": "$dureeCachette"';

    try {
      // Send data to server using WebSocketManager
      await WebSocketManager.sendData(data);

      // Listen to WebSocketManager stream for responses
      WebSocketManager.getStream().listen((message) {
        if (!mounted) return; // Check if the widget is still mounted
        Map<String, dynamic> data = json.decode(message);

        // Check if the received message contains the game code
        if (data.containsKey('gameCode')) {
          String receivedGameCode = data['gameCode'];

          // Redirect to the waiting screen with the received game code
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WaitingScreen(gameCode: receivedGameCode, isAdmin: true),
            ),
          );
        }
      });
    } catch (error) {
      print('Error sending data: $error');
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return CustomAlertDialog1(
              title: AppLocalizations.of(context)!.erreur,
              content: AppLocalizations.of(context)!.erreurconnexion,
              buttonText: AppLocalizations.of(context)!.ok,
              onPressed: () {
                Navigator.of(context).pop();
              },
              scaleFactor: MediaQuery.of(context).textScaleFactor,
            );
          },
        );
      }
      // Handle error sending data
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
    _pageController.dispose();
    super.dispose();
  }

  int dureePartie = 0;
  int dureeCachette = 0;

  // Declare the controllers for the email and password fields
  final TextEditingController dureePartieController = TextEditingController();
  final TextEditingController dureeCachetteController = TextEditingController();

  List<RoomCreationStep> _steps(BuildContext context) => [
    RoomCreationStep(
      title: AppLocalizations.of(context)!.timer_chasse,
      background: 'assets/background_white.jpg',
      buttonText: AppLocalizations.of(context)!.confirmer,
      logo: 'assets/logo_connect.png',
      fields: [
        RoomCreationField(
          label: AppLocalizations.of(context)!.champ_conf_duree,
          hint: AppLocalizations.of(context)!.texte_champ_conf_duree,
          controller: dureePartieController,
          keyboardType: TextInputType.number,
        ),
      ],
      onTap: () {
        if (dureePartieController.text.isEmpty) {
          _showEmptyFieldDialog(context);
        } else {
          try {
            int duree = int.parse(dureePartieController.text);
            if (duree <= 0) {
              _showZeroFieldDialog(context);
            } else if(duree > 120) {
              _show2hourFieldDialog(context);
            }
            else {
              dureePartie = duree;
              print(dureePartie);
              _pageController.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut);
            }
          } catch (e) {
            _showInvalidFieldDialog(context);
          }
        }
      },
    ),
    RoomCreationStep(
      title: AppLocalizations.of(context)!.timer_cachette,
      background: 'assets/background_white.jpg',
      buttonText: AppLocalizations.of(context)!.confirmer,
      logo: 'assets/logo_connect.png',
      fields: [
        RoomCreationField(
          label: AppLocalizations.of(context)!.champ_conf_duree_cachette,
          hint: AppLocalizations.of(context)!.texte_champ_conf_duree_cachette,
          controller: dureeCachetteController,
          keyboardType: TextInputType.number, // Modifiez cette ligne
        ),
      ],
        onTap: () {
          if (dureeCachetteController.text.isEmpty) {
            _showEmptyFieldDialog(context);
          } else {
            try {
              int duree = int.parse(dureeCachetteController.text);
              if (duree < 0) {
                _shownegFieldDialog(context);
              } else if (duree > 120) {
                _show2hourFieldDialog(context);
              } else {
                dureeCachette = duree;
                print(dureeCachette);
                _createGame();
                _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut);
              }
            } catch (e) {
              _showInvalidFieldDialog(context);
            }
          }
        }

    ),
  ];

  Widget build(BuildContext context) {
    final scaleFactor = getScaleFactor(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: _steps(context).length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return _buildStepPage(_steps(context)[index], scaleFactor, screenWidth);
        },
      ),
    );
  }

  Widget _buildStepPage(RoomCreationStep step, double scaleFactor, double screenWidth) {
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
                  AutoSizeText(
                      step.title,
                      minFontSize: 20,
                      maxFontSize: 24,
                      maxLines: 1,
                      style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                    ),
                  for (var field in step.fields)
                    Padding(
                      padding: EdgeInsets.all(16.0 * scaleFactor),
                      child: CustomTextField(
                        controller: field.controller,
                        keyboardType: field.keyboardType,
                        hintText: field.hint,
                        scaleFactor: scaleFactor,
                        maxLength: 3,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomButtonWithSymbol(
                    text: "",
                    icon: Symbols.arrow_back_ios_rounded,
                    backgroundColor: const Color(0xFF8C2020),
                    widthMinus: (screenWidth / 4).toInt()*4, // Ajustez la largeur en fonction de l'écran
                    onPressed: () {
                      if (_pageController.page?.toInt() == 0) {
                        Navigator.of(context).pop();
                      } else {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    scaleFactor: MediaQuery.of(context).textScaleFactor,
                  ),
                  CustomButton(
                    widthMinus: (screenWidth / 8).toInt()*3, // Ajustez la largeur en fonction de l'écran
                    text: step.buttonText,
                    onPressed: () {
                      if (step.onTap != null) {
                        step.onTap!();
                      }
                    },
                    scaleFactor: MediaQuery.of(context).textScaleFactor,
                  ),
                ],
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
        return CustomAlertDialog1(
          title: AppLocalizations.of(context)!.titre_popup_champ_vide,
          content: AppLocalizations.of(context)!.texte_popup_champ_vide,
          buttonText: AppLocalizations.of(context)!.ok,
          onPressed: () {
            Navigator.of(context).pop();
          },
          scaleFactor: MediaQuery.of(context).textScaleFactor,
        );
      },
    );
  }

  void _showZeroFieldDialog(BuildContext context) {
    print("🚫 Champ égal à zéro ou négatif");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog1(
          title: AppLocalizations.of(context)!.erreur,
          content: AppLocalizations.of(context)!.temps_de_recherche_ne_peut_etre_nul,
          buttonText: AppLocalizations.of(context)!.ok,
          onPressed: () {
            Navigator.of(context).pop();
          },
          scaleFactor: MediaQuery.of(context).textScaleFactor,
        );
      },
    );
  }

  void _shownegFieldDialog(BuildContext context) {
    print("🚫 Champ non valide");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog1(
          title: AppLocalizations.of(context)!.erreur,
          content: AppLocalizations.of(context)!.le_temps_de_recherche_ne_peut_pas_etre_negatif,
          buttonText: AppLocalizations.of(context)!.ok,
          onPressed: () {
            Navigator.of(context).pop();
          },
          scaleFactor: MediaQuery.of(context).textScaleFactor,
        );
      },
    );
  }

  void _show2hourFieldDialog(BuildContext context) {
    print("🚫 Champ non valide");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog1(
          title: AppLocalizations.of(context)!.erreur,
          content: AppLocalizations.of(context)!.la_duree_maximale_est_de_2_heures,
          buttonText: AppLocalizations.of(context)!.ok,
          onPressed: () {
            Navigator.of(context).pop();
          },
          scaleFactor: MediaQuery.of(context).textScaleFactor,
        );
      },
    );
  }

  void _showInvalidFieldDialog(BuildContext context) {
    print("🚫 Champ non valide");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog1(
          title: AppLocalizations.of(context)!.erreur,
          content: AppLocalizations.of(context)!.la_duree_doit_etre_un_entier,
          buttonText: AppLocalizations.of(context)!.ok,
          onPressed: () {
            Navigator.of(context).pop();
          },
          scaleFactor: MediaQuery.of(context).textScaleFactor,
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
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;

  RoomCreationField({
    required this.label,
    this.hint = '',
    required this.controller,
    this.keyboardType = TextInputType.text,
  });
}
