import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../GameUtilities/ServerUtilities.dart';
import '../GameUtilities/TimerUtilities.dart';

class ClassicMode extends StatefulWidget {
  final LatLng center; // Center of the circle
  final double radius; // Radius of the circle
  final int gameDuration; // Duration of the game
  final int hidingDuration; // Duration of the hiding phase
  final int timeStamGameStart; // Timestamp of the game start in milliseconds since epoch
  final String gameCode;
  final Map<String, bool> playerList;

  const ClassicMode({
    Key? key,
    required this.center,
    required this.radius,
    required this.gameDuration,
    required this.hidingDuration,
    required this.timeStamGameStart,
    required this.gameCode,
    required this.playerList,
  }) : super(key: key);

  @override
  State<ClassicMode> createState() => _ClassicModeState();
}

class _ClassicModeState extends State<ClassicMode> {
  late Position currentPosition;
  List<Marker> markers = [];
  TimerUtilities timerUtilities = TimerUtilities();
  late ServerUtilities serverUtilities;

  @override
  void initState() {
    super.initState();
    serverUtilities = ServerUtilities(gameCode: widget.gameCode);
    _initialize();
  }

  Future<void> _initialize() async {
    timerUtilities.startTimer(
      durationInMinutes: widget.hidingDuration,
      onEnd: onEnd,
      startTime: DateTime.fromMillisecondsSinceEpoch(widget.timeStamGameStart),
    );
    serverUtilities.addListener(_handleServerUpdates);
    List<String> playerIds = widget.playerList.keys.toList();
    var positions = await serverUtilities.getPositionForId(playerIds);
    // Traitez les positions ici
    print('Received positions: $positions');
  }

  void onEnd() {
    debugPrint('Game ended');
    // Handle the end of the timer here
  }

  void _handleServerUpdates() {
    // Handle updates received from the server
    setState(() {
      // Update the UI based on the new data from the server
    });
  }

  @override
  void dispose() {
    timerUtilities.dispose();
    serverUtilities.removeListener(_handleServerUpdates);
    serverUtilities.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TimerDisplay(
                timerUtilities: timerUtilities,
              ),
            ),
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: widget.center,
                  initialZoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),
                  CircleLayer(circles: [
                    CircleMarker(
                      point: widget.center,
                      color: Colors.blue.withOpacity(0.3),
                      borderStrokeWidth: 2,
                      borderColor: Colors.blue,
                      useRadiusInMeter: true,
                      radius: widget.radius,
                    ),
                  ]),
                  MarkerLayer(markers: markers),
                  CurrentLocationLayer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
