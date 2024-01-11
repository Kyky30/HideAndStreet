import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class MapConfScreen extends StatefulWidget {
  const MapConfScreen({super.key});

  @override
  State<MapConfScreen> createState() => _MapConfScreen();
}


class _MapConfScreen extends State<MapConfScreen> {
  late Position currentPosition;
  late LatLng tapPosition;
  bool isLoading = true; // Track loading state
  late double radius;

  @override
  void initState() {
    super.initState();
    _determinePosition().then((position) {
      setState(() {
        currentPosition = position;
        tapPosition =
            LatLng(currentPosition.latitude, currentPosition.longitude);
        isLoading =
        false; // Set loading state to false when the position is determined
        radius = 150;
      });
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
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
                    setState(() {
                      tapPosition = tPosition;
                    });
                  },
                  initialCenter: LatLng(
                      currentPosition.latitude, currentPosition.longitude),
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),
                  CircleLayer(circles: [
                    CircleMarker(
                      point: tapPosition,
                      color: Colors.red.withOpacity(0.5),
                      borderColor: Colors.black,
                      borderStrokeWidth: 2,
                      useRadiusInMeter: true,
                      radius: radius, //in meters
                    ),
                  ]),
                ],
              ),
            ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {

                  },
                  style: ElevatedButton.styleFrom(
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 20,
                        cornerSmoothing: 1,
                      ),
                    ),
                    // minimumSize: const Size(double.infinity, 80),

                    backgroundColor: const Color(0xFF373967),
                    foregroundColor: const Color(0xFF212348),
                    fixedSize: Size(MediaQuery.of(context).size.width / 2 - 20, 80),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.confirmer,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins', color: Colors.white),
                  ),
                ),
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
                    // minimumSize: const Size(double.infinity, 80),

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
            ),
            const SizedBox(height: 20), //margin entre les boutons et le bas de l'écran
          ],
        ),
      );
    }
  }
}