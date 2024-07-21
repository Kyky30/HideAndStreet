import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../PreferencesManager.dart';
import 'package:HideAndStreet/monetization/AdmobHelper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../monetization/PremiumStatus.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:HideAndStreet/components/buttons.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage();

  @override
  _AccountSettingsPageState createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  bool isBlindModeEnabled = false;
  double volume = 0.5;

  String username = '';
  String dateCreation = '';
  String email = '';
  String playedGames = '';
  String wonGames = '';

  String cguUrl = 'https://hideandstreet.furrball.fr/CGU.html';
  String cgvUrl = 'https://hideandstreet.furrball.fr/CGV.html';
  String privacyUrl = 'https://hideandstreet.furrball.fr/privacy.html';
  String deleteAccountUrl = 'https://app.hideandstreet.furrball.fr/delete-account.html';

  @override
  void initState() {
    super.initState();
    _loadPreferences(); // Charge la valeur du mode aveugle au démarrage
  }

  _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool blindMode = await PreferencesManager.getBlindToggle();
    setState(() {
      volume = prefs.getDouble('volume') ?? 0.5;
      username = prefs.getString('username') ?? ''; // Utilisez la clé correcte
      dateCreation = dateCreation = (prefs.getString('DateCreation') ?? '').substring(0, 15);
      isBlindModeEnabled = blindMode;
      email = prefs.getString('email') ?? '';
      playedGames = prefs.getString('nbGames') ?? '';
      wonGames = prefs.getString('nbWonGames') ?? '';
    });
  }

  _saveBlindMode() async {
    await PreferencesManager.setBlindToggle(isBlindModeEnabled);
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Remove any stored user credentials or tokens
    await prefs.remove('loggedin'); // Assuming 'loggedin' is used for storing authentication status

    // Clear the blind mode preference
    await PreferencesManager.setBlindToggle(false);

    // Reset the state
    setState(() {
      isBlindModeEnabled = false;
    });

    // Navigate to the login page
    Navigator.pushReplacementNamed(context, '/login');
  }

  double getScaleFactor(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    return mediaQueryData.textScaleFactor;
  }

  @override
  Widget build(BuildContext context) {
    final scaleFactor = getScaleFactor(context);

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20 * scaleFactor),
              if (PremiumStatus().isPremium == false)
                Container(
                  child: AdWidget(
                    ad: AdmobHelper.getBannerAd()..load(),
                    key: UniqueKey(),
                  ),
                  height: 75 * scaleFactor,
                ),
              Expanded(
                child: ListView(
                  children: [
                    Card(
                      child: ListTile(
                        leading: const Icon(Symbols.account_box_rounded, fill: 1, weight: 700, grade: 200, opticalSize: 24),
                        title: Text(username, style: TextStyle(fontSize: 18 * scaleFactor, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                        subtitle: Text(email, style: TextStyle(fontSize: 16 * scaleFactor, fontWeight: FontWeight.w400, fontFamily: 'Poppins')),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: const Icon(Symbols.calendar_today_rounded, fill: 1, weight: 700, grade: 200, opticalSize: 24),
                        title: Text(AppLocalizations.of(context)!.creationDateLabel, style: TextStyle(fontSize: 18 * scaleFactor, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                        subtitle: Text(dateCreation, style: TextStyle(fontSize: 16 * scaleFactor, fontWeight: FontWeight.w400, fontFamily: 'Poppins')),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: const Icon(Symbols.sports_rounded, fill: 1, weight: 700, grade: 200, opticalSize: 24),
                        title: Text(AppLocalizations.of(context)!.playedGames, style: TextStyle(fontSize: 18 * scaleFactor, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                        subtitle: Text(playedGames, style: TextStyle(fontSize: 16 * scaleFactor, fontWeight: FontWeight.w400, fontFamily: 'Poppins')),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: const Icon(Symbols.trophy_rounded, fill: 1, weight: 700, grade: 200, opticalSize: 24),
                        title: Text(AppLocalizations.of(context)!.wonGames, style: TextStyle(fontSize: 18 * scaleFactor, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                        subtitle: Text(wonGames, style: TextStyle(fontSize: 16 * scaleFactor, fontWeight: FontWeight.w400, fontFamily: 'Poppins')),
                      ),
                    ),
                    Card(
                      child: SwitchListTile(
                        title: Text(AppLocalizations.of(context)!.blind_toggle_label, style: TextStyle(fontSize: 18 * scaleFactor, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                        value: isBlindModeEnabled,
                        onChanged: (value) {
                          setState(() {
                            isBlindModeEnabled = value;
                          });
                          _saveBlindMode();
                        },
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.volume_up),
                        title: Text(AppLocalizations.of(context)!.volume_label, style: TextStyle(fontSize: 18 * scaleFactor, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                        subtitle: Slider(
                          value: volume,
                          min: 0.0,
                          max: 1.0,
                          onChanged: (newValue) {
                            setState(() {
                              volume = newValue;
                            });
                            PreferencesManager.setMusicVolume(volume);
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20 * scaleFactor),
                    CustomButton(
                      text: AppLocalizations.of(context)!.boutonSupprimerCompte,
                      onPressed: () {
                        launchUrl(Uri.parse(deleteAccountUrl));
                      },
                      scaleFactor: scaleFactor,
                      height: 50,
                      backgroundColor: const Color(0xFF8C2020),
                    ),
                    SizedBox(height: 10 * scaleFactor),
                    CustomButton(
                      text: AppLocalizations.of(context)!.deconnexion,
                      onPressed: () => _logout(context),
                      height: 70,
                      scaleFactor: scaleFactor,
                    ),
                    SizedBox(height: 10 * scaleFactor),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            launchUrl(Uri.parse(cguUrl));
                          },
                          child: Text(
                            AppLocalizations.of(context)!.cgu,
                            style: TextStyle(color: Colors.black, fontSize: 13 * scaleFactor, fontWeight: FontWeight.w600, fontFamily: 'Poppins', backgroundColor: Colors.white),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            launchUrl(Uri.parse(cgvUrl));
                          },
                          child: Text(
                            AppLocalizations.of(context)!.cgv,
                            style: TextStyle(color: Colors.black, fontSize: 13 * scaleFactor, fontWeight: FontWeight.w600, fontFamily: 'Poppins', backgroundColor: Colors.white),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            launchUrl(Uri.parse(privacyUrl));
                          },
                          child: Text(
                            AppLocalizations.of(context)!.privacy,
                            style: TextStyle(color: Colors.black, fontSize: 13 * scaleFactor, fontWeight: FontWeight.w600, fontFamily: 'Poppins', backgroundColor: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
