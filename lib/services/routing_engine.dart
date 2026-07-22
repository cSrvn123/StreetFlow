import 'package:flutter/foundation.dart';

import '../models/bounding_box.dart';
import '../routing/astar.dart';
import '../routing/graph.dart';
import '../routing/graph_loader.dart';
import '../routing/nearest_node.dart';
import '../routing/route_result.dart';
import 'route_mapper.dart';
import '../routing/alternative_route_finder.dart';

class RoutingEngine {
  RoutingEngine._();

  static final RoutingEngine instance = RoutingEngine._();

  final GraphLoader _loader = GraphLoader();
  final NearestNodeFinder _finder = NearestNodeFinder();
  final AStar _astar = AStar();
  final AlternativeRouteFinder _alternativeFinder =
  AlternativeRouteFinder();

  Graph? _lastGraph;

  Graph? get graph => _lastGraph;

  Future<RouteResult> calculateRoute({
    required BoundingBox box,
    required double startLat,
    required double startLon,
    required double endLat,
    required double endLon,
  }) async {
    _lastGraph = await _loader.loadGraph(box);

    final Graph graph = _lastGraph!;

    final startNode = _finder.findNearest(
      graph,
      startLat,
      startLon,
    );

    final endNode = _finder.findNearest(
      graph,
      endLat,
      endLon,
    );

    if (startNode == null || endNode == null) {
      return RouteResult(
        nodeIds: [],
        points: const [],
        distance: 0,
      );
    }

    return _astar.search(
      graph,
      startNode.id,
      endNode.id,
    );
  }

  Future<List<RouteResult>> calculateMultipleRoutes({
    required BoundingBox box,
    required double startLat,
    required double startLon,
    required double endLat,
    required double endLon,
  }) async {
    debugPrint("========== ROUTING ENGINE ==========");
    debugPrint("STEP 1 - Loading graph");

    _lastGraph = await _loader.loadGraph(box);

    debugPrint("STEP 2 - Graph loaded");

    final Graph graph = _lastGraph!;

    debugPrint("STEP 3 - Finding nearest nodes");

    final startNode = _finder.findNearest(
      graph,
      startLat,
      startLon,
    );

    final endNode = _finder.findNearest(
      graph,
      endLat,
      endLon,
    );

    debugPrint(
      "Start Node: ${startNode?.id}, End Node: ${endNode?.id}",
    );

    if (startNode == null || endNode == null) {
      debugPrint("❌ Could not find nearest nodes.");
      return [];
    }

    debugPrint("STEP 4 - Finding alternative routes");

    final routes = _alternativeFinder.findAlternatives(
      graph: graph,
      startNode: startNode.id,
      endNode: endNode.id,
      maxRoutes: 3,
    );

    debugPrint(
      "STEP 5 - Alternative routes found: ${routes.length}",
    );

    final mappedRoutes = routes.map((route) {
      final points = RouteMapper.toLatLng(
        graph,
        route.nodeIds,
      );

      debugPrint(
        "Route -> Nodes: ${route.nodeIds.length}, "
            "Points: ${points.length}, "
            "Distance: ${route.distance}",
      );

      return RouteResult(
        nodeIds: route.nodeIds,
        points: points,
        distance: route.distance,
      );
    }).toList();

    debugPrint(
      "STEP 6 - Returning ${mappedRoutes.length} mapped routes",
    );
    debugPrint("===================================");

    return mappedRoutes;
  }
}