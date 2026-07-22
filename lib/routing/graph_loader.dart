import '../models/bounding_box.dart';
import '../services/graph_repository.dart';
import 'graph.dart';
import 'package:flutter/foundation.dart';

class GraphLoader {
  Future<Graph> loadGraph(
      BoundingBox box,
      ) async {
    debugPrint("GRAPH LOADER 1");

    final graph = Graph();

    debugPrint("GRAPH LOADER 2 - Loading edges");

    final edges =
    await GraphRepository.instance.loadNearbyEdges(box);

    debugPrint("GRAPH LOADER 3 - Edges loaded: ${edges.length}");

    final nodeIds = <int>{};

    for (final edge in edges) {
      nodeIds.add(edge.from);
      nodeIds.add(edge.to);
    }

    debugPrint("GRAPH LOADER 4 - Node ids: ${nodeIds.length}");

    final nodes =
    await GraphRepository.instance.loadNodesByIds(nodeIds);

    debugPrint("GRAPH LOADER 5 - Nodes loaded: ${nodes.length}");

    for (final node in nodes) {
      graph.addNode(node);
    }

    debugPrint("GRAPH LOADER 6 - Nodes added");

    for (final edge in edges) {
      graph.addEdge(edge);
    }

    debugPrint("GRAPH LOADER 7 - Graph ready");

    return graph;
  }
}