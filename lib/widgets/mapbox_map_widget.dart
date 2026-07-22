import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../routing/route_result.dart';

class MapboxMapWidget extends StatefulWidget {
  final Function(MapboxMap) onMapCreated;
  final List<LatLng> routePoints;
  final List<RouteResult> offlineRoutes;

  const MapboxMapWidget({
    super.key,
    required this.onMapCreated,
    required this.routePoints,
    required this.offlineRoutes,
  });

  @override
  State<MapboxMapWidget> createState() => _MapboxMapWidgetState();
}

class _MapboxMapWidgetState extends State<MapboxMapWidget> {
  MapboxMap? mapboxMap;

  PolylineAnnotationManager? polylineManager;
  PointAnnotationManager? pointManager;

  final List<PolylineAnnotation> routeLines = [];

  PointAnnotation? startMarker;
  PointAnnotation? endMarker;

  Future<Uint8List> loadImage(String path) async {
    final data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

  @override
  void didUpdateWidget(covariant MapboxMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    debugPrint("===== didUpdateWidget =====");
    debugPrint("Old offline routes: ${oldWidget.offlineRoutes.length}");
    debugPrint("New offline routes: ${widget.offlineRoutes.length}");

    drawRoute();
  }


  Future<void> drawRoute() async {
    debugPrint("========== DRAW ROUTE ==========");
    debugPrint("offlineRoutes received: ${widget.offlineRoutes.length}");

    for (int i = 0; i < widget.offlineRoutes.length; i++) {
      debugPrint(
        "Route $i -> ${widget.offlineRoutes[i].points.length} points",
      );
    }

    if (polylineManager == null) return;

    // Remove old routes
    for (final line in routeLines) {
      await polylineManager!.delete(line);
    }
    routeLines.clear();

    if (widget.offlineRoutes.isEmpty) return;

    const colors = [
      0xFF2196F3, // Blue
      0xFF4CAF50, // Green
      0xFFFF9800, // Orange
    ];

    // Draw all routes
    for (int i = 0; i < widget.offlineRoutes.length; i++) {
      final route = widget.offlineRoutes[i];

      final coordinates = route.points
          .map((p) => Position(p.longitude, p.latitude))
          .toList();

      final line = await polylineManager!.create(
        PolylineAnnotationOptions(
          geometry: LineString(coordinates: coordinates),
          lineColor: colors[i % colors.length],
          lineWidth: i == 0 ? 6.0 : 4.0,
        ),
      );

      routeLines.add(line);
    }

    await drawMarkers();

    final firstRoute = widget.offlineRoutes.first;

    final firstCoordinates = firstRoute.points
        .map((p) => Position(p.longitude, p.latitude))
        .toList();

    await mapboxMap!.flyTo(
      CameraOptions(
        center: Point(
          coordinates:
          firstCoordinates[firstCoordinates.length ~/ 2],
        ),
        zoom: 14,
      ),
      MapAnimationOptions(
        duration: 1500,
      ),
    );
  }
  Future<void> drawMarkers() async {
    if (pointManager == null) return;

    if (widget.offlineRoutes.isEmpty) return;

    final route = widget.offlineRoutes.first;

    if (route.points.length < 2) return;

    if (startMarker != null) {
      await pointManager!.delete(startMarker!);
    }

    if (endMarker != null) {
      await pointManager!.delete(endMarker!);
    }

    final startImage =
    await loadImage("assets/images/start_pin.png");

    final endImage =
    await loadImage("assets/images/end_pin.png");

    final start = route.points.first;
    final end = route.points.last;

    startMarker = await pointManager!.create(
      PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(
            start.longitude,
            start.latitude,
          ),
        ),
        image: startImage,
        iconSize: 0.15,
      ),
    );

    endMarker = await pointManager!.create(
      PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(
            end.longitude,
            end.latitude,
          ),
        ),
        image: endImage,
        iconSize: 0.15,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      key: const ValueKey("mapbox"),
      styleUri: MapboxStyles.STANDARD,
      cameraOptions: CameraOptions(
        center: Point(
          coordinates: Position(
            80.0454724,
            12.8268333,
          ),
        ),
        zoom: 15,
      ),
      onMapCreated: (controller) async {
        mapboxMap = controller;

        widget.onMapCreated(controller);

        polylineManager = await mapboxMap!.annotations
            .createPolylineAnnotationManager();

        pointManager = await mapboxMap!.annotations
            .createPointAnnotationManager();

        await mapboxMap!.location.updateSettings(
          LocationComponentSettings(
            enabled: true,
            pulsingEnabled: true,
          ),
        );

        await drawRoute();
      },
    );
  }
}