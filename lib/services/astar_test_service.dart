import '../models/road_edge.dart';
import '../models/road_node.dart';

class AStarTestService {
  static Map<int, RoadNode> buildTestGraph() {
    final graph = <int, RoadNode>{};

    graph[1] = RoadNode(
      id: 1,
      latitude: 0,
      longitude: 0,
    );

    graph[2] = RoadNode(
      id: 2,
      latitude: 0,
      longitude: 1,
    );

    graph[3] = RoadNode(
      id: 3,
      latitude: 0,
      longitude: 2,
    );

    graph[4] = RoadNode(
      id: 4,
      latitude: 1,
      longitude: 0,
    );

    graph[5] = RoadNode(
      id: 5,
      latitude: 1,
      longitude: 2,
    );

    // A → B
    graph[1]!.edges.add(
      RoadEdge(
        toNodeId: 2,
        distance: 10,
        roadType: "primary",
        oneWay: false,
      ),
    );

    // B → C
    graph[2]!.edges.add(
      RoadEdge(
        toNodeId: 3,
        distance: 10,
        roadType: "primary",
        oneWay: false,
      ),
    );

    // A → D
    graph[1]!.edges.add(
      RoadEdge(
        toNodeId: 4,
        distance: 25,
        roadType: "secondary",
        oneWay: false,
      ),
    );

    // D → E
    graph[4]!.edges.add(
      RoadEdge(
        toNodeId: 5,
        distance: 10,
        roadType: "secondary",
        oneWay: false,
      ),
    );

    // E → C
    graph[5]!.edges.add(
      RoadEdge(
        toNodeId: 3,
        distance: 10,
        roadType: "secondary",
        oneWay: false,
      ),
    );

    return graph;
  }
}