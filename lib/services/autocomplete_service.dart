import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/api_keys.dart';

class AutoCompleteService {
  static Future<List<Map<String, dynamic>>> search(
      String query,
      double latitude,
      double longitude,
      ) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final url = Uri.parse(
      "https://api.mapbox.com/geocoding/v5/mapbox.places/"
          "${Uri.encodeComponent(query)}.json"
          "?autocomplete=true"
          "&country=IN"
          "&bbox=77.35,12.80,77.85,13.20"
          "&limit=5"
          "&proximity=$longitude,$latitude"
          "&access_token=$mapboxAccessToken",
    );

    debugPrint("========================================");
    debugPrint("AUTOCOMPLETE SEARCH");
    debugPrint("Query : $query");
    debugPrint("URL   : $url");
    debugPrint("========================================");

    final response = await http.get(url);

    debugPrint("Status Code : ${response.statusCode}");

    if (response.statusCode != 200) {
      debugPrint(response.body);
      throw Exception(response.body);
    }

    final json = jsonDecode(response.body);

    debugPrint("Raw Response:");
    debugPrint(const JsonEncoder.withIndent("  ").convert(json));

    List<Map<String, dynamic>> places = [];

    if (json["features"] == null) {
      debugPrint("No features returned.");
      return places;
    }

    for (final feature in json["features"]) {
      debugPrint("--------------------------------");
      debugPrint("Name       : ${feature["text"]}");
      debugPrint("Place Name : ${feature["place_name"]}");
      debugPrint("Type       : ${feature["place_type"]}");
      debugPrint("Center     : ${feature["center"]}");

      places.add({
        "name": feature["text"] ?? "",
        "address": feature["place_name"] ?? "",
        "lat": (feature["center"][1] as num).toDouble(),
        "lon": (feature["center"][0] as num).toDouble(),
      });
    }

    debugPrint("Suggestions Found : ${places.length}");
    debugPrint("========================================");

    return places;
  }
}