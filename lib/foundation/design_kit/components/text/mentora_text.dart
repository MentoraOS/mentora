import 'package:flutter/material.dart';

import '../../registry/semantic_roles.dart';
import '../design_kit_scope.dart';
import 'mentora_text_role.dart';
import 'mentora_text_theme.dart';

/// The official Mentora text — the only text of the product.
///
/// It says a behavior, never a style: no size, no weight, no family,
/// no color ever crosses its API. The style comes from the admitted
/// typography Token of the designated role, through the
/// [DesignKitScope].
///
/// It re-decides nothing that already has an authority:
/// - the reading direction belongs to [Directionality], fed by the
///   localization delegates — one direction authority, never two;
/// - the font scale belongs to the application's [MediaQuery] scaler,
///   fed by the Accessibility Engine — it is never applied twice;
/// - the strings belong to the application (Localization Engine): the
///   component composes none.
final class MentoraText extends StatelessWidget {
  final String data;
  final MentoraTextRole role;

  /// A semantic color override — a ROLE, never a color. Absent, the
  /// text speaks with the color its typography Token carries.
  final ColorRole? color;

  final int? maxLines;

  /// Overflow is controlled by default: a text is never silently
  /// clipped.
  final TextOverflow overflow;

  final TextAlign? align;

  /// Selection is offered where the content is meant to be taken away
  /// (a reference, an identifier) — never by default.
  final bool selectable;

  /// What the screen reader announces when it must differ from the
  /// displayed string (an abbreviation, a formatted value).
  final String? semanticsLabel;

  /// For a string already announced by its container — the same
  /// information is never announced twice.
  final bool excludeFromSemantics;

  const MentoraText(
    this.data, {
    super.key,
    required this.role,
    this.color,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.align,
    this.selectable = false,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = MentoraTextTheme.fromScope(DesignKitScope.of(context));
    final style = theme.styleOf(role, color: color);

    final Widget rendered = selectable
        ? SelectableText(
            data,
            style: style,
            maxLines: maxLines,
            textAlign: align,
            semanticsLabel: semanticsLabel,
          )
        : Text(
            data,
            style: style,
            maxLines: maxLines,
            overflow: overflow,
            textAlign: align,
            semanticsLabel: semanticsLabel,
          );

    return excludeFromSemantics
        ? ExcludeSemantics(child: rendered)
        : rendered;
  }
}
