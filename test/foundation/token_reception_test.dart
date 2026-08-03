import 'dart:io';

import 'package:flutter/material.dart' show Brightness;
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/bootstrap/app_bootstrap.dart';
import 'package:mentora/foundation/core/logging/foundation_logger.dart';
import 'package:mentora/foundation/design_kit/registry/binding_integrity_engine.dart';
import 'package:mentora/foundation/design_kit/registry/bound_token_engines.dart';
import 'package:mentora/foundation/design_kit/registry/semantic_roles.dart';
import 'package:mentora/foundation/design_kit/registry/token_provider.dart';
import 'package:mentora/foundation/design_kit/registry/token_registry.dart';
import 'package:mentora/foundation/design_kit/theme/theme_engine.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';
import 'package:mentora/foundation/design_kit/tokens/design_tokens.dart';
import 'package:mentora/foundation/design_kit/tokens/surface_elevation_tokens.dart';
import 'package:mentora/foundation/design_kit/tokens/token_bindings_phase1.dart';
import 'package:mentora/foundation/design_kit/tokens/token_catalog_phase1.dart';

final class _SilentLogger implements FoundationLogger {
  @override
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {}
}

(DesignTokenRegistry, DesignTokenProvider) _received() {
  final registry = DesignTokenRegistry();
  final provider = DesignTokenProvider(registry: registry);
  receivePhase1Tokens(registry, provider);
  return (registry, provider);
}

void main() {
  group('Phase 1 reception — the 71 admitted Tokens', () {
    test('exactly 71 identities, in the official domain counts', () {
      final identities = phase1Identities();
      expect(identities.length, 71);

      int count(String prefix) =>
          identities.where((i) => i.name.startsWith(prefix)).length;
      expect(count('color.'), 27);
      expect(count('typography.'), 27);
      expect(count('spacing.'), 8);
      expect(count('surface.'), 5);
      expect(count('elevation.'), 4);
    });

    test('reception registers and binds every token — no orphan, no '
        'deprecated', () {
      final (registry, provider) = _received();
      for (final identity in phase1Identities()) {
        expect(registry.contains(identity.name), isTrue);
        expect(provider.isBound(identity.name), isTrue);
      }
    });

    test('every color role resolves for every variant', () {
      final (_, provider) = _received();
      final engine = BoundColorTokenEngine(provider: provider);
      for (final role in ColorRole.values) {
        for (final variant in ThemeVariantId.values) {
          engine.colorOf(role, variant);
        }
      }
      expect(
        engine.colorOf(ColorRole.primary, ThemeVariantId.light),
        mentoraEmerald,
      );
    });

    test('every typography role resolves — sizes and weights come from '
        'the tokens layer only', () {
      final (_, provider) = _received();
      final engine = BoundTypographyTokenEngine(provider: provider);
      for (final role in TypographyRole.values) {
        for (final variant in ThemeVariantId.values) {
          expect(engine.styleOf(role, variant).fontSize, isNotNull);
        }
      }
      // Hierarchy holds: hero dominates body (TSH-02).
      expect(
        engine.styleOf(TypographyRole.hero, ThemeVariantId.light).fontSize!,
        greaterThan(
          engine.styleOf(TypographyRole.body, ThemeVariantId.light).fontSize!,
        ),
      );
    });

    test('components ask a relation — never a distance', () {
      final (_, provider) = _received();
      final engine = BoundSpacingTokenEngine(provider: provider);
      for (final relation in SpacingRelation.values) {
        expect(engine.spaceOf(relation), greaterThan(0));
      }
      expect(
        engine.spaceOf(SpacingRelation.respirationHierarchique),
        greaterThan(engine.spaceOf(SpacingRelation.proximiteLiee)),
      );
    });

    test('the five surfaces and the four elevation meanings resolve', () {
      final (_, provider) = _received();
      final surfaces = BoundSurfaceTokenEngine(provider: provider);
      for (final role in SurfaceRole.values) {
        for (final variant in ThemeVariantId.values) {
          surfaces.surfaceOf(role, variant);
        }
      }
      final elevation = BoundElevationTokenEngine(provider: provider);
      final decision = elevation.expressionOf(
        ElevationMeaning.decision,
        ThemeVariantId.light,
      );
      expect(decision.blocksBelow, isTrue);
      expect(decision.isExclusive, isTrue);
      final signal = elevation.expressionOf(
        ElevationMeaning.signalement,
        ThemeVariantId.light,
      );
      expect(signal.blocksBelow, isFalse);
    });
  });

  group('Binding Integrity Engine — the automatic coverage report', () {
    test('reports 71/71 with zero orphans, deprecated and hardcoded', () {
      final (registry, provider) = _received();
      final report = const BindingIntegrityEngine().report(
        registry: registry,
        provider: provider,
      );

      expect(report.perDomain['Color'], (expected: 27, registered: 27, bound: 27));
      expect(
        report.perDomain['Typography'],
        (expected: 27, registered: 27, bound: 27),
      );
      expect(report.perDomain['Spacing'], (expected: 8, registered: 8, bound: 8));
      expect(report.perDomain['Surface'], (expected: 5, registered: 5, bound: 5));
      expect(
        report.perDomain['Elevation'],
        (expected: 4, registered: 4, bound: 4),
      );
      expect(report.boundTotal, 71);
      expect(report.expectedTotal, 71);
      expect(report.orphanTokens, isEmpty);
      expect(report.deprecatedTokens, isEmpty);
      expect(report.isComplete, isTrue);
    });

    test('the official report format', () {
      final (registry, provider) = _received();
      final report = const BindingIntegrityEngine().report(
        registry: registry,
        provider: provider,
      );

      expect(report.formatted, contains('Color :\n27 / 27'));
      expect(report.formatted, contains('Typography :\n27 / 27'));
      expect(report.formatted, contains('Spacing :\n8 / 8'));
      expect(report.formatted, contains('Surface :\n5 / 5'));
      expect(report.formatted, contains('Elevation :\n4 / 4'));
      expect(report.formatted, contains('Coverage :\n71 / 71'));
      expect(report.formatted, contains('Hardcoded Values :\n0'));
      expect(report.formatted, contains('Deprecated Tokens :\n0'));
      expect(report.formatted, contains('Orphan Tokens :\n0'));
    });

    test('verify is fail closed: an incomplete reception never ships', () {
      final registry = DesignTokenRegistry();
      final provider = DesignTokenProvider(registry: registry);
      // Register everything, bind nothing: 71 orphans.
      for (final identity in phase1Identities()) {
        registry.receive(identity);
      }

      expect(
        () => const BindingIntegrityEngine().verify(
          registry: registry,
          provider: provider,
        ),
        throwsA(isA<BindingIntegrityFailure>()),
      );
    });

    test('hardcoded values are a violation — the scan feeds the '
        'engine', () {
      final (registry, provider) = _received();
      expect(
        () => const BindingIntegrityEngine().verify(
          registry: registry,
          provider: provider,
          hardcodedValues: 1,
        ),
        throwsA(isA<BindingIntegrityFailure>()),
      );
    });
  });

  group('Theme from Tokens — the resolver knows roles, never values', () {
    test('the bootstrapped theme is produced from the bound engines', () async {
      final services = await AppBootstrap(logger: _SilentLogger()).initialize();
      final engine = services.get<ThemeEngine>();

      final light = engine.themeForVariant(ThemeVariantId.light);
      expect(light.colorScheme.primary, mentoraEmerald);
      expect(light.scaffoldBackgroundColor, lightSurfaceTokens.scene);
      expect(light.colorScheme.brightness, Brightness.light);

      final darkHc = engine.themeForVariant(ThemeVariantId.darkHighContrast);
      expect(
        darkHc.colorScheme.primary,
        darkHighContrastColorTokens.primary,
      );
      expect(darkHc.colorScheme.brightness, Brightness.dark);
    });

    test('the historical blue is gone: every variant primary is an '
        'emerald value set', () {
      final (_, provider) = _received();
      final colors = BoundColorTokenEngine(provider: provider);
      for (final variant in ThemeVariantId.values) {
        final primary = colors.colorOf(ColorRole.primary, variant);
        // Emerald family: the green channel dominates the blue.
        expect(
          (primary.g * 255).round(),
          greaterThan((primary.b * 255).round()),
          reason: 'variant ${variant.name} primary must be emerald',
        );
      }
    });
  });

  group('Governance — the executable scans ship with the code', () {
    test('the theme engine consumes engines: no raw value literal', () {
      final source = File(
        'lib/foundation/design_kit/theme/theme_engine.dart',
      ).readAsStringSync();
      for (final forbidden in const [
        'Color(0x',
        'Colors.',
        'fontSize:',
        'FontWeight.w',
      ]) {
        expect(
          source.contains(forbidden),
          isFalse,
          reason: 'theme_engine must stay token-driven: no $forbidden',
        );
      }
    });

    test('zero hardcoded values outside the tokens layer — the count '
        'that feeds the integrity report', () {
      var hardcoded = 0;
      final files = Directory('lib/foundation')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));
      for (final file in files) {
        final normalized = file.path.replaceAll('\\', '/');
        if (normalized.contains('design_kit/tokens/')) continue;
        final source = file.readAsStringSync();
        for (final forbidden in const [
          'Color(0x',
          'Colors.',
          'Duration(milliseconds',
          'fontSize:',
        ]) {
          if (source.contains(forbidden)) hardcoded++;
        }
      }
      expect(hardcoded, 0, reason: 'Hardcoded Values must be 0.');

      final (registry, provider) = _received();
      final report = const BindingIntegrityEngine().verify(
        registry: registry,
        provider: provider,
        hardcodedValues: hardcoded,
      );
      expect(report.isComplete, isTrue);
    });
  });
}
