import '../models/road_node.dart';
import '../utils/geo_utils.dart';

class NodeLocatorService {
  static int? findNearestNode({
    required Map<int, RoadNode> graph,
    required double latitude,
    required double longitude,
  }) {
    double bestDistance = double.infinity;
    int? nearestNode;

    for (final node in graph.values) {
      final distance = GeoUtils.distance(
        latitude,
        longitude,
        node.latitude,
        node.longitude,
      );

      if (distance < bestDistance) {
        bestDistance = distance;
        nearestNode = node.id;
      }
    }

    return nearestNode;
  }
}