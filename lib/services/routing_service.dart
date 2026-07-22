import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_keys.dart';

class RouteService {
  static Future<Map<String, dynamic>> getRoutes(
      double fromLat,
      double fromLon,
      double toLat,
      double toLon,
      ) async {
    final url = Uri.parse(
      "https://api.mapbox.com/directions/v5/mapbox/driving-traffic/"
          "$fromLon,$fromLat;"
          "$toLon,$toLat"
          "?alternatives=true"
          "&steps=true"
          "&overview=full"
          "&geometries=geojson"
          "&annotations=distance,duration,speed"
          "&banner_instructions=true"
          "&voice_instructions=false"
          "&access_token=$mapboxAccessToken",
    );

    debugPrint("=================================");
    debugPrint("StreetFlow Route Request");
    debugPrint(url.toString());

    final response = await http.get(url);

    debugPrint("Status Code : ${response.statusCode}");

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final data = jsonDecode(response.body);
    debugPrint("========== MAPBOX RESPONSE ==========");
    debugPrint(const JsonEncoder.withIndent('  ').convert(data));
    debugPrint("=====================================");
    debugPrint(data.toString());

    debugPrint("Routes Found : ${data["routes"].length}");

    for (int i = 0; i < data["routes"].length; i++) {
      final route = data["routes"][i];

      debugPrint("---------------------------");
      debugPrint("Route ${i + 1}");

      debugPrint(
        "Distance : ${(route["distance"] / 1000).toStringAsFixed(2)} km",
      );

      debugPrint(
        "Duration : ${(route["duration"] / 60).toStringAsFixed(1)} mins",
      );

      if (route["legs"] != null &&
          route["legs"].isNotEmpty &&
          route["legs"][0]["annotation"] != null) {
        final annotation = route["legs"][0]["annotation"];

        debugPrint(
          "Speed Samples : ${annotation["speed"]?.length ?? 0}",
        );

        debugPrint(annotation.toString());
      }
    }

    debugPrint("=================================");

    return data;
  }
}