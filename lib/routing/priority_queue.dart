

class PriorityQueue<T> {
  final List<_QueueNode<T>> _items = [];

  bool get isEmpty => _items.isEmpty;

  bool get isNotEmpty => _items.isNotEmpty;

  void enqueue(T value, double priority) {
    _items.add(_QueueNode(value, priority));
    _items.sort((a, b) => a.priority.compareTo(b.priority));
  }

  T dequeue() {
    return _items.removeAt(0).value;
  }

  void clear() {
    _items.clear();
  }
}

class _QueueNode<T> {
  final T value;
  final double priority;

  _QueueNode(this.value, this.priority);
}