import 'package:flutter/material.dart';

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
