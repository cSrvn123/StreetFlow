class RouteAnalyzer {
  static Map<String, dynamic> analyze(Map<String, dynamic> route) {
    final leg = route["legs"][0];

    int primary = 0;
    int secondary = 0;
    int tertiary = 0;
    int residential = 0;
    int service = 0;
    int motorway = 0;

    double totalTurnWeight = 0;

    for (final step in leg["steps"]) {
      final intersections = step["intersections"] as List;

      for (final intersection in intersections) {
        final street =
        intersection["mapbox_streets_v8"];

        if (street != null) {
          switch (street["class"]) {
            case "motorway":
              motorway++;
              break;

            case "primary":
              primary++;
              break;

            case "secondary":
              secondary++;
              break;

            case "tertiary":
              tertiary++;
              break;

            case "residential":
              residential++;
              break;

            case "service":
              service++;
              break;
          }
        }

        totalTurnWeight +=
            (intersection["turn_weight"] ?? 0)
                .toDouble();
      }
    }

    return {
      "distance": route["distance"],
      "duration": route["duration"],
      "primary": primary,
      "secondary": secondary,
      "tertiary": tertiary,
      "residential": residential,
      "service": service,
      "motorway": motorway,
      "turnWeight": totalTurnWeight,
    };
  }
}