class RoadEdge {
  final int toNodeId;

  final double distance;

  final String roadType;

  final bool oneWay;

  final String? maxSpeed;

  RoadEdge({
    required this.toNodeId,
    required this.distance,
    required this.roadType,
    required this.oneWay,
    this.maxSpeed,
  });
}