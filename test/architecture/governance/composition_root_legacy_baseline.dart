/// Legacy composition debt captured during
/// Sprint -1.3 / Lot A / A.2.1.
///
/// IMPORTANT:
///
/// These entries are NOT approved architecture.
///
/// They exist only so that governance can be enabled before the canonical
/// MentoraCompositionRoot is introduced.
///
/// A.2.2 must remove these entries from runtime code naturally by moving
/// composition into lib/composition/.
///
/// New composition outside approved roots is forbidden.
abstract final class CompositionRootLegacyBaseline {
  static const Set<String> violations = {};
}
