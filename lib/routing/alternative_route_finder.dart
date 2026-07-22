import 'astar.dart';
import 'graph.dart';
import 'route_result.dart';

class AlternativeRouteFinder {
  final AStar astar = AStar();

  List<RouteResult> findAlternatives({
    required Graph graph,
    required int startNode,
    required int endNode,
    int maxRoutes = 3,
  }) {
    final routes = <RouteResult>[];

    // Stores penalties for road segments
    final penalties = <String, double>{};

    for (int i = 0; i < maxRoutes; i++) {
      final route = astar.search(
        graph,
        startNode,
        endNode,
        penalties: penalties,
      );

      if (route.nodeIds.isEmpty) {
        break;
      }

      // Avoid duplicate routes
      if (routes.any((r) => _sameRoute(r, route))) {
        break;
      }

      routes.add(route);

      // Penalize every edge used in this route
      // Penalize only the middle 50% of the route
      final startIndex = route.nodeIds.length ~/ 4;
      final endIndex = (route.nodeIds.length * 3) ~/ 4;

      for (int j = startIndex; j < endIndex - 1; j++) {
        final from = route.nodeIds[j];
        final to = route.nodeIds[j + 1];

        final key = "$from-$to";

        penalties[key] = (penalties[key] ?? 0) + 300;
      }
    }

    return routes;
  }

  bool _sameRoute(RouteResult a, RouteResult b) {
    if (a.nodeIds.length != b.nodeIds.length) {
      return false;
    }

    for (int i = 0; i < a.nodeIds.length; i++) {
      if (a.nodeIds[i] != b.nodeIds[i]) {
        return false;
      }
    }

    return true;
  }
}