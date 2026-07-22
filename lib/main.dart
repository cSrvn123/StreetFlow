import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'services/graph_service.dart';
import 'screens/home_screen_v2.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint("STEP 1");

  // Initialize the StreetFlow graph database
  await GraphService.instance.initialize();

  debugPrint("GRAPH DATABASE INITIALIZED");

  const String mapboxAccessToken = "YOUR_MAPBOX_ACCESS_TOKEN";

  debugPrint("STEP 2");

  runApp(const StreetFlowApp());

  debugPrint("STEP 3");
}
class StreetFlowApp extends StatelessWidget {
  const StreetFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("STEP 4");

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StreetFlow',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreenV2(),
    );
  }
}