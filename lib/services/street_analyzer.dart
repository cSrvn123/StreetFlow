class StreetAnalyzer {
  static Map<String, dynamic> analyzeRoute(
      Map<String, dynamic> route,
      ) {
    double distance =
    (route["distance"] as num).toDouble();

    double duration =
    (route["duration"] as num).toDouble();

    List<double> speeds = [];

    if (route["legs"] != null &&
        route["legs"].isNotEmpty) {
      final annotations =
      route["legs"][0]["annotation"];

      if (annotations != null &&
          annotations["speed"] != null) {
        speeds = (annotations["speed"] as List)
            .map((e) => (e as num).toDouble())
            .toList();
      }
    }

    double averageSpeed = 0;

    if (speeds.isNotEmpty) {
      averageSpeed =
          speeds.reduce((a, b) => a + b) /
              speeds.length;
    }

    int slowSegments = speeds
        .where((speed) => speed < 20)
        .length;

    int mediumSegments = speeds
        .where((speed) =>
    speed >= 20 && speed < 40)
        .length;

    int fastSegments = speeds
        .where((speed) => speed >= 40)
        .length;

    return {
      "distance": distance,
      "duration": duration,
      "averageSpeed": averageSpeed,
      "slowSegments": slowSegments,
      "mediumSegments": mediumSegments,
      "fastSegments": fastSegments,
    };
  }
}