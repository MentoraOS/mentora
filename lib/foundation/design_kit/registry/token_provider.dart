import '../theme/theme_variant.dart';
import 'token_identity.dart';
import 'token_registry.dart';

/// The Design Token Provider — the single path from a Token reference
/// to its materialized value (FDT-01/02). It binds value sets under
/// stable names (a theme is a value set — DTV-03) and resolves fail
/// closed:
///
/// - a binding for a name absent from the registry is refused
///   ("valeur hors registre");
/// - a deprecated or archived Token is refused at resolution;
/// - an unbound Token is refused — never a fallback value (FDT-05);
/// - a duplicate binding is refused.
final class DesignTokenProvider {
  final DesignTokenRegistry _registry;
  final Map<String, Map<ThemeVariantId, Object>> _bindings = {};
  final Map<String, Object> _universalBindings = {};

  DesignTokenProvider({required DesignTokenRegistry registry})
    : _registry = registry;

  /// Binds one value set (per theme variant) under a registered name.
  void bind<T extends Object>(
    TokenRef<T> ref,
    Map<ThemeVariantId, T> valuesByVariant,
  ) {
    _guardBindable(ref);
    _bindings[ref.name] = Map.of(valuesByVariant);
  }

  /// Binds a single value valid for every variant (variant-free
  /// domains: spacing relations, motion expressions…).
  void bindUniversal<T extends Object>(TokenRef<T> ref, T value) {
    _guardBindable(ref);
    _universalBindings[ref.name] = value;
  }

  void _guardBindable(TokenRef<Object> ref) {
    if (!_registry.contains(ref.name)) {
      throw StateError(
        'Cannot bind "${ref.name}": the name is not in the registry — '
        'a value outside the registry is an architecture violation '
        '(DTV-04).',
      );
    }
    if (_bindings.containsKey(ref.name) ||
        _universalBindings.containsKey(ref.name)) {
      throw StateError(
        'Token "${ref.name}" is already bound — one truth per name '
        '(UTT-03).',
      );
    }
  }

  /// Resolves the value of [ref] for [variant]. Fail closed on every
  /// refusal path — a missing value is a blocking defect, never a
  /// silent fallback (FDT-05).
  T valueOf<T extends Object>(TokenRef<T> ref, ThemeVariantId variant) {
    final identity = _registry.identityOf(ref.name);
    if (!identity.isConsumable) {
      throw StateError(
        'Token "${ref.name}" is ${identity.status.name} — a deprecated '
        'token signals itself at consumption; migration is guided, '
        'never silent (FDT-06).',
      );
    }
    final universal = _universalBindings[ref.name];
    if (universal != null) {
      return universal as T;
    }
    final byVariant = _bindings[ref.name];
    if (byVariant == null) {
      throw StateError(
        'Token "${ref.name}" has no materialization yet — an unbound '
        'token never resolves to a fallback (FDT-05).',
      );
    }
    final value = byVariant[variant];
    if (value == null) {
      throw StateError(
        'Token "${ref.name}" has no value for variant ${variant.name} — '
        'every declared variant must be served (fail closed).',
      );
    }
    return value as T;
  }

  bool isBound(String name) =>
      _bindings.containsKey(name) || _universalBindings.containsKey(name);

  Iterable<String> get boundNames =>
      [..._bindings.keys, ..._universalBindings.keys];

  /// The variants a name is bound for (empty for universal bindings).
  Set<ThemeVariantId> variantsOf(String name) =>
      _bindings[name]?.keys.toSet() ?? const {};
}
