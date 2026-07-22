import 'road_edge.dart';
class RoadNode {
  final int id;

  final double latitude;
  final double longitude;

  final List<RoadEdge> edges;

  RoadNode({
    required this.id,
    required this.latitude,
    required this.longitude,
    List<RoadEdge>? edges,
  }) : edges = edges ?? [];
}