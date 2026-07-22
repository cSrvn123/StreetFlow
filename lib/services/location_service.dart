import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position?> getCurrentLocation() async {
    try {
      print("Step 1: Checking location service");

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      print("Service Enabled = $serviceEnabled");

      if (!serviceEnabled) {
        print("Location service is OFF");
        return null;
      }

      print("Step 2: Checking permission");

      LocationPermission permission =
      await Geolocator.checkPermission();

      print("Current permission = $permission");

      if (permission == LocationPermission.denied) {
        print("Requesting permission...");

        permission =
        await Geolocator.requestPermission();

        print("Permission after request = $permission");
      }

      if (permission == LocationPermission.denied) {
        print("Permission denied");
        return null;
      }

      if (permission == LocationPermission.deniedForever) {
        print("Permission denied forever");
        return null;
      }

      print("Step 3: Getting location");

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      print("SUCCESS");
      print("Latitude: ${position.latitude}");
      print("Longitude: ${position.longitude}");

      return position;
    } catch (e) {
      print("ERROR: $e");
      return null;
    }
  }
}