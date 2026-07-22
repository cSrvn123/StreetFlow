class PriorityNode implements Comparable<PriorityNode> {
  final int nodeId;

  final double priority;

  PriorityNode({
    required this.nodeId,
    required this.priority,
  });

  @override
  int compareTo(PriorityNode other) {
    return priority.compareTo(other.priority);
  }
}