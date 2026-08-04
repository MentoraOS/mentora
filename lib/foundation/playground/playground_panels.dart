import 'package:flutter/material.dart';

import '../design_kit/appearance/appearance_engine.dart';
import '../design_kit/components/button/mentora_button.dart';
import '../design_kit/components/button/mentora_button_style.dart';
import '../design_kit/motion/motion_engine.dart';
import '../design_kit/registry/binding_integrity_engine.dart';
import '../design_kit/registry/token_provider.dart';
import '../design_kit/registry/token_registry.dart';
import '../design_kit/registry/token_validator.dart';
import '../design_kit/theme/theme_engine.dart';
import '../design_kit/theme/theme_variant.dart';
import '../design_kit/tokens/token_catalog_phase1.dart';
import 'playground_galleries.dart';
import 'playground_labels.dart';

/// Token Coverage Panel — fed automatically by the integrity engine.
final class TokenCoveragePanel extends StatelessWidget {
  final BindingIntegrityReport report;

  const TokenCoveragePanel({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final percent = report.expectedTotal == 0
        ? 0
        : (report.boundTotal * 100 ~/ report.expectedTotal);
    return GallerySection(
      title: coveragePanelTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in report.perDomain.entries)
            Text(
              '${entry.key} : ${entry.value.bound} / ${entry.value.expected}',
              key: Key('coverage-${entry.key}'),
              style: textTheme.bodySmall,
            ),
          Text(
            '$coverageLabel : ${report.boundTotal} / ${report.expectedTotal}'
            ' — $percent %',
            key: const Key('coverage-total'),
            style: textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}

/// Binding Integrity Panel — every violation class, live.
final class BindingIntegrityPanel extends StatelessWidget {
  final BindingIntegrityReport report;
  final int unknownTokens;
  final int missingBindings;

  const BindingIntegrityPanel({
    super.key,
    required this.report,
    required this.unknownTokens,
    required this.missingBindings,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GallerySection(
      title: integrityPanelTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$hardcodedLabel : ${report.hardcodedValues}',
            key: const Key('integrity-hardcoded'),
            style: textTheme.bodySmall,
          ),
          Text(
            '$deprecatedLabel : ${report.deprecatedTokens.length}',
            key: const Key('integrity-deprecated'),
            style: textTheme.bodySmall,
          ),
          Text(
            '$orphanLabel : ${report.orphanTokens.length}',
            key: const Key('integrity-orphans'),
            style: textTheme.bodySmall,
          ),
          Text(
            '$unknownLabel : $unknownTokens',
            key: const Key('integrity-unknown'),
            style: textTheme.bodySmall,
          ),
          Text(
            '$missingLabel : $missingBindings',
            key: const Key('integrity-missing'),
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Theme Inspector — the resolved variant and its scheme, built by the
/// Theme Engine alone.
final class ThemeInspectorPanel extends StatelessWidget {
  final ThemeEngine themeEngine;
  final ThemeVariantId variant;

  const ThemeInspectorPanel({
    super.key,
    required this.themeEngine,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    final theme = themeEngine.themeForVariant(variant);
    final textTheme = Theme.of(context).textTheme;
    final scheme = theme.colorScheme;
    final swatches = <String, Color>{
      'primary': scheme.primary,
      'secondary': scheme.secondary,
      'error': scheme.error,
      'surface': scheme.surface,
      'outline': scheme.outline,
    };
    return GallerySection(
      title: themeInspectorTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            variant.name,
            key: const Key('inspector-variant'),
            style: textTheme.titleSmall,
          ),
          Wrap(
            children: [
              for (final entry in swatches.entries)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      key: Key('inspector-${entry.key}'),
                      width: kMinInteractiveDimension,
                      height: kMinInteractiveDimension,
                      color: entry.value,
                    ),
                    Text(entry.key, style: textTheme.labelSmall),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Runtime Verification — runs the official validators live. Fail
/// closed: any failure is displayed prominently, never swallowed.
final class RuntimeVerificationPanel extends StatelessWidget {
  final DesignTokenRegistry registry;
  final DesignTokenProvider provider;

  const RuntimeVerificationPanel({
    super.key,
    required this.registry,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String verdict;
    var healthy = true;
    try {
      const TokenValidator().validate(
        registry: registry,
        provider: provider,
        expectedComplete: {
          for (final identity in phase1Identities()) identity.name,
        },
      );
      const BindingIntegrityEngine().verify(
        registry: registry,
        provider: provider,
      );
      verdict = runtimeHealthy;
    } catch (failure) {
      healthy = false;
      verdict = '$failure';
    }
    return GallerySection(
      title: runtimePanelTitle,
      child: Text(
        verdict,
        key: const Key('runtime-verdict'),
        style: theme.textTheme.bodySmall?.copyWith(
          color: healthy ? null : theme.colorScheme.error,
        ),
      ),
    );
  }
}

/// Motion Preview — replays each intention with its official duration,
/// declined by the live Motion preference.
final class MotionPreviewPanel extends StatelessWidget {
  final MotionEngine motion;
  final AppearanceState appearance;
  final int replayTick;
  final VoidCallback onReplay;

  const MotionPreviewPanel({
    super.key,
    required this.motion,
    required this.appearance,
    required this.replayTick,
    required this.onReplay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expanded = replayTick.isEven;
    return GallerySection(
      title: motionGalleryTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final intention in MotionIntention.values)
            Row(
              children: [
                AnimatedContainer(
                  key: Key('motion-${intention.name}'),
                  duration: motion.durationFor(intention, appearance),
                  curve: motion.curveFor(intention),
                  width: expanded
                      ? kMinInteractiveDimension * 2
                      : kMinInteractiveDimension,
                  height: theme.textTheme.labelSmall?.fontSize ??
                      kMinInteractiveDimension / 4,
                  color: theme.colorScheme.secondary,
                ),
                Text(intention.name, style: theme.textTheme.labelSmall),
              ],
            ),
          MentoraButton(
            key: const Key('motion-replay'),
            label: '${motionGalleryTitle.split(' ').first} ▶',
            onPressed: onReplay,
            variant: MentoraButtonVariant.text,
            size: MentoraButtonSize.small,
          ),
        ],
      ),
    );
  }
}
