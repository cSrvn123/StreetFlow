import 'package:latlong2/latlong.dart';

class PathResult {
  final List<int> nodeIds;

  final List<LatLng> points;

  final double distance;

  PathResult({
    required this.nodeIds,
    required this.points,
    required this.distance,
  });
}