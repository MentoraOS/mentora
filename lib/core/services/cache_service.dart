class CacheService {
  final Map<String, Object> _cache = {};

  void set<T extends Object>(String key, T value) {
    _cache[key] = value;
  }

  T? get<T extends Object>(String key) {
    final value = _cache[key];

    if (value == null) {
      return null;
    }

    return value as T;
  }

  bool contains(String key) {
    return _cache.containsKey(key);
  }

  void remove(String key) {
    _cache.remove(key);
  }

  void clear() {
    _cache.clear();
  }
}
