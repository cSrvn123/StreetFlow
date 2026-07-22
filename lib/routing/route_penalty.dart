class RoutePenalty {
  final Map<String, double> _penalties = {};

  double getPenalty(int from, int to) {
    return _penalties["$from-$to"] ?? 0;
  }

  void addPenalty(int from, int to, double penalty) {
    _penalties["$from-$to"] =
        (_penalties["$from-$to"] ?? 0) + penalty;
  }

  void clear() {
    _penalties.clear();
  }
}