import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:figma_squircle/figma_squircle.dart';

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

  List<GlobalKey<FormFieldState<String>>> pseudoKey = [GlobalKey<FormFieldState<String>>()];
  List<GlobalKey<FormFieldState<String>>> emailKey = [GlobalKey<FormFieldState<String>>()];
  GlobalKey<FormFieldState<String>> dateOfBirthKey = GlobalKey<FormFieldState<String>>();
  List<GlobalKey<FormFieldState<String>>> passwordKeys = [GlobalKey<FormFieldState<String>>(), GlobalKey<FormFieldState<String>>()];

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
          _showEmptyFieldDialog(context, "Date of Birth");
        } else {
          var currentDate = DateTime.now();
          var age = currentDate.year - _selectedDate!.year - ((_selectedDate!.month > currentDate.month || (_selectedDate!.month == currentDate.month && _selectedDate!.day > currentDate.day)) ? 1 : 0);

          if (age < 13) {
            _showAgeRestrictionDialog(context);
          } else {
            _pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
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
        RegistrationField(label: AppLocalizations.of(context)!.pseudo, hint: AppLocalizations.of(context)!.pseudo, key: pseudoKey[0]),
      ],
      onTap: () {
        var pseudo = pseudoKey[0].currentState?.value ?? "";
        if (pseudo.isEmpty) {
          _showEmptyFieldDialog(context, "Pseudo");
        } else {
          pseudoValues = pseudo;
          print(pseudoValues);
          _pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
        }
      },
    ),
    RegistrationStep(
      title: AppLocalizations.of(context)!.titre_email,
      background: 'assets/background_white.jpg',
      buttonText: AppLocalizations.of(context)!.confirmer,
      logo: 'assets/logo_connect.png',
      fields: [
        RegistrationField(label: AppLocalizations.of(context)!.mail, hint: AppLocalizations.of(context)!.exemple_email, isPassword: false, key: emailKey[0]),
      ],
      onTap: () {
        var email = emailKey[0].currentState?.value ?? "";
        if (email.isEmpty) {
          _showEmptyFieldDialog(context, "Email");
        } else {
          emailValues = email;
          print(emailValues);
          _pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
        }
      },
    ),
    RegistrationStep(
      title: AppLocalizations.of(context)!.titre_mdp,
      background: 'assets/background_white.jpg',
      buttonText: AppLocalizations.of(context)!.confirmer,
      logo: 'assets/logo_connect.png',
      fields: [
        RegistrationField(label: AppLocalizations.of(context)!.mdp, hint: AppLocalizations.of(context)!.mdp, isPassword: true, key: passwordKeys[0]),
        RegistrationField(label: AppLocalizations.of(context)!.mdpconfirm, hint: AppLocalizations.of(context)!.mdpconfirm, isPassword: true, key: passwordKeys[1]),
      ],
      onTap: () {
        var password = passwordKeys[0].currentState?.value ?? "";
        var confirmPassword = passwordKeys[1].currentState?.value ?? "";

        if (password.isEmpty || confirmPassword.isEmpty) {
          _showEmptyFieldDialog(context, "Password");
        } else {
          if (password == confirmPassword) {
            passwordValues = password;
            print(passwordValues);
          } else {
            print("Les mots de passe ne correspondent pas.");
          }
          _pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
        }
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: _steps(context).length,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return _buildStepPage(_steps(context)[index]);
        },
      ),
    );
  }

  Widget _buildStepPage(RegistrationStep step) {
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
                      style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  for (var field in step.fields)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: field.dateField
                          ? ElevatedButton(
                        onPressed: () => _selectDate(context),
                        child: Text(
                          AppLocalizations.of(context)!.selection_bday,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                              cornerRadius: 20,
                              cornerSmoothing: 1,
                            ),
                          ),
                          minimumSize: const Size(double.infinity, 70),
                          backgroundColor: const Color(0xFF373967),
                          foregroundColor: const Color(0xFF212348),
                        ),
                      )
                          : TextFormField(
                        key: field.key,
                        obscureText: field.isPassword,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[300],
                          hintText: field.hint,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (step.validate != null) {
                    step.validate!();
                  } else {
                    if (step.onTap != null) {
                      step.onTap!();
                    }
                  }
                },
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
                  step.buttonText,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.white),
                ),
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
      });
    }
  }

  void _showEmptyFieldDialog(BuildContext context, String fieldName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Empty Field"),
          content: Text("$fieldName cannot be empty."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showAgeRestrictionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Age Restriction"),
          content: Text("You must be at least 13 years old to register."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
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
  final GlobalKey<FormFieldState<String>>? key;
  final bool isPassword;
  final bool dateField;

  RegistrationField({
    required this.label,
    this.hint,
    this.key,
    this.isPassword = false,
    this.dateField = false,
  });
}
