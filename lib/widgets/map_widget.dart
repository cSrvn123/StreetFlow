import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapWidget extends StatelessWidget {
  final MapController mapController;
  final LatLng currentLocation;
  final List<LatLng> routePoints;

  const MapWidget({
    super.key,
    required this.mapController,
    required this.currentLocation,
    required this.routePoints,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      key: ValueKey(
        "${currentLocation.latitude},${currentLocation.longitude}",
      ),
      mapController: mapController,
      options: MapOptions(
        initialCenter: currentLocation,
        initialZoom: 15,
      ),
      children: [
        TileLayer(
          urlTemplate:
          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.streetflow_new',
        ),

        if (routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints,
                strokeWidth: 6,
                color: Colors.blue,
              ),
            ],
          ),

        MarkerLayer(
          markers: [
            Marker(
              point: currentLocation,
              width: 50,
              height: 50,
              child: const Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 45,
              ),
            ),
          ],
        ),
      ],
    );
  }
}