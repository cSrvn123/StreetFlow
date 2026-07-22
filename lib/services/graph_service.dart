import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class GraphService {
  GraphService._();

  static final GraphService instance = GraphService._();

  Database? _database;

  Future<void> initialize() async {
    print("GRAPH SERVICE 1 - initialize()");

    if (_database != null) {
      print("GRAPH SERVICE 2 - Already initialized");
      return;
    }

    final databasesPath = await getDatabasesPath();

    final dbPath = join(
      databasesPath,
      "streetflow_graph.db",
    );

    print("GRAPH SERVICE 3 - DB Path: $dbPath");

    final exists = await databaseExists(dbPath);

    print("GRAPH SERVICE 4 - Exists: $exists");

    if (!exists) {
      print("GRAPH SERVICE 5 - Copying database");

      final data = await rootBundle.load(
        "assets/database/streetflow_graph.db",
      );

      await Directory(dirname(dbPath)).create(recursive: true);

      await File(dbPath).writeAsBytes(
        data.buffer.asUint8List(),
        flush: true,
      );
    }

    print("GRAPH SERVICE 6 - Opening database");

    _database = await openDatabase(
      dbPath,
      readOnly: true,
    );

    print("GRAPH SERVICE 7 - Database opened");
  }

  Database get database {
    if (_database == null) {
      throw Exception("GraphService not initialized");
    }

    return _database!;
  }
}