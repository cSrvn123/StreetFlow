import 'package:latlong2/latlong.dart';

class RouteResult {
  final List<int> nodeIds;
  final List<LatLng> points;
  final double distance;

  RouteResult({
    required this.nodeIds,
    required this.points,
    required this.distance,
  });
}