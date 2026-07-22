import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../models/bounding_box.dart';
import '../routing/route_result.dart';

import '../services/graph_service.dart';
import '../services/location_service.dart';
import '../services/geocoding_service.dart';
import '../services/routing_service.dart';
import '../services/routing_engine.dart';
import '../services/route_mapper.dart';
import '../services/route_inspector.dart';
import '../services/route_analyzer.dart';
import '../services/astar_service.dart';
import '../services/astar_test_service.dart';
import '../widgets/route_bottom_sheet.dart';
import '../widgets/mapbox_map_widget.dart';
import '../widgets/search_panel.dart';

class HomeScreenV2 extends StatefulWidget {
  const HomeScreenV2({super.key});

  @override
  State<HomeScreenV2> createState() => _HomeScreenV2State();
}

class _HomeScreenV2State extends State<HomeScreenV2> {
  final TextEditingController fromController =
  TextEditingController();

  final TextEditingController toController =
  TextEditingController();

  MapboxMap? mapboxMap;

  LatLng currentLocation = const LatLng(
    12.9716,
    77.5946,
  );

  double? selectedDestinationLat;
  double? selectedDestinationLon;

  List<LatLng> routePoints = [];

  List<dynamic> availableRoutes = [];

  List<RouteResult> offlineRoutes = [];

  int selectedRoute = 0;
  double routeDistance = 0;
  int routeDuration = 0;

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    GraphService.instance.initialize();
  }
  Future<void> useMyLocation() async {
    final position = await LocationService.getCurrentLocation();

    if (position == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to get current location"),
        ),
      );
      return;
    }

    currentLocation = LatLng(
      position.latitude,
      position.longitude,
    );

    fromController.text =
    "${position.latitude},${position.longitude}";

    mapboxMap?.flyTo(
      CameraOptions(
        center: Point(
          coordinates: Position(
            position.longitude,
            position.latitude,
          ),
        ),
        zoom: 16,
      ),
      MapAnimationOptions(
        duration: 1500,
      ),
    );

    setState(() {});
  }
  Future<void> testStreetFlow({
    required double startLat,
    required double startLon,
  }) async {
    debugPrint("🚀 STREETFLOW ENGINE STARTED");

    if (selectedDestinationLat == null ||
        selectedDestinationLon == null) {
      debugPrint("Destination not selected.");
      return;
    }

    final routes =
    await RoutingEngine.instance.calculateMultipleRoutes(
      box: const BoundingBox(
        minLat: 12.85,
        maxLat: 13.05,
        minLon: 77.55,
        maxLon: 77.75,
      ),
      startLat: startLat,
      startLon: startLon,
      endLat: selectedDestinationLat!,
      endLon: selectedDestinationLon!,
    );

    if (routes.isEmpty) {
      debugPrint("❌ No offline routes found.");
      return;
    }

    setState(() {
      offlineRoutes = List<RouteResult>.from(routes);
      routePoints = List<LatLng>.from(routes.first.points);
      selectedRoute = 0;
    });

    debugPrint("HomeScreen rebuilt with ${offlineRoutes.length} offline routes");
    debugPrint("Hash: ${offlineRoutes.hashCode}");

    debugPrint(
        "✅ Offline routes generated: ${offlineRoutes.length}");

    for (int i = 0; i < offlineRoutes.length; i++) {
      debugPrint(
        "Route ${i + 1}: "
            "${offlineRoutes[i].distance.toStringAsFixed(0)} m",
      );
    }
  }
  Future<void> findRoute() async {
    final from = fromController.text.trim();

    if (from.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a starting location"),
        ),
      );
      return;
    }

    Map<String, double>? fromLocation;

    // Current location entered as coordinates
    if (from.contains(",")) {
      final parts = from.split(",");

      fromLocation = {
        "lat": double.parse(parts[0]),
        "lon": double.parse(parts[1]),
      };
    } else {
      fromLocation = await GeocodingService.getCoordinates(
        from,
        proximityLat: currentLocation.latitude,
        proximityLon: currentLocation.longitude,
      );
    }

    if (fromLocation == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Starting location not found"),
        ),
      );
      return;
    }

    if (selectedDestinationLat == null ||
        selectedDestinationLon == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please select a destination.",
          ),
        ),
      );
      return;
    }

    final toLocation = {
      "lat": selectedDestinationLat!,
      "lon": selectedDestinationLon!,
    };

    // Temporary Mapbox route
    final data = await RouteService.getRoutes(
      fromLocation["lat"]!,
      fromLocation["lon"]!,
      toLocation["lat"]!,
      toLocation["lon"]!,
    );

    setState(() {
      availableRoutes = data["routes"];
    });

    if (availableRoutes.isNotEmpty) {
      showSelectedRoute(0);
    }

    // Run StreetFlow engine
    await testStreetFlow(
      startLat: fromLocation["lat"]!,
      startLon: fromLocation["lon"]!,
    );
  }
  void showSelectedRoute(int index) {
    if (availableRoutes.isEmpty) return;

    final route = availableRoutes[index];

    final coordinates =
    route["geometry"]["coordinates"] as List;

    final points = coordinates
        .map<LatLng>(
          (c) => LatLng(
        (c[1] as num).toDouble(),
        (c[0] as num).toDouble(),
      ),
    )
        .toList();

    setState(() {
      selectedRoute = index;
      routePoints = points;

      // Distance in km
      routeDistance =
          (route["distance"] as num).toDouble() / 1000;

      // Duration in minutes
      routeDuration =
          ((route["duration"] as num).toDouble() / 60).round();
    });
  }

@override
Widget build(BuildContext context) {
  debugPrint(
    "BUILD -> offlineRoutes: ${offlineRoutes.length}, hash=${offlineRoutes.hashCode}",
  );
return Scaffold(
body: Stack(
children: [
  MapboxMapWidget(
    key: ValueKey(offlineRoutes.length),
    routePoints: routePoints,
    offlineRoutes: offlineRoutes,
    onMapCreated: (controller) {
      mapboxMap = controller;
    },
  ),

Positioned(
top: 16,
left: 16,
right: 16,
child: SafeArea(
child: SearchPanel(
fromController: fromController,
toController: toController,
onUseMyLocation: useMyLocation,
onFindRoute: findRoute,
currentLat: currentLocation.latitude,
currentLon: currentLocation.longitude,
onDestinationSelected: (
lat,
lon,
address,
) {
setState(() {
selectedDestinationLat = lat;
selectedDestinationLon = lon;
});
},
),
),
),

if (routePoints.isNotEmpty)
  RouteBottomSheet(
    distance: routeDistance,
    duration: routeDuration,
    onStart: () {
      debugPrint("Start Navigation pressed");
    },
  ),
],
),
);
}}