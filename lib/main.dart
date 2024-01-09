// main.dart
import 'package:flutter/material.dart';

import 'package:hide_and_street/home.dart';
import 'package:hide_and_street/shop.dart';
import 'package:hide_and_street/account_settings.dart';

import 'package:material_symbols_icons/symbols.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Bottom Navigation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.black,
            fill: 1,
            weight: 700,
            opticalSize: 24),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1; // Commence par la page d'accueil (index 1).

  final List<Widget> _tabs = [
    ShopPage(),
    HomePage(),
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
            icon: Icon(Symbols.shopping_cart_rounded, fill: 1, weight: 700, grade: 200, opticalSize: 24 ),
            label: 'Boutique',
          ),
          BottomNavigationBarItem(
            icon: Icon( Symbols.home_rounded, fill: 1, weight: 700, grade: 200, opticalSize: 24 ),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Symbols.settings_account_box_rounded,fill: 1, weight: 700, grade: 200, opticalSize: 24 ),
            label: 'Compte',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
