class TrafficAnalyzer {

  static double trafficScore(
      Map<String, dynamic> analysis,
      ) {

    int slow =
    analysis["slowSegments"];

    int medium =
    analysis["mediumSegments"];

    int fast =
    analysis["fastSegments"];

    double score = 100;

    score -= slow * 6;

    score -= medium * 2;

    score += fast * 1.5;

    if (score > 100) {
      score = 100;
    }

    if (score < 0) {
      score = 0;
    }

    return score;
  }

  static String trafficLevel(
      double score,
      ) {

    if (score >= 80) {
      return "Light";
    }

    if (score >= 60) {
      return "Moderate";
    }

    if (score >= 40) {
      return "Heavy";
    }

    return "Severe";
  }

}