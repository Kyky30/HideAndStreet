import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'Page/room_creation.dart';
import 'PreferencesManager.dart';

import 'package:hide_and_street/components/buttons.dart';


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
                  CustomButton
                    (
                      text: AppLocalizations.of(context)!.moins_5m,
                      onPressed: () {
                        setState(() {
                          radius -= 5;
                        });
                        },
                      scaleFactor: MediaQuery.of(context).textScaleFactor,
                  ),
                  Text(
                    AppLocalizations.of(context)!.rayon + ' : ${radius.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  CustomButton
                    (
                      text: AppLocalizations.of(context)!.plus_5m,
                      onPressed: () {
                        setState(() {
                          radius += 5;
                        });
                      },
                      scaleFactor: MediaQuery.of(context).textScaleFactor,
                  ),
                ],
              ),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!isBlindModeEnabled) ...[

                  CustomButton
                    (
                    text: AppLocalizations.of(context)!.centrer,
                    onPressed: () {
                      setState(() {
                        tapPosition = LatLng(currentPosition.latitude, currentPosition.longitude);
                      });
                    },
                    scaleFactor: MediaQuery.of(context).textScaleFactor,
                  ),
                ],

                CustomButton
                  (
                  text: AppLocalizations.of(context)!.confirmer,
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
                  scaleFactor: MediaQuery.of(context).textScaleFactor,
                ),
              ],
            ),
            const SizedBox(height: 20), // Margin between buttons and the bottom of the screen
          ],
        ),
      );
    }
  }
}
