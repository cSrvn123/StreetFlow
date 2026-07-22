import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapboxTestScreen extends StatefulWidget {
  const MapboxTestScreen({super.key});

  @override
  State<MapboxTestScreen> createState() => _MapboxTestScreenState();
}

class _MapboxTestScreenState extends State<MapboxTestScreen> {
  MapboxMap? mapboxMap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mapbox Test"),
      ),
      body: MapWidget(
        key: const ValueKey("mapbox"),
        styleUri: MapboxStyles.STANDARD,
        cameraOptions: CameraOptions(
          center: Point(
            coordinates: Position(77.6969, 12.9660),
          ),
          zoom: 14,
        ),
        onMapCreated: (controller) {
          mapboxMap = controller;
          debugPrint("✅ Map Created");
        },
      ),
    );
  }
}