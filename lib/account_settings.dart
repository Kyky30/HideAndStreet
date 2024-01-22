// account_settings.dart
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'PreferencesManager.dart';
import 'package:hide_and_street/api/AdmobHelper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'api/PremiumStatus.dart';

import 'package:url_launcher/url_launcher.dart';


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
  String PrivacyUrl = 'https://hideandstreet.furrball.fr/Privacy.html';

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
      DateCreation = prefs.getString('DateCreation') ?? '';
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
    await prefs.remove('loggedin');  // Assuming 'loggedin' is used for storing authentication status

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profileTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.usernameLabel,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              username,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.emailLabel,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              email,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.creationDateLabel,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              DateCreation,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.blind_toggle_label,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Switch(
                  value: isBlindModeEnabled,
                  onChanged: (value) {
                    setState(() {
                      isBlindModeEnabled = value;
                    });
                    _saveBlindMode(); // Enregistre la valeur du mode aveugle lorsque le toggle change
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _logout(context),
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
                'Logout',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            if (PremiumStatus().isPremium == false)
              Container(
                child: AdWidget(
                  ad: AdmobHelper.getBannerAd()..load(),
                  key: UniqueKey(),
                ),
                height: 75,
              )
            ,
            Spacer(),
            TextButton(
              onPressed: () {
                launchUrl(Uri.parse(CGUUrl));
              },
              child: Text(
                AppLocalizations.of(context)!.cgu,
                style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins', backgroundColor: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                launchUrl(Uri.parse(CGVUrl));
              },
              child: Text(
                AppLocalizations.of(context)!.cgv,
                style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins', backgroundColor: Colors.white),
              ),
            ),
            TextButton(
              onPressed: () {
                launchUrl(Uri.parse(PrivacyUrl));
              },
              child: Text(
                AppLocalizations.of(context)!.privacy,
                style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Poppins', backgroundColor: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
