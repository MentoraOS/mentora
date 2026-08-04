import '../../registry/semantic_roles.dart';

/// The official access to the registry's typography roles.
///
/// This creates NO vocabulary: a role is never invented here, it is
/// designated. The ten official behaviors are named doors onto the 27
/// admitted roles; every other admitted role stays reachable through
/// [MentoraTextRole.of]. A screen never speaks a size, a weight or a
/// color — it speaks a behavior.
final class MentoraTextRole {
  final TypographyRole role;

  const MentoraTextRole.of(this.role);

  /// The ten official behaviors — each one designating an admitted
  /// role of the catalog, never a new one.
  static const MentoraTextRole headline = MentoraTextRole.of(
    TypographyRole.hero,
  );
  static const MentoraTextRole title = MentoraTextRole.of(
    TypographyRole.pageTitle,
  );
  static const MentoraTextRole subtitle = MentoraTextRole.of(
    TypographyRole.sectionTitle,
  );
  static const MentoraTextRole body = MentoraTextRole.of(TypographyRole.body);
  static const MentoraTextRole caption = MentoraTextRole.of(
    TypographyRole.caption,
  );
  static const MentoraTextRole label = MentoraTextRole.of(
    TypographyRole.label,
  );
  static const MentoraTextRole action = MentoraTextRole.of(
    TypographyRole.action,
  );
  static const MentoraTextRole status = MentoraTextRole.of(
    TypographyRole.status,
  );
  static const MentoraTextRole ai = MentoraTextRole.of(
    TypographyRole.aiSuggestion,
  );
  static const MentoraTextRole trust = MentoraTextRole.of(
    TypographyRole.verification,
  );

  /// The official behaviors, published for the living documentation —
  /// the catalogue reads them, it never retypes them.
  static const Map<String, MentoraTextRole> officialBehaviors = {
    'headline': headline,
    'title': title,
    'subtitle': subtitle,
    'body': body,
    'caption': caption,
    'label': label,
    'action': action,
    'status': status,
    'ai': ai,
    'trust': trust,
  };

  @override
  bool operator ==(Object other) =>
      other is MentoraTextRole && other.role == role;

  @override
  int get hashCode => role.hashCode;
}
