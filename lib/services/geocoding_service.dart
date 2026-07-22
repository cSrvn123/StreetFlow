import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../constants/api_keys.dart';

class GeocodingService {

  // Search multiple places
  static Future<List<Map<String, dynamic>>> searchPlaces(
      String place,
      ) async {
    final url = Uri.parse(
      "https://api.mapbox.com/geocoding/v5/mapbox.places/"
          "${Uri.encodeComponent(place)}.json"
          "?country=IN"
          "&limit=10"
          "&access_token=$mapboxAccessToken",
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final data = jsonDecode(response.body);

    List<Map<String, dynamic>> places = [];

    if (data["features"] == null) return places;

    for (final feature in data["features"]) {
      places.add({
        "name": feature["place_name"],
        "lat": feature["center"][1].toDouble(),
        "lon": feature["center"][0].toDouble(),
      });
    }

    return places;
  }

  // Returns the nearest place to the supplied location
  static Future<Map<String, double>?> getCoordinates(
      String place, {
        double? proximityLat,
        double? proximityLon,
      }) async {

    final places = await searchPlaces(place);

    if (places.isEmpty) return null;

    if (proximityLat != null && proximityLon != null) {

      final from = LatLng(proximityLat, proximityLon);

      places.sort((a, b) {

        final da = distance(
          from,
          LatLng(a["lat"], a["lon"]),
        );

        final db = distance(
          from,
          LatLng(b["lat"], b["lon"]),
        );

        return da.compareTo(db);

      });
    }

    return {
      "lat": places.first["lat"],
      "lon": places.first["lon"],
    };
  }

  static double distance(
      LatLng a,
      LatLng b,
      ) {
    return const Distance().as(
      LengthUnit.Kilometer,
      a,
      b,
    );
  }
}