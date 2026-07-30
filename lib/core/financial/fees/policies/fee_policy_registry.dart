import 'fee_policy.dart';

class FeePolicyRegistry {
  final Map<String, FeePolicy> _policies = {};

  void register(FeePolicy policy) {
    final normalizedKey = _normalizeKey(policy.key);
    final existing = _policies[normalizedKey];

    if (existing != null && existing.runtimeType != policy.runtimeType) {
      throw StateError(
        'Fee policy $normalizedKey is already registered '
        'with another implementation',
      );
    }

    _policies[normalizedKey] = policy;
  }

  FeePolicy resolve(String key) {
    final normalizedKey = _normalizeKey(key);
    final policy = _policies[normalizedKey];

    if (policy == null) {
      throw StateError('No fee policy registered for $normalizedKey');
    }

    return policy;
  }

  bool supports(String key) {
    return _policies.containsKey(_normalizeKey(key));
  }

  void unregister(String key) {
    _policies.remove(_normalizeKey(key));
  }

  void clear() {
    _policies.clear();
  }

  int get length => _policies.length;

  String _normalizeKey(String key) {
    final normalized = key.trim().toLowerCase();

    if (normalized.isEmpty) {
      throw ArgumentError.value(key, 'key', 'Fee policy key cannot be empty');
    }

    return normalized;
  }
}
