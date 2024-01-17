import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  static const _keyBlindToggle = 'blindToggle';

  static Future<bool> getBlindToggle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBlindToggle) ?? false;
  }

  static Future<void> setBlindToggle(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBlindToggle, value);
  }
}
