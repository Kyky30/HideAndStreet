import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'PreferencesManager.dart';
import 'package:hide_and_street/monetization/AdmobHelper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'monetization/PremiumStatus.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:hide_and_street/components/buttons.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage();

  @override
  _AccountSettingsPageState createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  bool isBlindModeEnabled = false;
  String username = '';
  String DateCreation = '';
  String email = '';

  String CGUUrl = 'https://hideandstreet.furrball.fr/CGU.html';
  String CGVUrl = 'https://hideandstreet.furrball.fr/CGV.html';
  String PrivacyUrl = 'https://hideandstreet.furrball.fr/privacy.html';

  @override
  void initState() {
    super.initState();
    _loadPreferences(); // Charge la valeur du mode aveugle au démarrage
  }

  _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool blindMode = await PreferencesManager.getBlindToggle();
    setState(() {
      username = prefs.getString('username') ?? ''; // Utilisez la clé correcte
      DateCreation = DateCreation = (prefs.getString('DateCreation') ?? '').substring(0, 15);
      isBlindModeEnabled = blindMode;
      email = prefs.getString('email') ?? '';
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

  Future<void> _launchUrl(_url) async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
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
              Card(
                child: ListTile(
                  leading: Icon(Symbols.account_box_rounded, fill: 1, weight: 700, grade: 200, opticalSize: 24),
                  title: Text(username, style: TextStyle(fontSize: 18 * scaleFactor, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                  subtitle: Text(email, style: TextStyle(fontSize: 16 * scaleFactor, fontWeight: FontWeight.w400, fontFamily: 'Poppins')),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Symbols.calendar_today_rounded, fill: 1, weight: 700, grade: 200, opticalSize: 24),
                  title: Text(AppLocalizations.of(context)!.creationDateLabel, style: TextStyle(fontSize: 18 * scaleFactor, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                  subtitle: Text(DateCreation, style: TextStyle(fontSize: 16 * scaleFactor, fontWeight: FontWeight.w400, fontFamily: 'Poppins')),
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
              Spacer(),
              CustomButton(
                  text: AppLocalizations.of(context)!.deconnexion,
                  onPressed: () => _logout(context),
                  scaleFactor: scaleFactor
              ),
              SizedBox(height: 20 * scaleFactor),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      launchUrl(Uri.parse(CGUUrl));
                    },
                    child: Text(
                      AppLocalizations.of(context)!.cgu,
                      style: TextStyle(color: Colors.black, fontSize: 13 * scaleFactor, fontWeight: FontWeight.w600, fontFamily: 'Poppins', backgroundColor: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      launchUrl(Uri.parse(CGVUrl));
                    },
                    child: Text(
                      AppLocalizations.of(context)!.cgv,
                      style: TextStyle(color: Colors.black, fontSize: 13 * scaleFactor, fontWeight: FontWeight.w600, fontFamily: 'Poppins', backgroundColor: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      launchUrl(Uri.parse(PrivacyUrl));
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
      ),
    );
  }
}
