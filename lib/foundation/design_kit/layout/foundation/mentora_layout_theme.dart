import '../../components/design_kit_scope.dart';
import '../../components/text/mentora_text_role.dart';
import '../../registry/semantic_roles.dart';
import '../../registry/token_engines.dart';
import '../../tokens/layout_tokens.dart';

/// The Layout Tokens Adapter — shared by the whole layer.
///
/// It resolves the only proportions a layout owns: how the panels of a
/// dashboard breathe, and the room a layout adds around what it was
/// handed, which is none. Everything else belongs to the components
/// the foundation composes, and each of them keeps its own adapter.
///
/// There is one adapter for the whole layer, and a scan proves it.
final class MentoraLayoutTheme {
  final SpacingTokenEngine _spacing;

  const MentoraLayoutTheme({required SpacingTokenEngine spacing})
    : _spacing = spacing;

  /// Builds the adapter from the official consumption channel.
  factory MentoraLayoutTheme.fromScope(DesignKitScope scope) =>
      MentoraLayoutTheme(spacing: scope.spacing);

  /// The breathing between two panels of a dashboard — a spacing
  /// RELATION, declined by the layer's own factor.
  double get panelGap =>
      _spacing.spaceOf(SpacingRelation.respirationHierarchique) *
      layoutPanelBreathingFactor;

  /// The breathing inside one panel, between what it is about, what it
  /// says and the acts it offers.
  double get panelLineGap => _spacing.spaceOf(SpacingRelation.proximiteLiee);

  /// The room a layout adds around what it was handed: none.
  double get contentGap => layoutContentGap;

  /// A panel names its subject; it never speaks louder than the page
  /// it belongs to.
  MentoraTextRole get panelTitleRole => MentoraTextRole.subtitle;
}
