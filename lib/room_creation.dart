import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:latlong2/latlong.dart';


class RoomCreationPage extends StatefulWidget {
  final LatLng initialTapPosition;
  final double initialRadius;

  RoomCreationPage({
    required this.initialTapPosition,
    required this.initialRadius,
  });

  @override
  _RoomCreationPageState createState() => _RoomCreationPageState();
}

class _RoomCreationPageState extends State<RoomCreationPage> {
  PageController _pageController = PageController(initialPage: 0);

  int dureePartie = 0;
  int nbChercheurs = 0;

  List<GlobalKey<FormFieldState<String>>> dureeKey = [GlobalKey<FormFieldState<String>>()];
  List<GlobalKey<FormFieldState<String>>> nbChercheursKey = [GlobalKey<FormFieldState<String>>()];

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
          _pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
        }
      },
    ),
    RoomCreationStep(
      title: AppLocalizations.of(context)!.titre_conf_chercheurs,
      background: 'assets/background_white.jpg',
      buttonText: AppLocalizations.of(context)!.confirmer,
      logo: 'assets/logo_connect.png',
      fields: [
        RoomCreationField(label: AppLocalizations.of(context)!.champ_conf_chercheurs, hint: AppLocalizations.of(context)!.texte_champ_conf_chercheurs, key: nbChercheursKey[0], keyboardType: TextInputType.number),
      ],
      onTap: () {
        var nbcherch = nbChercheursKey[0].currentState?.value ?? "";
        if (nbcherch.isEmpty) {
          _showEmptyFieldDialog(context);
        } else {
          nbChercheurs = int.parse(nbcherch);
          print(nbChercheurs);
          _pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
        }
      },
    ),

  ];

  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: _steps(context).length,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return _buildStepPage(_steps(context)[index]);
        },
      ),
    );
  }

  Widget _buildStepPage(RoomCreationStep step) {
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
              margin: const EdgeInsets.fromLTRB(15, 75, 15, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    step.logo,
                    width: MediaQuery.of(context).size.width - 150,
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
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      step.title,
                      style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  for (var field in step.fields)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        key: field.key,
                        keyboardType: field.keyboardType,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[300],
                          hintText: field.hint,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (step.onTap != null) {
                    step.onTap!();
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 20,
                      cornerSmoothing: 1,
                    ),
                  ),
                  minimumSize: const Size(double.infinity, 80),
                  backgroundColor: const Color(0xFF373967),
                  foregroundColor: const Color(0xFF212348),
                ),
                child: Text(
                  step.buttonText,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEmptyFieldDialog(BuildContext context) {
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
              child: Text("OK"),
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

