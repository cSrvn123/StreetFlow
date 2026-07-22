class RouteInspector {
  static Map<String, dynamic> inspect(Map<String, dynamic> route) {
    final leg = route["legs"][0];

    final intersections = leg["steps"]
        .expand((step) => step["intersections"] as List)
        .toList();

    int primary = 0;
    int secondary = 0;
    int tertiary = 0;
    int residential = 0;
    int service = 0;
    int motorway = 0;

    for (final intersection in intersections) {
      final streets = intersection["mapbox_streets_v8"];

      if (streets == null) continue;

      final roadClass = streets["class"];

      switch (roadClass) {
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

    return {
      "distance": route["distance"],
      "duration": route["duration"],
      "primary": primary,
      "secondary": secondary,
      "tertiary": tertiary,
      "residential": residential,
      "service": service,
      "motorway": motorway,
    };
  }
}