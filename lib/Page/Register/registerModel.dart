import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:web_socket_channel/io.dart';

import 'dart:developer' as developer;

import 'package:hide_and_street/Page/Login/loginPage.dart';
import 'package:hide_and_street/components/alertbox.dart';

class RegisterModel {

  GlobalKey<FormFieldState<String>> dateOfBirthKey = GlobalKey<FormFieldState<String>>();

  bool toggleValue = false;

  PageController pageController = PageController(initialPage: 0);
  DateTime? selectedDate;

  String pseudoValues = "";
  String emailValues = "";
  DateTime? dateOfBirthValues = DateTime.now();
  String passwordValues = "";
  String confirmPasswordValues = "";
  bool blindToggleValues = false;

  String TexteSelctionDate = "";

  final TextEditingController emailController = TextEditingController();
  final TextEditingController pseudoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  void signUp(BuildContext context, String emailValues, String pseudoValues, String passwordValues, String confirmPasswordValues) async {
    // Check if email is valid.
    bool isValid = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(emailValues);
    String auth = "chatappauthkey231r4";
    // Check if email is valid
    if (isValid) {
      if (passwordValues == confirmPasswordValues) {
        IOWebSocketChannel channel;
        try {
          // Create connection.
          channel = IOWebSocketChannel.connect('wss://app.hideandstreet.furrball.fr/signup$emailValues');
          print("Connexion réussie inshallah");
        } catch (e) {
          print("Error on connecting to websocket: " + e.toString());
          return;
        }
        // Data that will be sent to Node.js
        String hashedPassword = await FlutterBcrypt.hashPw(
          password : passwordValues,
          salt : await FlutterBcrypt.salt(),
        );
        String signUpData =
            "{'auth':'$auth','cmd':'signup','email':'$emailValues','username':'$pseudoValues','hash':'$hashedPassword'}";
        // Send data to Node.js
        channel.sink.add(signUpData);
        // Listen for data from the server
        channel.stream.listen((event) async {
          developer.log(signUpData);
          event = event.replaceAll(RegExp("'"), '"');
          var signupData = json.decode(event);
          // Check if the status is successful
          if (signupData["status"] == 'success') {
            // Close connection.
            channel.sink.close();
            // Return user to login if successful
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          } else {
            channel.sink.close();
            print("Error signing up");
          }
        });
      } else {
        print("Passwords do not match");
      }
    } else {
      print("Invalid email");
    }
  }

  bool isPasswordSecure(String password) {
    RegExp passwordRegex = RegExp(r'^(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[!@#$&*~]).{8,}$');
    return passwordRegex.hasMatch(password);
  }

  double getScaleFactor(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    return mediaQueryData.textScaleFactor;
  }
}

class RegistrationStep {
  final String title;
  final String background;
  final String buttonText;
  final String logo;
  final List<RegistrationField> fields;
  final VoidCallback? validate;
  final VoidCallback? onTap;

  RegistrationStep({
    required this.title,
    required this.background,
    required this.buttonText,
    required this.logo,
    this.fields = const [],
    this.validate,
    this.onTap,
  });
}

class RegistrationField {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final Key? key;
  final bool isPassword;
  final bool dateField;
  final bool toggleField;

  RegistrationField({
    required this.label,
    this.hint,
    this.key,
    this.controller,
    this.isPassword = false,
    this.dateField = false,
    this.toggleField = false,
  });
}
