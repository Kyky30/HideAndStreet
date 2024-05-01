import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hide_and_street/PreferencesManager.dart';

import 'package:hide_and_street/components/buttons.dart';
import 'package:hide_and_street/components/input.dart';

import 'package:hide_and_street/Page/Register/registerModel.dart';
import 'package:hide_and_street/General/alertDialogs.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  RegisterModel model = RegisterModel();


  @override
  void initState() {
    super.initState();
    _loadBlindToggle();

    model.emailController.addListener(() {
      model.emailValues = model.emailController.text;
    });
    model.pseudoController.addListener(() {
      model.pseudoValues = model.pseudoController.text;
    });
    model.passwordController.addListener(() {
      model.passwordValues = model.passwordController.text;
    });
    model.confirmPasswordController.addListener(() {
      model.confirmPasswordValues = model.confirmPasswordController.text;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    model.TexteSelctionDate = AppLocalizations.of(context)?.selection_bday ?? "";
  }


  _loadBlindToggle() async {
    bool blindToggle = await PreferencesManager.getBlindToggle();
    setState(() {
      model.toggleValue = blindToggle;
    });
  }

  _saveBlindToggle() async {
    await PreferencesManager.setBlindToggle(model.toggleValue);
  }

  List<RegistrationStep> _steps(BuildContext context) => [
    RegistrationStep(
      title: AppLocalizations.of(context)!.titre_date_naissance,
      background: 'assets/background_white.jpg',
      buttonText: AppLocalizations.of(context)!.confirmer,
      logo: 'assets/logo_connect.png',
      fields: [
        RegistrationField(label: AppLocalizations.of(context)!.datedenaissance, dateField: true, key: model.dateOfBirthKey),
      ],
      validate: () {
        if (model.selectedDate == null) {
          showEmptyFieldDialog(context);
        } else {
          var currentDate = DateTime.now();
          var age = currentDate.year - model.selectedDate!.year - ((model.selectedDate!.month > currentDate.month || (model.selectedDate!.month == currentDate.month && model.selectedDate!.day > currentDate.day)) ? 1 : 0);

          if (age < 13) {
            showAgeRestrictionDialog(context);
          } else {
            model.pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
          }
        }
      },
      onTap: () {
        var dateOfBirth = model.selectedDate;
        model.dateOfBirthValues = dateOfBirth;
        print(model.dateOfBirthValues);
      },
    ),
    RegistrationStep(
      title: AppLocalizations.of(context)!.titre_pseudo,
      background: 'assets/background_white.jpg',
      buttonText: AppLocalizations.of(context)!.confirmer,
      logo: 'assets/logo_connect.png',
      fields: [
        RegistrationField(label: AppLocalizations.of(context)!.pseudo, hint: AppLocalizations.of(context)!.pseudo, controller: model.pseudoController),
      ],
      onTap: () {
        if (model.pseudoController.text.isEmpty) {
          showEmptyFieldDialog(context);
        } else {
          model.pseudoValues = model.pseudoController.text;
          print(model.pseudoValues);
          model.pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        }
      },
    ),
    RegistrationStep(
      title: AppLocalizations.of(context)!.titre_email,
      background: 'assets/background_white.jpg',
      buttonText: AppLocalizations.of(context)!.confirmer,
      logo: 'assets/logo_connect.png',
      fields: [
        RegistrationField(label: AppLocalizations.of(context)!.mail, hint: AppLocalizations.of(context)!.exemple_email, isPassword: false, controller: model.emailController),
      ],
      onTap: () {
        if (model.emailController.text.isEmpty) {
          showEmptyFieldDialog(context);
        } else {
          model.emailValues = model.emailController.text;
          print(model.emailValues);
          model.pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
        }
      },
    ),
    RegistrationStep(
      title: AppLocalizations.of(context)!.titre_mdp,
      background: 'assets/background_white.jpg',
      buttonText: AppLocalizations.of(context)!.confirmer,
      logo: 'assets/logo_connect.png',
      fields: [
        RegistrationField(label: AppLocalizations.of(context)!.mdp, hint: AppLocalizations.of(context)!.mdp, isPassword: true, controller: model.passwordController),
        RegistrationField(label: AppLocalizations.of(context)!.mdpconfirm, hint: AppLocalizations.of(context)!.mdpconfirm, isPassword: true, controller: model.confirmPasswordController),
      ],
      onTap: () {
        if (model.passwordController.text.isEmpty || model.confirmPasswordController.text.isEmpty) {
          showEmptyFieldDialog(context);
        } else if (model.passwordController.text != model.confirmPasswordController.text) {
          showPasswordMismatchDialog(context);
        } else if (!model.isPasswordSecure(model.passwordController.text)) {
          showPasswordInsecureDialog(context);
        } else {
          model.passwordValues = model.passwordController.text;
          model.confirmPasswordValues = model.confirmPasswordController.text;
          print(model.passwordValues);
          model.pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
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
        model.blindToggleValues = model.toggleValue;
        print(model.blindToggleValues);
        _saveBlindToggle();
        model.signUp(context, model.emailValues, model.pseudoValues, model.passwordValues, model.confirmPasswordValues);
      },
    ),
  ];

  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: model.pageController,
        itemCount: _steps(context).length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return _buildStepPage(_steps(context)[index]);
        },
      ),
    );
  }



  Widget _buildStepPage(RegistrationStep step) {
    final scaleFactor = model.getScaleFactor(context);

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
                        text: model.TexteSelctionDate,
                        onPressed: () => _selectDate(context),
                        scaleFactor: MediaQuery.of(context).textScaleFactor,
                      )
                          : field.toggleField
                          ? SwitchListTile(
                        title: Text(field.label),
                        value: model.toggleValue,
                        onChanged: (value) {
                          setState(() {
                            model.toggleValue = value;
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
    if (pickedDate != null && pickedDate != model.selectedDate) {
      setState(() {
        model.selectedDate = pickedDate;
        model.TexteSelctionDate = model.selectedDate.toString().substring(0, 10);
      });
    }
  }

}

