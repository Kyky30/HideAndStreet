import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bcrypt/flutter_bcrypt.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hide_and_street/PreferencesManager.dart';
import 'package:hide_and_street/Page/login.dart';
import 'package:web_socket_channel/io.dart';


import 'dart:developer' as developer;

import 'Page/Login/LoginPage.dart';
import 'components/alertbox.dart';
import 'components/buttons.dart';
import 'components/input.dart';

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

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  PageController _pageController = PageController(initialPage: 0);
  DateTime? _selectedDate;

  String pseudoValues = "";
  String emailValues = "";
  DateTime? dateOfBirthValues = DateTime.now();
  String passwordValues = "";
  String confirmPasswordValues = "";
  bool blindToggleValues = false;

  String _TexteSelctionDate = "";

  final TextEditingController emailController = TextEditingController();
  final TextEditingController pseudoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  GlobalKey<FormFieldState<String>> dateOfBirthKey = GlobalKey<FormFieldState<String>>();

  bool _toggleValue = false;

  @override
  void initState() {
    super.initState();
    _loadBlindToggle();

    emailController.addListener(() {
      emailValues = emailController.text;
    });
    pseudoController.addListener(() {
      pseudoValues = pseudoController.text;
    });
    passwordController.addListener(() {
      passwordValues = passwordController.text;
    });
    confirmPasswordController.addListener(() {
      confirmPasswordValues = confirmPasswordController.text;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _TexteSelctionDate = AppLocalizations.of(context)?.selection_bday ?? "";
  }


  _loadBlindToggle() async {
    bool blindToggle = await PreferencesManager.getBlindToggle();
    setState(() {
      _toggleValue = blindToggle;
    });
  }

  _saveBlindToggle() async {
    await PreferencesManager.setBlindToggle(_toggleValue);
  }

  List<RegistrationStep> _steps(BuildContext context) => [
    RegistrationStep(
      title: AppLocalizations.of(context)!.titre_date_naissance,
      background: 'assets/background_white.jpg',
      buttonText: AppLocalizations.of(context)!.confirmer,
      logo: 'assets/logo_connect.png',
      fields: [
        RegistrationField(label: AppLocalizations.of(context)!.datedenaissance, dateField: true, key: dateOfBirthKey),
      ],
      validate: () {
        if (_selectedDate == null) {
          _showEmptyFieldDialog(context);
        } else {
          var currentDate = DateTime.now();
          var age = currentDate.year - _selectedDate!.year - ((_selectedDate!.month > currentDate.month || (_selectedDate!.month == currentDate.month && _selectedDate!.day > currentDate.day)) ? 1 : 0);

          if (age < 13) {
            _showAgeRestrictionDialog(context);
          } else {
            _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
          }
        }
      },
      onTap: () {
        var dateOfBirth = _selectedDate;
        dateOfBirthValues = dateOfBirth;
        print(dateOfBirthValues);
      },
    ),
    RegistrationStep(
      title: AppLocalizations.of(context)!.titre_pseudo,
      background: 'assets/background_white.jpg',
      buttonText: AppLocalizations.of(context)!.confirmer,
      logo: 'assets/logo_connect.png',
      fields: [
        RegistrationField(label: AppLocalizations.of(context)!.pseudo, hint: AppLocalizations.of(context)!.pseudo, controller: pseudoController),
      ],
      onTap: () {
        if (pseudoController.text.isEmpty) {
          _showEmptyFieldDialog(context);
        } else {
          pseudoValues = pseudoController.text;
          print(pseudoValues);
          _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        }
      },
    ),
    RegistrationStep(
      title: AppLocalizations.of(context)!.titre_email,
      background: 'assets/background_white.jpg',
      buttonText: AppLocalizations.of(context)!.confirmer,
      logo: 'assets/logo_connect.png',
      fields: [
        RegistrationField(label: AppLocalizations.of(context)!.mail, hint: AppLocalizations.of(context)!.exemple_email, isPassword: false, controller: emailController),
      ],
      onTap: () {
        if (emailController.text.isEmpty) {
          _showEmptyFieldDialog(context);
        } else {
          emailValues = emailController.text;
          print(emailValues);
          _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        }
      },
    ),
    RegistrationStep(
      title: AppLocalizations.of(context)!.titre_mdp,
      background: 'assets/background_white.jpg',
      buttonText: AppLocalizations.of(context)!.confirmer,
      logo: 'assets/logo_connect.png',
      fields: [
        RegistrationField(label: AppLocalizations.of(context)!.mdp, hint: AppLocalizations.of(context)!.mdp, isPassword: true, controller: passwordController),
        RegistrationField(label: AppLocalizations.of(context)!.mdpconfirm, hint: AppLocalizations.of(context)!.mdpconfirm, isPassword: true, controller: confirmPasswordController),
      ],
      onTap: () {
        if (passwordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
          _showEmptyFieldDialog(context);
        } else if (passwordController.text != confirmPasswordController.text) {
          _showPasswordMismatchDialog(context);
        } else if (!isPasswordSecure(passwordController.text)) {
          _showPasswordInsecureDialog(context);
        } else {
          passwordValues = passwordController.text;
          confirmPasswordValues = confirmPasswordController.text;
          print(passwordValues);
          _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        }
      },
    ),
    RegistrationStep(
      title: AppLocalizations.of(context)!.titre_blind_toggle,
      background: 'assets/background_white.jpg',
      buttonText: AppLocalizations.of(context)!.confirmer,
      logo: 'assets/logo_connect.png',
      fields: [
        RegistrationField(label: AppLocalizations.of(context)!.blind_toggle_label, toggleField: true),
      ],
      onTap: () {
        blindToggleValues = _toggleValue;
        print(blindToggleValues);
        _saveBlindToggle();
        signUp(context, emailValues, pseudoValues, passwordValues, confirmPasswordValues);
      },
    ),
  ];

  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: _steps(context).length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return _buildStepPage(_steps(context)[index]);
        },
      ),
    );
  }

  double getScaleFactor(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    return mediaQueryData.textScaleFactor;
  }

  Widget _buildStepPage(RegistrationStep step) {
    final scaleFactor = getScaleFactor(context);

    return SingleChildScrollView(
      child: Stack(
        children: [
          Image.asset(
            step.background,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.fromLTRB(15, 75, 15, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    step.logo,
                    width: MediaQuery.of(context).size.width - 150,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      step.title,
                      style: TextStyle(fontSize: 24.0 * scaleFactor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  for (var field in step.fields)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: field.dateField
                          ? CustomButton(
                            text: _TexteSelctionDate,
                            onPressed: () => _selectDate(context),
                            scaleFactor: MediaQuery.of(context).textScaleFactor,
                        )
                          : field.toggleField
                          ? SwitchListTile(
                        title: Text(field.label),
                        value: _toggleValue,
                        onChanged: (value) {
                          setState(() {
                            _toggleValue = value;
                          });
                        },
                      )
                          : CustomTextField(
                          obscureText: field.isPassword,
                          hintText: field.hint ?? '',
                          controller: field.controller ?? TextEditingController(),
                          scaleFactor: scaleFactor
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20 * scaleFactor,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomButton(
                text: step.buttonText,
                onPressed: () {
                  if (step.validate != null) {
                    step.validate!();
                  } else {
                    if (step.onTap != null) {
                      step.onTap!();
                    }
                  }
                },
                scaleFactor: MediaQuery.of(context).textScaleFactor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1910),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _TexteSelctionDate = _selectedDate.toString().substring(0, 10);
      });
    }
  }

  void _showPasswordMismatchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog1(
          title: AppLocalizations.of(context)!.titre_popup_mdp,
          content: AppLocalizations.of(context)!.texte_popup_mdp,
          buttonText: AppLocalizations.of(context)!.ok,
          onPressed: () {
            Navigator.of(context).pop();
          },
          scaleFactor: MediaQuery.of(context).textScaleFactor,
        );
      },
    );
  }

  void _showEmptyFieldDialog(BuildContext context) {
    print("🚫 Champ vide");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog1(
          title: AppLocalizations.of(context)!.titre_popup_champ_vide,
          content: AppLocalizations.of(context)!.texte_popup_champ_vide,
          buttonText: AppLocalizations.of(context)!.ok,
          onPressed: () {
            Navigator.of(context).pop();
          },
          scaleFactor: MediaQuery.of(context).textScaleFactor,
        );
      },
    );
  }

  void _showAgeRestrictionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog1(
          title: AppLocalizations.of(context)!.titre_popup_age,
          content: AppLocalizations.of(context)!.texte_popup_age,
          buttonText: AppLocalizations.of(context)!.ok,
          onPressed: () {
            Navigator.of(context).pop();
          },
          scaleFactor: MediaQuery.of(context).textScaleFactor,
        );
      },
    );
  }
}

void _showPasswordInsecureDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomAlertDialog1(
        title: AppLocalizations.of(context)!.titre_popup_mdp_insecure,
        content: AppLocalizations.of(context)!.texte_popup_mdp_insecure,
        buttonText: AppLocalizations.of(context)!.ok,
        onPressed: () {
          Navigator.of(context).pop();
        },
        scaleFactor: MediaQuery.of(context).textScaleFactor,
      );
    },
  );
}

bool isPasswordSecure(String password) {
  // Vérifie si le mot de passe a au moins 8 caractères, une majuscule, un chiffre et un caractère spécial.
  RegExp passwordRegex = RegExp(r'^(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[!@#$&*~]).{8,}$');
  return passwordRegex.hasMatch(password);
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
