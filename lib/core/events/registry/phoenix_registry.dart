abstract class PhoenixRegistry<T> {
  final Map<String, T> items = {};

  void register(String key, T item) {
    items[key] = item;
  }

  T? resolve(String key) {
    return items[key];
  }

  bool supports(String key) {
    return items.containsKey(key);
  }

  void unregister(String key) {
    items.remove(key);
  }

  void clear() {
    items.clear();
  }
}
