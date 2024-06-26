import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  static const _keyBlindToggle = 'blindToggle';

  static Future<void> setBlindToggle(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBlindToggle, value);
    print('Blind Toggle set to: $value');
  }

  static Future<bool> getBlindToggle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool value = prefs.getBool(_keyBlindToggle) ?? false;
    print('Blind Toggle retrieved: $value');
    return value;
  }

}
