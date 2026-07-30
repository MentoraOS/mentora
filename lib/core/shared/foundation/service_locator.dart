class ServiceLocator {
  ServiceLocator._();

  static final Map<Type, Object> _services = {};

  static void register<T extends Object>(T service) {
    _services[T] = service;
  }

  static T get<T extends Object>() {
    final service = _services[T];

    if (service == null) {
      throw Exception('Service non enregistré: $T');
    }

    return service as T;
  }

  static bool isRegistered<T extends Object>() {
    return _services.containsKey(T);
  }

  static void unregister<T extends Object>() {
    _services.remove(T);
  }

  static void clear() {
    _services.clear();
  }
}
