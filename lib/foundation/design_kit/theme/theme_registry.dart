import 'theme_variant.dart';

/// A registered theme bundle: the assembly recipe of one variant.
/// The builder produces the variant's materialization when the
/// bindings arrive — the registry itself never holds a value.
final class ThemeBundle<T> {
  final ThemeVariantId variant;
  final T Function() build;

  const ThemeBundle({required this.variant, required this.build});
}

/// The Theme Registry — one bundle per official variant, fail closed:
/// duplicates refused, unknown lookups refused.
final class DesignThemeRegistry<T> {
  final Map<ThemeVariantId, ThemeBundle<T>> _bundles = {};

  void register(ThemeBundle<T> bundle) {
    if (_bundles.containsKey(bundle.variant)) {
      throw StateError(
        'A bundle for ${bundle.variant.name} is already registered — '
        'one truth per variant.',
      );
    }
    _bundles[bundle.variant] = bundle;
  }

  ThemeBundle<T> bundleFor(ThemeVariantId variant) {
    final bundle = _bundles[variant];
    if (bundle == null) {
      throw StateError(
        'No theme bundle registered for ${variant.name} — an absent '
        'variant never falls back silently.',
      );
    }
    return bundle;
  }

  bool contains(ThemeVariantId variant) => _bundles.containsKey(variant);
}

/// The Theme Validator — refuses an incomplete registry: every
/// official variant must be served before anything renders.
final class ThemeValidator {
  const ThemeValidator();

  void validate<T>(DesignThemeRegistry<T> registry) {
    final missing = ThemeVariantId.values
        .where((variant) => !registry.contains(variant))
        .toList();
    if (missing.isNotEmpty) {
      throw StateError(
        'Theme registry incomplete — missing variants: '
        '${missing.map((v) => v.name).join(', ')} (fail closed).',
      );
    }
  }
}
