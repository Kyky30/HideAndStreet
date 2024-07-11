import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:HideAndStreet/Page/Login/loginPage.dart';
import '../../components/alertbox.dart';
import 'package:HideAndStreet/WebSocketManager.dart';

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

  bool _isDialogVisible = false; // Variable pour suivre l'état de la boîte de dialogue

  void signUp(BuildContext context, String emailValues, String pseudoValues, String passwordValues, String confirmPasswordValues) async {
    // Check if email is valid.
    bool isValid = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(emailValues);

    // Check if email is valid
    if (isValid) {
      if (passwordValues == confirmPasswordValues) {
        try {
          await WebSocketManager.connect(emailValues);

          // Send data to Node.js
          await WebSocketManager.sendData("'cmd':'signup', 'email':'$emailValues', 'username':'$pseudoValues','hash':'$passwordValues'");

          // Listen for data from the server
          WebSocketManager.getStream().listen((event) async {
            event = event.replaceAll(RegExp("'"), '"');
            var signupData = json.decode(event);
            debugPrint(signupData.toString());

            // Check if the status is successful
            if (signupData["status"] == 'success') {
              // Return user to login if successful
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            } else if (signupData["status"] == 'user_exists') {
              _handleError(context, AppLocalizations.of(context)!.nom_dutilisateur_deja_utilise, 1);
            } else if (signupData["status"] == 'mail_exists') {
              _handleError(context, AppLocalizations.of(context)!.email_deja_utilise, 2);
            }
          });
        } catch (e) {
          print("Error on connecting to websocket: " + e.toString());
        }
      } else {
        print("Passwords do not match");
      }
    } else {
      print("Invalid email");
    }
  }

  void _handleError(BuildContext context, String content, int stepIndex) {
    if (!_isDialogVisible) {
      _isDialogVisible = true;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog1(
            title: AppLocalizations.of(context)!.erreur,
            content: content,
            buttonText: AppLocalizations.of(context)!.ok,
            onPressed: () {
              Navigator.of(context).pop();
              _isDialogVisible = false;
              _navigateToStep(stepIndex);
            },
            scaleFactor: getScaleFactor(context),
          );
        },
      ).then((_) {
        _isDialogVisible = false;
        _navigateToStep(stepIndex);  // Ensure navigation happens after dialog is dismissed
      });
    }
  }

  void _navigateToStep(int stepIndex) {
    pageController.jumpToPage(stepIndex);
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