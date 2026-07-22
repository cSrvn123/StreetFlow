import 'graph.dart';
import 'priority_queue.dart';
import 'route_result.dart';
import 'streetflow_cost.dart';

class AStar {
  double _heuristic(Graph graph, int from, int to) {
    final a = graph.getNode(from);
    final b = graph.getNode(to);

    if (a == null) {
      print("❌ Missing node: $from");
      return 0;
    }

    if (b == null) {
      print("❌ Missing node: $to");
      return 0;
    }

    final dx = a.lat - b.lat;
    final dy = a.lon - b.lon;

    return (dx * dx + dy * dy) * 111000;
  }
  RouteResult search(
      Graph graph,
      int start,
      int goal, {
        Map<String, double> penalties = const {},
      }) {
    final frontier = PriorityQueue<int>();

    frontier.enqueue(start, 0);

    final cameFrom = <int, int?>{};
    final costSoFar = <int, double>{};

    cameFrom[start] = null;
    costSoFar[start] = 0;

    while (frontier.isNotEmpty) {
      final current = frontier.dequeue();

      if (current == goal) {
        break;
      }

      for (final edge in graph.neighbors(current)) {
        final edgeKey = "${edge.from}-${edge.to}";

        // Get penalty for this road segment

        final penalty = penalties[edgeKey] ?? 0.0;

// StreetFlow cost
        final edgeCost = StreetFlowCost.calculate(
          edge: edge,
          reusePenalty: penalty,
        );

        final newCost =
            costSoFar[current]! +
                edgeCost;

        if (!costSoFar.containsKey(edge.to) ||
            newCost < costSoFar[edge.to]!) {
          costSoFar[edge.to] = newCost;

          final priority =
              newCost + _heuristic(graph, edge.to, goal);

          frontier.enqueue(
            edge.to,
            priority,
          );

          cameFrom[edge.to] = current;
        }
      }
    }

    if (!cameFrom.containsKey(goal)) {
      return RouteResult(
        nodeIds: const [],
        points: const [],
        distance: 0,
      );
    }

    final path = <int>[];

    int? current = goal;

    while (current != null) {
      path.add(current);
      current = cameFrom[current];
    }

    return RouteResult(
      nodeIds: path.reversed.toList(),
      points: const [],
      distance: costSoFar[goal]!,
    );
  }
}