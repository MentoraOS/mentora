class StorageService {
  final Map<String, Object?> _memory = {};

  T? read<T>(String key) {
    return _memory[key] as T?;
  }

  void write<T>(String key, T value) {
    _memory[key] = value;
  }

  bool contains(String key) {
    return _memory.containsKey(key);
  }

  void delete(String key) {
    _memory.remove(key);
  }

  void clear() {
    _memory.clear();
  }
}
