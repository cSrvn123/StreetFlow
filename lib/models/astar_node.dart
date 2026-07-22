class AStarNode {
  final int nodeId;

  double g;

  final double h;

  int? parent;

  AStarNode({
    required this.nodeId,
    required this.g,
    required this.h,
    this.parent,
  });

  double get f => g + h;
}