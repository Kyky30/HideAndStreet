import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class GameMap extends StatefulWidget {
  const GameMap({super.key});

  @override
  State<GameMap> createState() => _GameMapState();
}

class _GameMapState extends State<GameMap> {
  late Position currentPosition;
  late LatLng tapPosition;
  bool isLoading = true; // Track loading state
  late double radius;
  int countdownSeconds = 600;

  @override
  void initState() {
    super.initState();
    _determinePosition().then((position) {
      setState(() {
        currentPosition = position;
        tapPosition = LatLng(currentPosition.latitude, currentPosition.longitude);
        isLoading = false; // Set loading state to false when the position is determined
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
    }
    else {
      return Scaffold(
        body: Column(
          children :[

            CountdownTimer(
              endTime: DateTime.now().millisecondsSinceEpoch + countdownSeconds * 1000,
              widgetBuilder: (_, CurrentRemainingTime? time) {
                if (time == null) {
                  return const Text("00:00",
                      style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                );

                }
                return Text(
                  '${time.min}:${time.sec}',
                  style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                );
              },
            ),
            Expanded(child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(
                    currentPosition.latitude, currentPosition.longitude),
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
                    radius: radius, //in meters
                  ),
                ]),
              ],
            ),
            ),
          ]
        ),
      );
    }
  }
}
