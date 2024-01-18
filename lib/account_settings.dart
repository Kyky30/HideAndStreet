// account_settings.dart
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'PreferencesManager.dart';

class AccountSettingsPage extends StatefulWidget {
  final String username;
  final String email;

  const AccountSettingsPage({Key? key, required this.username, required this.email}) : super(key: key);

  @override
  _AccountSettingsPageState createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  bool isBlindModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBlindMode(); // Charge la valeur du mode aveugle au démarrage
  }

  _loadBlindMode() async {
    bool blindMode = await PreferencesManager.getBlindToggle();
    setState(() {
      isBlindModeEnabled = blindMode;
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
              widget.username,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.emailLabel,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.email,
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
          ],
        ),
      ),
    );
  }
}
