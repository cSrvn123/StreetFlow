import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/road_edge.dart';
import '../models/road_node.dart';
import '../utils/geo_utils.dart';

class OSMGraphService {
  static Future<Map<int, RoadNode>> loadGraph({
    required double minLat,
    required double minLon,
    required double maxLat,
    required double maxLon,
  }) async {
    debugPrint("OSM: Sending Overpass API request...");

    final query = """
[out:json][timeout:25];
(
  way["highway"]
  ($minLat,$minLon,$maxLat,$maxLon);
);
(._;>;);
out body;
""";

    debugPrint("========== OSM QUERY ==========");
    debugPrint(query);
    debugPrint("==============================");

    debugPrint("STEP 1 - Before HTTP");

    try {
      final response = await http
          .post(
        Uri.parse(
          "https://overpass.kumi.systems/api/interpreter",
        ),
        headers: {
          "User-Agent":
          "StreetFlow/1.0 (contact: chinnisaravana1@gmail.com)",
          "Accept": "application/json",
        },
        body: {
          "data": query,
        },
      )
          .timeout(const Duration(seconds: 20));

      debugPrint("STEP 2 - HTTP Finished");
      debugPrint("Status: ${response.statusCode}");

      if (response.statusCode != 200) {
        debugPrint("========== RESPONSE BODY ==========");
        debugPrint(response.body);
        debugPrint("===================================");

        throw Exception(
          "Failed to load OSM data (${response.statusCode})",
        );
      }

      debugPrint("STEP 3 - Decoding JSON");

      final json = jsonDecode(response.body);

      debugPrint("OSM: JSON decoded");
      debugPrint("OSM: Elements = ${json["elements"].length}");

      final Map<int, RoadNode> graph = {};
      final Map<int, List<int>> ways = {};
      final Map<int, Map<String, dynamic>> wayInfo = {};

      // -------------------------
      // Create all nodes
      // -------------------------
      for (final element in json["elements"]) {
        if (element["type"] == "node") {
          graph[element["id"]] = RoadNode(
            id: element["id"],
            latitude: element["lat"],
            longitude: element["lon"],
          );
        }
      }

      // -------------------------
      // Store all ways
      // -------------------------
      for (final element in json["elements"]) {
        if (element["type"] == "way") {
          ways[element["id"]] =
          List<int>.from(element["nodes"]);

          wayInfo[element["id"]] = {
            "roadType":
            element["tags"]?["highway"] ?? "unknown",
            "oneWay":
            element["tags"]?["oneway"] == "yes",
            "maxSpeed":
            element["tags"]?["maxspeed"] ?? "",
          };
        }
      }

      // -------------------------
      // Connect nodes
      // -------------------------
      for (final entry in ways.entries) {
        final nodes = entry.value;

        final info = wayInfo[entry.key]!;

        final roadType = info["roadType"];
        final oneWay = info["oneWay"];

        for (int i = 0; i < nodes.length - 1; i++) {
          final from = graph[nodes[i]];
          final to = graph[nodes[i + 1]];

          if (from == null || to == null) continue;

          from.edges.add(
            RoadEdge(
              toNodeId: to.id,
              distance: GeoUtils.distance(
                from.latitude,
                from.longitude,
                to.latitude,
                to.longitude,
              ),
              roadType: roadType,
              oneWay: oneWay,
              maxSpeed: info["maxSpeed"],
            ),
          );

          if (!oneWay) {
            to.edges.add(
              RoadEdge(
                toNodeId: from.id,
                distance: GeoUtils.distance(
                  to.latitude,
                  to.longitude,
                  from.latitude,
                  from.longitude,
                ),
                roadType: roadType,
                oneWay: oneWay,
                maxSpeed: info["maxSpeed"],
              ),
            );
          }
        }
      }

      debugPrint("OSM: Graph Built");
      debugPrint("OSM: Nodes = ${graph.length}");

      return graph;
    } catch (e, stackTrace) {
      debugPrint("========== HTTP EXCEPTION ==========");
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      debugPrint("====================================");

      rethrow;
    }
  }
}