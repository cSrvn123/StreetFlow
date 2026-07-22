import 'package:latlong2/latlong.dart';

import '../models/astar_node.dart';
import '../models/path_result.dart';
import '../models/priority_node.dart';
import '../models/road_node.dart';
import '../utils/geo_utils.dart';

class AStarService {
  static PathResult? findPath({
    required Map<int, RoadNode> graph,
    required int startNode,
    required int endNode,
    Map<String, double>? edgePenalties,
  }) {
    final openList = <PriorityNode>[];
    final closedSet = <int>{};
    final nodes = <int, AStarNode>{};

    final start = graph[startNode];
    final goal = graph[endNode];

    if (start == null || goal == null) {
      return null;
    }

    final startAStar = AStarNode(
      nodeId: startNode,
      g: 0,
      h: heuristic(start, goal),
    );

    nodes[startNode] = startAStar;

    openList.add(
      PriorityNode(
        nodeId: startNode,
        priority: startAStar.f,
      ),
    );

    while (openList.isNotEmpty) {
      openList.sort();

      final current = openList.removeAt(0);

      if (current.nodeId == endNode) {
        break;
      }

      closedSet.add(current.nodeId);

      final currentRoad = graph[current.nodeId]!;

      for (final edge in currentRoad.edges) {
        if (closedSet.contains(edge.toNodeId)) {
          continue;
        }

        final neighbour = graph[edge.toNodeId]!;

        final penalty = getEdgePenalty(
          current.nodeId,
          edge.toNodeId,
          edgePenalties,
        );

        final tentativeG =
            nodes[current.nodeId]!.g +
                edge.distance +
                penalty;

        final existing = nodes[edge.toNodeId];

        if (existing == null || tentativeG < existing.g) {
          final astarNode = AStarNode(
            nodeId: edge.toNodeId,
            g: tentativeG,
            h: heuristic(neighbour, goal),
            parent: current.nodeId,
          );

          nodes[edge.toNodeId] = astarNode;

          openList.add(
            PriorityNode(
              nodeId: edge.toNodeId,
              priority: astarNode.f,
            ),
          );
        }
      }
    }

    if (!nodes.containsKey(endNode)) {
      return null;
    }

    final nodeIds = <int>[];
    final points = <LatLng>[];

    int? current = endNode;

    while (current != null) {
      nodeIds.insert(0, current);

      final road = graph[current]!;

      points.insert(
        0,
        LatLng(
          road.latitude,
          road.longitude,
        ),
      );

      current = nodes[current]?.parent;
    }

    return PathResult(
      nodeIds: nodeIds,
      points: points,
      distance: nodes[endNode]!.g,
    );
  }

  // ===========================
  // NEW: Generate Multiple Routes
  // ===========================
  static List<PathResult> findMultiplePaths({
    required Map<int, RoadNode> graph,
    required int startNode,
    required int endNode,
    int numberOfRoutes = 5,
  }) {
    final routes = <PathResult>[];
    final penalties = <String, double>{};

    for (int i = 0; i < numberOfRoutes; i++) {
      final route = findPath(
        graph: graph,
        startNode: startNode,
        endNode: endNode,
        edgePenalties: penalties,
      );

      if (route == null) {
        break;
      }

      routes.add(route);

      // Penalize every edge used in this route
      for (int j = 0; j < route.nodeIds.length - 1; j++) {
        final from = route.nodeIds[j];
        final to = route.nodeIds[j + 1];

        final key = "$from->$to";

        penalties[key] = (penalties[key] ?? 0) + 100;
      }
    }

    return routes;
  }

  static double getEdgePenalty(
      int fromNode,
      int toNode,
      Map<String, double>? penalties,
      ) {
    if (penalties == null) return 0;

    final key = "$fromNode->$toNode";

    return penalties[key] ?? 0;
  }

  static double heuristic(
      RoadNode a,
      RoadNode b,
      ) {
    return GeoUtils.distance(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );
  }
}