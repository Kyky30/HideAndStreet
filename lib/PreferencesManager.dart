import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  static const _keyBlindToggle = 'blindToggle';

  static Future<void> setBlindToggle(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBlindToggle, value);
    debugPrint('Blind Toggle set to: $value');
  }

  static Future<bool> getBlindToggle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool value = prefs.getBool(_keyBlindToggle) ?? false;
    debugPrint('Blind Toggle retrieved: $value');
    return value;
  }

  static Future<void> setMusicVolume(double value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('volume', value);
    debugPrint('Music volume set to: $value');
  }

  static Future<double> getMusicVolume() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double value = prefs.getDouble('volume') ?? 0.5;
    debugPrint('Music volume retrieved: $value');
    return value;
  }

  static Future<void> setMaskedPlayers(List<String> value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('hiddenPlayers', value);
    debugPrint('Masked players set to: $value');
  }

  static Future<List<String>> getMaskedPlayers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> value = prefs.getStringList('hiddenPlayers') ?? [];
    debugPrint('Masked players retrieved: $value');
    return value;
  }


}
