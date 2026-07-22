import 'edge.dart';

class StreetFlowCost {
  static double calculate({
    required GraphEdge edge,
    double reusePenalty = 0,
  }) {
    return edge.distance +
        _roadTypeWeight(edge.roadType) +
        reusePenalty;
  }

  static double _roadTypeWeight(String roadType) {
    switch (roadType.toLowerCase()) {
      case "residential":
        return 0;

      case "living_street":
        return 2;

      case "service":
        return 5;

      case "tertiary":
        return 15;

      case "secondary":
        return 40;

      case "primary":
        return 80;

      case "trunk":
        return 120;

      case "motorway":
        return 180;

      default:
        return 25;
    }
  }
}