class GraphEdge {
  final int from;
  final int to;
  final double distance;
  final String roadType;
  final double speed;
  final bool oneWay;

  GraphEdge({
    required this.from,
    required this.to,
    required this.distance,
    required this.roadType,
    required this.speed,
    required this.oneWay,
  });
}