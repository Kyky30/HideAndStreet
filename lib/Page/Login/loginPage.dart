import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../components/buttons.dart';
import '../../components/input.dart';
import '../../password_forgoten.dart';
import '../../Page/Register/registerPage.dart';
import 'loginController.dart';

class LoginPage extends StatelessWidget {
  final LoginController _controller = LoginController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.fromLTRB(15, 0.1 * MediaQuery.of(context).size.height, 15, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/logo_connect.png',
                        width: 0.8 * MediaQuery.of(context).size.width,
                        fit: BoxFit.contain,
                      ),
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
                      Text(
                        AppLocalizations.of(context)!.mail,
                        style: TextStyle(fontSize: 0.05 * MediaQuery.of(context).size.width, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Container(
                          height: 0.08 * MediaQuery.of(context).size.height,
                          width: 0.9 * MediaQuery.of(context).size.width,
                          child: CustomTextField(
                            hintText: AppLocalizations.of(context)!.mail,
                            controller: _emailController,
                            scaleFactor: MediaQuery.of(context).textScaleFactor,
                          ),
                        ),
                      ),
                      SizedBox(height: 0.02 * MediaQuery.of(context).size.height),
                      Text(
                        AppLocalizations.of(context)!.mdp,
                        style: TextStyle(fontSize: 0.05 * MediaQuery.of(context).size.width, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Container(
                          height: 0.08 * MediaQuery.of(context).size.height,
                          width: 0.9 * MediaQuery.of(context).size.width,
                          child: CustomTextField(
                            hintText: AppLocalizations.of(context)!.mdp,
                            controller: _passwordController,
                            obscureText: true,
                            scaleFactor: MediaQuery.of(context).textScaleFactor,
                          ),
                        ),
                      ),
                      SizedBox(height: 0.02 * MediaQuery.of(context).size.height),
                      buildLoginButton(context),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Positioned(
                bottom: 0.04 * MediaQuery.of(context).size.height,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RegisterPage(),
                                  ),
                                );
                              },
                              child: Text(
                                AppLocalizations.of(context)!.inscription,
                                style: TextStyle(color: Colors.black, fontSize: 0.04 * MediaQuery.of(context).size.width, fontWeight: FontWeight.w600, fontFamily: 'Poppins', backgroundColor: Colors.white),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ForgotenPassword(),
                                  ),
                                );
                              },
                              child: Text(
                                AppLocalizations.of(context)!.mdpoublie,
                                style: TextStyle(color: Colors.black, fontSize: 0.04 * MediaQuery.of(context).size.width, fontWeight: FontWeight.w600, fontFamily: 'Poppins', backgroundColor: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLoginButton(BuildContext context) {
    return CustomButton(
      text: AppLocalizations.of(context)!.connexion,
      onPressed: () {
        _controller.login(
          context,
          _emailController.text,
          _passwordController.text,
        );
      },
      scaleFactor: MediaQuery.of(context).textScaleFactor,
    );
  }

// Ajoutez les autres méthodes de création de widgets ici

}
