import '../core/identifiable.dart';

/// Shared in-memory list used by entity repositories (DRY CRUD).
class InMemoryStore<T extends Identifiable> {
  InMemoryStore(List<T> initial) : _items = List<T>.from(initial);

  final List<T> _items;

  List<T> getAll() => List<T>.unmodifiable(_items);

  T? findById(String id) {
    for (final T item in _items) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  void add(T item) => _items.add(item);

  bool update(T item) {
    final int index = _items.indexWhere((T existing) => existing.id == item.id);
    if (index < 0) {
      return false;
    }
    _items[index] = item;
    return true;
  }

  bool remove(String id) {
    final int before = _items.length;
    _items.removeWhere((T item) => item.id == id);
    return _items.length < before;
  }

  void removeWhere(bool Function(T item) test) => _items.removeWhere(test);

  int indexWhere(bool Function(T item) test) => _items.indexWhere(test);

  void removeAt(int index) => _items.removeAt(index);
}
