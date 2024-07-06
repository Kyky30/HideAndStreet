import 'package:flutter_tts/flutter_tts.dart';

class TtsUtilities {
  FlutterTts text2speech = FlutterTts();

  void speak(String text) async {
    await text2speech.setLanguage("fr-FR");
    await text2speech.speak(text);
  }

}