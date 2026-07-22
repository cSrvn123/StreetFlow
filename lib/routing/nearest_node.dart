import 'dart:math';

import 'graph.dart';
import 'node.dart';

class NearestNodeFinder {
  GraphNode? findNearest(
      Graph graph,
      double lat,
      double lon,
      ) {
    GraphNode? nearest;

    double bestDistance = double.infinity;

    for (final node in graph.allNodes) {
      final d = sqrt(
        pow(node.lat - lat, 2) +
            pow(node.lon - lon, 2),
      );

      if (d < bestDistance) {
        bestDistance = d;
        nearest = node;
      }
    }

    return nearest;
  }
}