import 'package:flutter/foundation.dart';

import '../models/path_result.dart';

import 'astar_service.dart';
import 'node_locator_service.dart';
import 'osm_graph_service.dart';

class StreetFlowEngine {
  static Future<List<PathResult>> findStreetRoutes({
    required double startLat,
    required double startLon,
    required double endLat,
    required double endLon,
  }) async {
    debugPrint("========== STREETFLOW ENGINE ==========");
    debugPrint("Loading OSM Graph...");

    final graph = await OSMGraphService.loadGraph(
      minLat: startLat < endLat ? startLat - 0.003 : endLat - 0.003,
      minLon: startLon < endLon ? startLon - 0.003 : endLon - 0.003,
      maxLat: startLat > endLat ? startLat + 0.003 : endLat + 0.003,
      maxLon: startLon > endLon ? startLon + 0.003 : endLon + 0.003,
    );

    debugPrint("Graph Nodes: ${graph.length}");

    final startNode = NodeLocatorService.findNearestNode(
      graph: graph,
      latitude: startLat,
      longitude: startLon,
    );

    final endNode = NodeLocatorService.findNearestNode(
      graph: graph,
      latitude: endLat,
      longitude: endLon,
    );

    debugPrint("Start Node: $startNode");
    debugPrint("End Node: $endNode");

    if (startNode == null || endNode == null) {
      debugPrint("❌ Failed to find nearest nodes");
      return [];
    }

    // Generate multiple routes
    final routes = AStarService.findMultiplePaths(
      graph: graph,
      startNode: startNode,
      endNode: endNode,
      numberOfRoutes: 5,
    );

    debugPrint("=====================================");
    debugPrint("Generated ${routes.length} routes");

    for (int i = 0; i < routes.length; i++) {
      debugPrint(
        "Route ${i + 1}: "
            "${routes[i].nodeIds.length} nodes | "
            "${routes[i].distance.toStringAsFixed(2)} meters",
      );
    }

    debugPrint("=====================================");

    if (routes.isEmpty) {
      debugPrint("❌ No routes found");
      return [];
    }

    return routes;
  }
}