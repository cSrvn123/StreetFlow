import 'package:sqflite/sqflite.dart';

import '../models/bounding_box.dart';
import '../routing/node.dart';
import '../routing/edge.dart';
import 'graph_service.dart';
import 'package:flutter/foundation.dart';

class GraphRepository {
  GraphRepository._();

  static final GraphRepository instance = GraphRepository._();

  Database get db => GraphService.instance.database;

  Future<int> nodeCount() async {
    final result = await db.rawQuery(
      "SELECT COUNT(*) AS total FROM nodes",
    );

    return result.first["total"] as int;
  }

  Future<List<GraphNode>> loadNearbyNodes(
      BoundingBox box,
      ) async {
    final result = await db.rawQuery(
      '''
      SELECT
        id,
        lat,
        lon
      FROM nodes
      WHERE
        lat BETWEEN ? AND ?
        AND
        lon BETWEEN ? AND ?
      ''',
      [
        box.minLat,
        box.maxLat,
        box.minLon,
        box.maxLon,
      ],
    );

    return result.map((row) {
      return GraphNode(
        id: row["id"] as int,
        lat: (row["lat"] as num).toDouble(),
        lon: (row["lon"] as num).toDouble(),
      );
    }).toList();
  }

  // NEW METHOD
  Future<List<GraphNode>> loadNodesByIds(Set<int> ids) async {
    if (ids.isEmpty) return [];

    const batchSize = 500;
    final allNodes = <GraphNode>[];

    final idList = ids.toList();

    for (int i = 0; i < idList.length; i += batchSize) {
      final batch = idList.sublist(
        i,
        (i + batchSize > idList.length)
            ? idList.length
            : i + batchSize,
      );

      final placeholders = List.filled(batch.length, '?').join(',');

      final result = await db.rawQuery(
        '''
      SELECT
        id,
        lat,
        lon
      FROM nodes
      WHERE id IN ($placeholders)
      ''',
        batch,
      );

      allNodes.addAll(
        result.map(
              (row) => GraphNode(
            id: row["id"] as int,
            lat: (row["lat"] as num).toDouble(),
            lon: (row["lon"] as num).toDouble(),
          ),
        ),
      );
    }

    return allNodes;
  }
  Future<List<GraphEdge>> loadNearbyEdges(
      BoundingBox box,
      ) async {
    debugPrint("REPO 1 - loadNearbyEdges()");

    debugPrint("REPO 2 - About to execute SQL");

    final result = await db.rawQuery(
      '''
    SELECT
      e.from_node,
      e.to_node,
      e.distance,
      e.road_type,
      e.speed,
      e.oneway
    FROM edges e
    JOIN nodes n
      ON e.from_node = n.id
    WHERE
      n.lat BETWEEN ? AND ?
      AND
      n.lon BETWEEN ? AND ?
    ''',
      [
        box.minLat,
        box.maxLat,
        box.minLon,
        box.maxLon,
      ],
    );

    debugPrint("REPO 3 - SQL finished");
    debugPrint("Edges returned: ${result.length}");

    return result.map((row) {
      return GraphEdge(
        from: row["from_node"] as int,
        to: row["to_node"] as int,
        distance: (row["distance"] as num).toDouble(),
        roadType: row["road_type"]?.toString() ?? "",
        speed: row["speed"] == null
            ? 0.0
            : double.tryParse(row["speed"].toString()) ?? 0.0,
        oneWay: (row["oneway"] as int) == 1,
      );
    }).toList();
  }
}