import 'base_engine.dart';

class EngineRegistry {
  EngineRegistry._();

  static final Map<Type, BaseEngine> _engines = {};

  static void register<T extends BaseEngine>(T engine) {
    _engines[T] = engine;
  }

  static T? get<T extends BaseEngine>() {
    return _engines[T] as T?;
  }

  static List<BaseEngine> all() {
    return _engines.values.toList();
  }

  static void clear() {
    _engines.clear();
  }

  static bool contains<T extends BaseEngine>() {
    return _engines.containsKey(T);
  }
}
