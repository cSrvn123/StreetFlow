class TrafficService {

  static List<Map<String, dynamic>> getRoutes() {

    return [

      {
        "name": "Route A",

        "distance": 2.8,

        "time": 15,

        "traffic": "Heavy",

        "emoji": "🔴",

        "score": 68,

        "road":
        "HAL Old Airport Road",
      },

      {
        "name": "Route B",

        "distance": 3.2,

        "time": 10,

        "traffic": "Moderate",

        "emoji": "🟡",

        "score": 91,

        "road":
        "Yemalur Main Road",
      },

      {
        "name": "Route C",

        "distance": 3.7,

        "time": 12,

        "traffic": "Light",

        "emoji": "🟢",

        "score": 84,

        "road":
        "Inner Streets",
      },

    ];
  }
}