import 'package:flutter/material.dart';
import 'package:HideAndStreet/Page/map_conf_screen.dart';
import 'package:HideAndStreet/room_joining.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:HideAndStreet/components/buttons.dart';
import 'package:HideAndStreet/components/alertbox.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late LocationPermission permission;


  @override
  void initState() {
    super.initState();
    _showFirstLaunchDialog();
    _determinePermissions();
  }

  Future<void> _showFirstLaunchDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    if (isFirstLaunch) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog1(
              title: AppLocalizations.of(context)!.titre_popup_avertissement,
              content: AppLocalizations.of(context)!.texte_popup_avertissement,
              buttonText: 'OK',
              onPressed: () {
                Navigator.of(context).pop();
              },
              scaleFactor: getScaleFactor(context));
        },
      );
      await prefs.setBool('isFirstLaunch', false);
    }
  }

  double getScaleFactor(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    return mediaQueryData.textScaleFactor;
  }

  Future<void> _determinePermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Permission de localisation ------------------------------------------------
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog2(
            title: AppLocalizations.of(context)!.locationPermissions,
            content: AppLocalizations.of(context)!.locationPermissionsMessage,
            buttonText1: AppLocalizations.of(context)!.bouton_autoriser,
            buttonText2: AppLocalizations.of(context)!.bouton_refuser,
            onPressed1: () async {
              Navigator.of(context).pop();
              permission = await Geolocator.requestPermission();
            },
            onPressed2: () {
              Navigator.of(context).pop();
            },
            scaleFactor: MediaQuery.of(context).textScaleFactor,
          );
        },
      );
    }

    // Permission de notification ------------------------------------------------
    await Permission.notification.isDenied.then((value) {
      if (value) {
        Permission.notification.request();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scaleFactor = getScaleFactor(context);

    return Scaffold(
      body: Stack(
        children: [
          // Image de fond
          Positioned.fill(
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
            ),
          ),
          // Contenu de la page
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo en haut de la page
                Container(
                  margin: EdgeInsets.fromLTRB(15, 75 * scaleFactor, 15, 0),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/logo_home_menu.png',
                        width: (MediaQuery.of(context).size.width - 150) * scaleFactor,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 10 * scaleFactor),
                    ],
                  ),
                ),
                SizedBox(height: 3 * scaleFactor),
                // Spacer pour remplir l'espace disponible
                const Spacer(),
                // Boutons pour créer et rejoindre une partie
                CustomButton(
                  text: AppLocalizations.of(context)!.creerpartie,
                  onPressed: () async {

                    permission = await Geolocator.checkPermission();
                    if (permission == LocationPermission.denied) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return CustomAlertDialog2(
                            title: AppLocalizations.of(context)!.locationPermissions,
                            content: AppLocalizations.of(context)!.locationPermissionsMessage,
                            buttonText1: AppLocalizations.of(context)!.bouton_autoriser,
                            buttonText2: AppLocalizations.of(context)!.bouton_refuser,
                            onPressed1: () async {
                              Navigator.of(context).pop();
                              permission = await Geolocator.requestPermission();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MapConfScreen(),
                                ),
                              );
                            },
                            onPressed2: () {
                              Navigator.of(context).pop();
                            },
                            scaleFactor: MediaQuery.of(context).textScaleFactor,
                          );
                        },
                      );
                    }



                  },
                  scaleFactor: scaleFactor,
                ),
                SizedBox(height: 16 * scaleFactor),
                CustomButton(
                  text: AppLocalizations.of(context)!.rejoindrepartie,
                  onPressed: () async {


                    permission = await Geolocator.checkPermission();
                    if (permission == LocationPermission.denied) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return CustomAlertDialog2(
                            title: AppLocalizations.of(context)!.locationPermissions,
                            content: AppLocalizations.of(context)!.locationPermissionsMessage,
                            buttonText1: AppLocalizations.of(context)!.bouton_autoriser,
                            buttonText2: AppLocalizations.of(context)!.bouton_refuser,
                            onPressed1: () async {
                              Navigator.of(context).pop();
                              permission = await Geolocator.requestPermission();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RoomJoiningPage(),
                                ),
                              );
                            },
                            onPressed2: () {
                              Navigator.of(context).pop();
                            },
                            scaleFactor: MediaQuery.of(context).textScaleFactor,
                          );
                        },
                      );
                    }




                  },
                  scaleFactor: scaleFactor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
