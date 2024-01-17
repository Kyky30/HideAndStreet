import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'home.dart';
import 'l10n/l10n.dart';
import 'login.dart';
import 'shop.dart';
import 'account_settings.dart';


import 'package:material_symbols_icons/symbols.dart';

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
      home: FutureBuilder<Widget?>(
        future: autoLogin(),
        builder: (BuildContext context, AsyncSnapshot<Widget?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            return snapshot.data ?? const MyHomePage();
          }
        },
      ),
      routes: {
        '/home': (context) => const MyHomePage(),
        '/account_settings': (context) => AccountSettingsPage(),
        '/login': (context) => LoginPage(),
      },
      supportedLocales: L10n.all,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
    );
  }

  Future<Widget> autoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? loggedIn = prefs.getBool('loggedin');

    if (loggedIn == true) {
      return const MyHomePage();
    } else {
      return LoginPage(); // Return the LoginPage widget
    }
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1;

  final List<Widget> _tabs = [
    const ShopPage(),
    const HomePage(),
    AccountSettingsPage(),
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
            icon: const Icon(Symbols.shopping_cart_rounded, fill: 1, weight: 700, grade: 200, opticalSize: 24),
            label: AppLocalizations.of(context)!.boutique,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Symbols.home_rounded, fill: 1, weight: 700, grade: 200, opticalSize: 24),
            label: AppLocalizations.of(context)!.accueil,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Symbols.settings_account_box_rounded, fill: 1, weight: 700, grade: 200, opticalSize: 24),
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
