// main.dart
import 'package:flutter/material.dart';

import 'package:hide_and_street/home.dart';
import 'package:hide_and_street/l10n/l10n.dart';
import 'package:hide_and_street/shop.dart';
import 'package:hide_and_street/account_settings.dart';
import 'package:hide_and_street/login.dart';

import 'package:material_symbols_icons/symbols.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon Application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),  // Définissez votre page LoginPage comme page d'accueil
      routes: {
        '/home': (context) => const MyHomePage(),  // Ajoutez cette ligne si vous avez une page home.dart
      },
      supportedLocales: L10n.all,
      //locale: const Locale('fr'),
      localizationsDelegates: const [
         AppLocalizations.delegate,
         GlobalMaterialLocalizations.delegate,
         GlobalWidgetsLocalizations.delegate,
         GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // Choisissez la meilleure langue en fonction des langues prises en charge
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1; // Commence par la page d'accueil (index 1).

  final List<Widget> _tabs = [
    const ShopPage(),
    const HomePage(),
    const AccountSettingsPage(username: "sperme",email: "a@a.fr"),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Symbols.shopping_cart_rounded, fill: 1, weight: 700, grade: 200, opticalSize: 24 ),
            label: AppLocalizations.of(context)!.boutique,
          ),
          BottomNavigationBarItem(
            icon: const Icon( Symbols.home_rounded, fill: 1, weight: 700, grade: 200, opticalSize: 24 ),
            label: AppLocalizations.of(context)!.accueil,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Symbols.settings_account_box_rounded,fill: 1, weight: 700, grade: 200, opticalSize: 24 ),
            label: AppLocalizations.of(context)!.profil,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedFontSize: 20,
        unselectedFontSize: 18,
        iconSize: 30,
      ),
    );
  }
}



