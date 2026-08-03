/// The official dependency container of the foundation.
///
/// No wild singleton, no global variable: an instance is built by the
/// bootstrap, handed down explicitly, and scoped to the application.
/// Registrations are lazy singletons; resolution is fail closed — a
/// missing dependency is a StateError, never a null or a default.
final class FoundationServices {
  final Map<Type, Object Function()> _factories = {};
  final Map<Type, Object> _instances = {};

  /// Registers the single factory for [T]. Duplicates are refused:
  /// two truths for one dependency is an architecture defect.
  void register<T extends Object>(T Function() factory) {
    if (_factories.containsKey(T)) {
      throw StateError('A factory for $T is already registered.');
    }
    _factories[T] = factory;
  }

  /// Resolves [T], building it on first use. Fail closed.
  T get<T extends Object>() {
    final existing = _instances[T];
    if (existing != null) {
      return existing as T;
    }
    final factory = _factories[T];
    if (factory == null) {
      throw StateError(
        'No factory registered for $T — every dependency enters through '
        'the official bootstrap.',
      );
    }
    final instance = factory() as T;
    _instances[T] = instance;
    return instance;
  }

  bool contains<T extends Object>() => _factories.containsKey(T);
}
