// map_conf_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class MapConfScreen extends StatelessWidget {
  final mapController = MapController.withUserPosition(
      trackUserLocation: UserTrackingOption(
        enableTracking: true,
        unFollowUser: false,
      )
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Configuration'),
      ),
      body: OSMFlutter(
        controller: mapController,
        osmOption: OSMOption(
          userTrackingOption: const UserTrackingOption(
            enableTracking: true,
            unFollowUser: false,
          ),
          zoomOption: const ZoomOption(
            initZoom: 14, // Adjust the initial zoom level as needed
            minZoomLevel: 3,
            maxZoomLevel: 19,
            stepZoom: 1.0,
          ),
          userLocationMarker: UserLocationMaker(
            personMarker: MarkerIcon(
              icon: Icon(
                Icons.location_history_rounded,
                color: Colors.red,
                size: 48,
              ),
            ),
            directionArrowMarker: MarkerIcon(
              icon: Icon(
                Icons.double_arrow,
                size: 48,
              ),
            ),
          ),
          roadConfiguration: RoadOption(
            roadColor: Colors.yellowAccent,
          ),
          markerOption: MarkerOption(
            defaultMarker: MarkerIcon(
              icon: Icon(
                Icons.person_pin_circle,
                color: Colors.blue,
                size: 56,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
