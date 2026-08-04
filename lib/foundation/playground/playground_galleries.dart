import 'package:flutter/material.dart';

import '../design_kit/components/button/mentora_button.dart';
import '../design_kit/components/button/mentora_button_style.dart';
import '../design_kit/components/card/mentora_card.dart';
import '../design_kit/components/card/mentora_card_style.dart';
import '../design_kit/registry/semantic_roles.dart';
import '../design_kit/registry/token_engines.dart';
import '../design_kit/responsive/responsive_engine.dart';
import '../design_kit/theme/theme_variant.dart';
import '../design_kit/tokens/surface_elevation_tokens.dart';
import 'playground_labels.dart';

/// Shared section chrome for every gallery.
final class GallerySection extends StatelessWidget {
  final String title;
  final Widget child;

  const GallerySection({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textTheme.titleMedium),
        child,
        Divider(color: Theme.of(context).dividerColor),
      ],
    );
  }
}

/// The 27 color roles — always the role, never a raw color.
final class ColorGallery extends StatelessWidget {
  final ColorTokenEngine colors;
  final ThemeVariantId variant;

  const ColorGallery({
    super.key,
    required this.colors,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GallerySection(
      title: colorGalleryTitle,
      child: Wrap(
        children: [
          for (final role in ColorRole.values)
            Padding(
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    key: Key('color-swatch-${role.name}'),
                    width: kMinInteractiveDimension,
                    height: kMinInteractiveDimension,
                    color: colors.colorOf(role, variant),
                  ),
                  Text(role.name, style: textTheme.labelSmall),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// The 27 typography roles — the role name rendered in its own style.
final class TypographyGallery extends StatelessWidget {
  final TypographyTokenEngine typography;
  final ThemeVariantId variant;

  const TypographyGallery({
    super.key,
    required this.typography,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: typographyGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final role in TypographyRole.values)
            Text(
              role.name,
              key: Key('typography-sample-${role.name}'),
              style: typography.styleOf(role, variant),
            ),
        ],
      ),
    );
  }
}

/// The 8 spacing relations — bars sized by the relation, labeled by
/// the relation, never by the value.
final class SpacingGallery extends StatelessWidget {
  final SpacingTokenEngine spacing;

  const SpacingGallery({super.key, required this.spacing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GallerySection(
      title: spacingGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final relation in SpacingRelation.values)
            Row(
              children: [
                Container(
                  key: Key('spacing-bar-${relation.name}'),
                  width: spacing.spaceOf(relation) * 4,
                  height: spacing.spaceOf(SpacingRelation.proximiteLiee),
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: spacing.spaceOf(SpacingRelation.proximiteLiee)),
                Text(relation.name, style: theme.textTheme.labelSmall),
              ],
            ),
        ],
      ),
    );
  }
}

/// The five official surfaces.
final class SurfaceGallery extends StatelessWidget {
  final SurfaceTokenEngine surfaces;
  final SpacingTokenEngine spacing;
  final ThemeVariantId variant;

  const SurfaceGallery({
    super.key,
    required this.surfaces,
    required this.spacing,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GallerySection(
      title: surfaceGalleryTitle,
      child: Wrap(
        children: [
          for (final role in SurfaceRole.values)
            Container(
              key: Key('surface-tile-${role.name}'),
              width: spacing.spaceOf(SpacingRelation.espaceFocus) * 3,
              height: spacing.spaceOf(SpacingRelation.espaceFocus),
              color: surfaces.surfaceOf(role, variant),
              alignment: Alignment.center,
              child: Text(
                role.name,
                style: theme.textTheme.labelSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}

/// The four elevation meanings — properties of meaning, never heights.
final class ElevationGallery extends StatelessWidget {
  final ElevationTokenEngine<ElevationExpression> elevation;
  final ThemeVariantId variant;

  const ElevationGallery({
    super.key,
    required this.elevation,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GallerySection(
      title: elevationGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final meaning in ElevationMeaning.values)
            Builder(
              builder: (context) {
                final expression = elevation.expressionOf(meaning, variant);
                return Text(
                  '${meaning.name} — blocks: ${expression.blocksBelow}, '
                  'dims: ${expression.dimsScene}, '
                  'exclusive: ${expression.isExclusive}',
                  key: Key('elevation-${meaning.name}'),
                  style: textTheme.bodySmall,
                );
              },
            ),
        ],
      ),
    );
  }
}

/// The official Buttons catalogue — every variant, every size and the
/// application phases of the REAL component.
final class ButtonGallery extends StatefulWidget {
  const ButtonGallery({super.key});

  @override
  State<ButtonGallery> createState() => _ButtonGalleryState();
}

final class _ButtonGalleryState extends State<ButtonGallery> {
  final MentoraButtonController _loading = MentoraButtonController();
  final MentoraButtonController _success = MentoraButtonController();
  final MentoraButtonController _error = MentoraButtonController();

  @override
  void initState() {
    super.initState();
    _loading.beginLoading();
    _success.showSuccess();
    _error.showError();
  }

  @override
  void dispose() {
    _loading.dispose();
    _success.dispose();
    _error.dispose();
    super.dispose();
  }

  void _noop() {}

  @override
  Widget build(BuildContext context) {
    return GallerySection(
      title: buttonGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final variant in MentoraButtonVariant.values)
            MentoraButton(
              key: Key('button-variant-${variant.name}'),
              label: variant.name,
              onPressed: _noop,
              variant: variant,
            ),
          for (final size in MentoraButtonSize.values)
            MentoraButton(
              key: Key('button-size-${size.name}'),
              label: size.name,
              onPressed: _noop,
              size: size,
            ),
          const MentoraButton(
            key: Key('button-state-disabled'),
            label: 'disabled',
            onPressed: null,
          ),
          MentoraButton(
            key: const Key('button-state-loading'),
            label: 'loading',
            onPressed: _noop,
            controller: _loading,
          ),
          MentoraButton(
            key: const Key('button-state-success'),
            label: 'success',
            onPressed: _noop,
            controller: _success,
          ),
          MentoraButton(
            key: const Key('button-state-error'),
            label: 'error',
            onPressed: _noop,
            controller: _error,
          ),
        ],
      ),
    );
  }
}

/// The official Cards catalogue — every variant and every state of the
/// REAL component. The laboratory duplicates nothing: what is shown
/// here is exactly what the screens will use.
///
/// The interaction states (pressed, focused, hovered) are shown as
/// live cards: the engineer presses, tabs and hovers them to verify
/// the expression — a catalogue of claims would prove nothing.
final class CardGallery extends StatefulWidget {
  const CardGallery({super.key});

  @override
  State<CardGallery> createState() => _CardGalleryState();
}

final class _CardGalleryState extends State<CardGallery> {
  final MentoraCardController _loading = MentoraCardController();
  final MentoraCardController _error = MentoraCardController();

  @override
  void initState() {
    super.initState();
    _loading.beginLoading();
    _error.showError();
  }

  @override
  void dispose() {
    _loading.dispose();
    _error.dispose();
    super.dispose();
  }

  /// The act served to every inviting sample of the catalogue: the
  /// laboratory observes the expression, it performs no business.
  void _noop() {}

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    Widget caption(String text) => Text(text, style: textTheme.labelSmall);

    return GallerySection(
      title: cardGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final variant in MentoraCardVariant.values)
            MentoraCard(
              key: Key('card-variant-${variant.name}'),
              variant: variant,
              onTap: variant == MentoraCardVariant.interactive ? _noop : null,
              child: caption(variant.name),
            ),
          // The states, on the official interactive variant.
          MentoraCard(
            key: const Key('card-state-idle'),
            child: caption(MentoraCardState.idle.name),
          ),
          MentoraCard(
            key: const Key('card-state-pressed'),
            variant: MentoraCardVariant.interactive,
            onTap: _noop,
            child: caption(MentoraCardState.pressed.name),
          ),
          MentoraCard(
            key: const Key('card-state-focused'),
            variant: MentoraCardVariant.interactive,
            onTap: _noop,
            child: caption(MentoraCardState.focused.name),
          ),
          MentoraCard(
            key: const Key('card-state-hovered'),
            variant: MentoraCardVariant.interactive,
            onTap: _noop,
            child: caption(MentoraCardState.hovered.name),
          ),
          MentoraCard(
            key: const Key('card-state-selected'),
            variant: MentoraCardVariant.selected,
            child: caption(MentoraCardState.selected.name),
          ),
          MentoraCard(
            key: const Key('card-state-disabled'),
            variant: MentoraCardVariant.outlined,
            enabled: false,
            child: caption(MentoraCardState.disabled.name),
          ),
          MentoraCard(
            key: const Key('card-state-loading'),
            variant: MentoraCardVariant.outlined,
            controller: _loading,
            child: caption(MentoraCardState.loading.name),
          ),
          MentoraCard(
            key: const Key('card-state-error'),
            variant: MentoraCardVariant.outlined,
            controller: _error,
            child: caption(MentoraCardState.error.name),
          ),
        ],
      ),
    );
  }
}

/// The responsive contexts — each representative size classified live
/// by the official engine.
final class ResponsiveGallery extends StatelessWidget {
  final ResponsiveEngine responsive;

  const ResponsiveGallery({super.key, required this.responsive});

  static const Map<String, Size> _representativeSizes = {
    'wearable': Size(250, 280),
    'phone': Size(390, 844),
    'foldable': Size(650, 840),
    'tablet': Size(800, 1280),
    'desktop': Size(1600, 1050),
    'tv': Size(3840, 2160),
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GallerySection(
      title: responsiveGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in _representativeSizes.entries)
            Text(
              '${entry.key} → ${responsive.resolve(entry.value).name}',
              key: Key('responsive-${entry.key}'),
              style: textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}
