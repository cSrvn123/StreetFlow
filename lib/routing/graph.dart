import 'node.dart';
import 'edge.dart';

class Graph {
  final Map<int, GraphNode> nodes = {};

  final Map<int, List<GraphEdge>> adjacency = {};

  void addNode(GraphNode node) {
    nodes[node.id] = node;
  }

  void addEdge(GraphEdge edge) {
    // Forward edge
    adjacency.putIfAbsent(edge.from, () => []);
    adjacency[edge.from]!.add(edge);

    // Reverse edge for two-way roads
    if (!edge.oneWay) {
      adjacency.putIfAbsent(edge.to, () => []);

      adjacency[edge.to]!.add(
        GraphEdge(
          from: edge.to,
          to: edge.from,
          distance: edge.distance,
          roadType: edge.roadType,
          speed: edge.speed,
          oneWay: edge.oneWay,
        ),
      );
    }
  }

  GraphNode? getNode(int id) {
    return nodes[id];
  }

  List<GraphEdge> neighbors(int id) {
    return adjacency[id] ?? [];
  }

  Iterable<GraphNode> get allNodes => nodes.values;
}