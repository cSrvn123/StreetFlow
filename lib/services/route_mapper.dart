import 'package:latlong2/latlong.dart';

import '../routing/graph.dart';

class RouteMapper {
  static List<LatLng> toLatLng(
      Graph graph,
      List<int> nodeIds,
      ) {
    final points = <LatLng>[];

    for (final id in nodeIds) {
      final node = graph.getNode(id);

      if (node != null) {
        points.add(
          LatLng(
            node.lat,
            node.lon,
          ),
        );
      }
    }

    return points;
  }
}