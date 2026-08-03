import '../theme/theme_variant.dart';

/// Component Theme Foundation — the receiving structure for the 19
/// chapter compositions of the catalog (§D7).
///
/// Each chapter registers its theme-fragment builder: the recipe that
/// assembles the chapter's consumed Tokens into a themed fragment for
/// one variant. The contracts arrive with the component waves; the
/// mechanism is ready now and never changes (CLC: the contract
/// precedes any materialization).
final class ComponentThemeFoundation<TFragment> {
  final Map<String, TFragment Function(ThemeVariantId variant)> _builders = {};

  /// Registers the fragment builder of one catalog chapter. Duplicate
  /// chapters are refused — one recipe per chapter (CFU-02).
  void registerChapter(
    String chapterName,
    TFragment Function(ThemeVariantId variant) builder,
  ) {
    if (_builders.containsKey(chapterName)) {
      throw StateError(
        'Chapter "$chapterName" already has a theme fragment — one '
        'recipe per chapter.',
      );
    }
    _builders[chapterName] = builder;
  }

  /// Resolves the fragment of a chapter for a variant. Fail closed:
  /// an unknown chapter never yields a default fragment.
  TFragment fragmentFor(String chapterName, ThemeVariantId variant) {
    final builder = _builders[chapterName];
    if (builder == null) {
      throw StateError(
        'No theme fragment registered for chapter "$chapterName" — '
        'components outside the catalog do not exist (CLG-01).',
      );
    }
    return builder(variant);
  }

  bool contains(String chapterName) => _builders.containsKey(chapterName);
}
