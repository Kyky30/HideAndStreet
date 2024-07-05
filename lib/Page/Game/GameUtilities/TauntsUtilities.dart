import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../GameUtilities/ServerUtilities.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class TauntsUtilities extends ChangeNotifier {
  bool _isDrawerOpen = false;
  AudioPlayer player = AudioPlayer();
  final ServerUtilities serverUtilities;
  final Position position;

  bool get isDrawerOpen => _isDrawerOpen;

  TauntsUtilities({required this.serverUtilities, required this.position});

  void toggleDrawer() {
    _isDrawerOpen = !_isDrawerOpen;
    notifyListeners();
  }

  void tauntSonoreCourt() {
    HapticFeedback.heavyImpact();
    player.setSourceAsset("Patate.mp3");
    player.play(player.source!);
  }

  void updatePosition(Position position) {
    position = position;
  }
}

class TauntsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TauntsUtilities>(
      builder: (context, tauntsUtilities, child) {
        return Row(
          children: [
            if (tauntsUtilities.isDrawerOpen)
              Container(
                height: 65, // Adjust the height as needed
                width: MediaQuery.of(context).size.width * 0.375,
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(15.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Color(0xff565ab7),
                      ),
                      child: const Icon(
                        Symbols.share_location_rounded,
                        fill: 1,
                        weight: 700,
                        grade: 200,
                        opticalSize: 24,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        tauntsUtilities.serverUtilities
                            .setPlayerOutOfZone(tauntsUtilities.position);
                      },
                    ),
                    SizedBox(width: 5),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(15.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Color(0xff565ab7),
                      ),
                      child: const Icon(
                        Symbols.celebration_rounded,
                        fill: 1,
                        weight: 700,
                        grade: 200,
                        opticalSize: 24,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () async {
                        tauntsUtilities.tauntSonoreCourt();
                      },
                    ),
                  ],
                ),
              ),
            ElevatedButton(
              child: Icon(
                tauntsUtilities.isDrawerOpen ? Symbols.close_rounded : Symbols.sports_rounded,
                fill: 1,
                weight: 700,
                grade: 200,
                opticalSize: 24,
                color: Colors.white,
                size: 25,
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Color(0xFF373967),
              ),
              onPressed: () {
                tauntsUtilities.toggleDrawer();
              },

            ),
          ],
        );
      },
    );
  }
}
