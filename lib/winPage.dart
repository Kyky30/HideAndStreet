import 'package:flutter/material.dart';
import 'package:hide_and_street/map_conf_screen.dart';
import 'package:hide_and_street/room_joining.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class winPage extends StatefulWidget {
  final bool isSeekerWin;

  const winPage({required this.isSeekerWin});

  @override
  _WinPageState createState() => _WinPageState();
}

class _WinPageState extends State<winPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            AppLocalizations.of(context)!.game_over,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.black),
          ),
          Text(
            widget.isSeekerWin ? AppLocalizations.of(context)!.victoire_chercheur : AppLocalizations.of(context)!.victoire_cacheur,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w500, fontFamily: 'Poppins', color: Colors.blue),
          ),
          const Spacer(),
          Center(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MapConfScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 20,
                        cornerSmoothing: 1,
                      ),
                    ),
                    minimumSize: Size(MediaQuery.of(context).size.width - 30, 80),
                    backgroundColor: const Color(0xFF373967),
                    foregroundColor: const Color(0xFF212348),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.creerpartie,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RoomJoiningPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 20,
                        cornerSmoothing: 1,
                      ),
                    ),
                    minimumSize: Size(MediaQuery.of(context).size.width - 30, 80),
                    backgroundColor: const Color(0xFF373967),
                    foregroundColor: const Color(0xFF212348),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.rejoindrepartie,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
