import 'dart:ui' show Color;

import 'package:flutter/widgets.dart' show TextStyle;

import '../../appearance/appearance_engine.dart';
import '../../registry/semantic_roles.dart';
import '../../registry/token_engines.dart';
import '../../theme/theme_variant.dart';
import '../design_kit_scope.dart';
import 'mentora_text_role.dart';

/// The Text Tokens Adapter — the only place where a typography role
/// becomes a style. It consumes the bound engines exclusively: it
/// never holds a size, a weight, a color or a family, and it never
/// builds a style of its own invention.
final class MentoraTextTheme {
  final TypographyTokenEngine _typography;
  final ColorTokenEngine _colors;
  final AppearanceState _appearance;
  final ThemeVariantId _variant;

  const MentoraTextTheme({
    required TypographyTokenEngine typography,
    required ColorTokenEngine colors,
    required AppearanceState appearance,
    required ThemeVariantId variant,
  }) : _typography = typography,
       _colors = colors,
       _appearance = appearance,
       _variant = variant;

  /// Builds the adapter from the official consumption channel.
  factory MentoraTextTheme.fromScope(DesignKitScope scope) {
    return MentoraTextTheme(
      typography: scope.typography,
      colors: scope.colors,
      appearance: scope.appearance,
      variant: scope.variant,
    );
  }

  /// Resolves a behavior into its admitted role's style, for the
  /// current theme variant. High contrast needs no special case here:
  /// the variant already carries it down to the bound Tokens.
  ///
  /// Reading Comfort has exactly one official value today
  /// ([ReadingComfortPreference]); the day a second one is admitted
  /// upstream, it lands in this adapter — never in a widget. A
  /// governance test guards that claim.
  TextStyle styleOf(MentoraTextRole role, {ColorRole? color}) {
    final style = _typography.styleOf(role.role, _variant);
    if (color == null) return style;
    return style.copyWith(color: _colors.colorOf(color, _variant));
  }

  /// The declared reading comfort — served as it is admitted, never
  /// interpreted by a widget.
  ReadingComfortPreference get readingComfort => _appearance.readingComfort;

  Color colorOf(ColorRole role) => _colors.colorOf(role, _variant);
}
