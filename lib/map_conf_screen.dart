import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:figma_squircle/figma_squircle.dart';

import 'room_creation.dart';
import 'PreferencesManager.dart';

class MapConfScreen extends StatefulWidget {
  const MapConfScreen({Key? key}) : super(key: key);

  @override
  State<MapConfScreen> createState() => _MapConfScreenState();
}

class _MapConfScreenState extends State<MapConfScreen> {
  late Position currentPosition;
  late LatLng tapPosition;
  bool isLoading = true; // Track loading state
  late double radius;
  bool isBlindModeEnabled = true;

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  Future<void> _initializeState() async {
    await _loadBlindModeStatus();
    await _determinePosition().then((position) {
      setState(() {
        currentPosition = position;
        tapPosition = LatLng(currentPosition.latitude, currentPosition.longitude);
        isLoading = false;
        radius = 150;
      });
    });
  }

  Future<void> _loadBlindModeStatus() async {
    isBlindModeEnabled = await PreferencesManager.getBlindToggle();
    setState(() {});
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, don't continue accessing the position.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, request permissions again.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever.
      return Future.error('Location permissions are permanently denied.');
    }

    // Permissions are granted, continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.configmaptitle)),
        body: Column(
          children: [
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  onTap: (_, tPosition) {
                    if (!isBlindModeEnabled) {
                      setState(() {
                        tapPosition = tPosition;
                      });
                    }
                  },
                  initialCenter: LatLng(currentPosition.latitude, currentPosition.longitude),
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),
                  CurrentLocationLayer(),
                  CircleLayer(circles: [
                    CircleMarker(
                      point: tapPosition,
                      color: Colors.grey.withOpacity(0.5),
                      borderColor: Colors.black,
                      borderStrokeWidth: 2,
                      useRadiusInMeter: true,
                      radius: radius, // in meters
                    ),
                  ]),
                ],
              ),
            ),
            if (!isBlindModeEnabled) ...[
              // Display the Slider when blind mode is disabled
              Slider(
                value: radius,
                onChanged: (newRadius) {
                  setState(() {
                    radius = newRadius;
                  });
                },
                min: 15,
                max: 1000,
              ),
            ] else ...[
              // Display the row with radius value and buttons when blind mode is enabled
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        radius -= 5;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 20,
                          cornerSmoothing: 1,
                        ),
                      ),
                      backgroundColor: const Color(0xFF373967),
                      foregroundColor: const Color(0xFF212348),
                      fixedSize: Size(MediaQuery.of(context).size.width / 3.5 - 20, 80),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.moins_5m,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.rayon + ' : ${radius.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        radius += 5;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 20,
                          cornerSmoothing: 1,
                        ),
                      ),
                      backgroundColor: const Color(0xFF373967),
                      foregroundColor: const Color(0xFF212348),
                      fixedSize: Size(MediaQuery.of(context).size.width / 3.5 - 20, 80),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.plus_5m,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoomCreationPage(
                          initialTapPosition: tapPosition,
                          initialRadius: radius,
                        ),
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
                    backgroundColor: const Color(0xFF373967),
                    foregroundColor: const Color(0xFF212348),
                    fixedSize: Size(MediaQuery.of(context).size.width / 2 - 20, 80),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.confirmer,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.white),
                  ),
                ),
                if (!isBlindModeEnabled) ...[
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        tapPosition = LatLng(currentPosition.latitude, currentPosition.longitude);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 20,
                          cornerSmoothing: 1,
                        ),
                      ),
                      backgroundColor: const Color(0xFF373967),
                      foregroundColor: const Color(0xFF212348),
                      fixedSize: Size(MediaQuery.of(context).size.width / 2 - 20, 80),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.centrer,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.white),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20), // Margin between buttons and the bottom of the screen
          ],
        ),
      );
    }
  }
}
