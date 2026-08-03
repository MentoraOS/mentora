import 'dart:io';
import 'dart:ui' show Brightness, Color;

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/registry/component_theme_foundation.dart';
import 'package:mentora/foundation/design_kit/registry/form_foundation.dart';
import 'package:mentora/foundation/design_kit/registry/semantic_roles.dart';
import 'package:mentora/foundation/design_kit/registry/token_identity.dart';
import 'package:mentora/foundation/design_kit/registry/token_provider.dart';
import 'package:mentora/foundation/design_kit/registry/token_registry.dart';
import 'package:mentora/foundation/design_kit/registry/token_validator.dart';
import 'package:mentora/foundation/design_kit/theme/theme_registry.dart';
import 'package:mentora/foundation/design_kit/theme/theme_resolver.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';

TokenIdentity _identity(
  String name, {
  TokenStatus status = TokenStatus.registered,
}) {
  return TokenIdentity(
    name: name,
    domain: TokenDomain.color,
    group: 'test-group',
    status: status,
  );
}

void main() {
  group('DesignTokenRegistry — receives, never creates', () {
    test('receives an identity and resolves it by name', () {
      final registry = DesignTokenRegistry()..receive(_identity('color.test'));
      expect(registry.identityOf('color.test').group, 'test-group');
    });

    test('a duplicate name is refused — unique forever (UTC-02)', () {
      final registry = DesignTokenRegistry()..receive(_identity('color.test'));
      expect(() => registry.receive(_identity('color.test')), throwsStateError);
    });

    test('an unknown name is refused — never null (fail closed)', () {
      final registry = DesignTokenRegistry();
      expect(() => registry.identityOf('ghost'), throwsStateError);
    });
  });

  group('DesignTokenProvider — the single resolution path', () {
    late DesignTokenRegistry registry;
    late DesignTokenProvider provider;

    setUp(() {
      registry = DesignTokenRegistry();
      provider = DesignTokenProvider(registry: registry);
    });

    test('binds value sets under a stable name and resolves per '
        'variant (DTV-03)', () {
      final identity = _identity('color.primary.test');
      registry.receive(identity);
      final ref = TokenRef<Color>(identity);

      provider.bind(ref, {
        ThemeVariantId.light: const Color(0x00000001),
        ThemeVariantId.dark: const Color(0x00000002),
      });

      expect(
        provider.valueOf(ref, ThemeVariantId.light),
        const Color(0x00000001),
      );
      expect(
        provider.valueOf(ref, ThemeVariantId.dark),
        const Color(0x00000002),
      );
    });

    test('a binding for a name outside the registry is refused '
        '(valeur hors registre)', () {
      final ref = TokenRef<Color>(_identity('never.registered'));
      expect(
        () => provider.bind(ref, {ThemeVariantId.light: const Color(0x00000001)}),
        throwsStateError,
      );
    });

    test('a duplicate binding is refused — one truth per name', () {
      final identity = _identity('color.once');
      registry.receive(identity);
      final ref = TokenRef<Color>(identity);
      provider.bindUniversal(ref, const Color(0x00000001));
      expect(
        () => provider.bindUniversal(ref, const Color(0x00000002)),
        throwsStateError,
      );
    });

    test('a deprecated token is refused at resolution — migration is '
        'guided, never silent', () {
      final identity = _identity(
        'color.old',
        status: TokenStatus.deprecated,
      );
      registry.receive(identity);
      final ref = TokenRef<Color>(identity);
      expect(
        () => provider.valueOf(ref, ThemeVariantId.light),
        throwsStateError,
      );
    });

    test('an unbound token never resolves to a fallback (FDT-05)', () {
      final identity = _identity('color.unbound');
      registry.receive(identity);
      final ref = TokenRef<Color>(identity);
      expect(
        () => provider.valueOf(ref, ThemeVariantId.light),
        throwsStateError,
      );
    });

    test('a missing variant is refused — every declared variant must '
        'be served', () {
      final identity = _identity('color.partial');
      registry.receive(identity);
      final ref = TokenRef<Color>(identity);
      provider.bind(ref, {ThemeVariantId.light: const Color(0x00000001)});
      expect(
        () => provider.valueOf(ref, ThemeVariantId.dark),
        throwsStateError,
      );
    });
  });

  group('TokenValidator — the Kit refuses invalid states', () {
    test('a clean registry+provider validates silently', () {
      final registry = DesignTokenRegistry();
      final provider = DesignTokenProvider(registry: registry);
      final identity = _identity('spacing.rel');
      registry.receive(identity);
      provider.bindUniversal(TokenRef<double>(identity), 8.0);

      const TokenValidator().validate(registry: registry, provider: provider);
    });

    test('an orphan identity is a violation — registered, never bound '
        '(UTG-08)', () {
      final registry = DesignTokenRegistry()..receive(_identity('orphan'));
      final provider = DesignTokenProvider(registry: registry);

      expect(
        () => const TokenValidator().validate(
          registry: registry,
          provider: provider,
        ),
        throwsA(
          isA<TokenValidationFailure>().having(
            (f) => f.violations.single.kind,
            'kind',
            TokenViolationKind.orphanIdentity,
          ),
        ),
      );
    });

    test('incomplete variant coverage is a violation for tokens '
        'expected complete', () {
      final registry = DesignTokenRegistry();
      final provider = DesignTokenProvider(registry: registry);
      final identity = _identity('color.partial');
      registry.receive(identity);
      provider.bind(TokenRef<Color>(identity), {
        ThemeVariantId.light: const Color(0x00000001),
      });

      expect(
        () => const TokenValidator().validate(
          registry: registry,
          provider: provider,
          expectedComplete: {'color.partial'},
        ),
        throwsA(
          isA<TokenValidationFailure>().having(
            (f) => f.violations.any(
              (v) => v.kind == TokenViolationKind.missingVariant,
            ),
            'has missingVariant',
            isTrue,
          ),
        ),
      );
    });
  });

  group('ThemeResolver — Light/Dark/System without Widgets', () {
    const resolver = ThemeResolver();

    test('explicit preferences win regardless of the platform', () {
      expect(
        resolver.resolve(
          theme: ThemePreference.light,
          contrast: ContrastPreference.standard,
          platformBrightness: Brightness.dark,
        ),
        ThemeVariantId.light,
      );
      expect(
        resolver.resolve(
          theme: ThemePreference.dark,
          contrast: ContrastPreference.standard,
          platformBrightness: Brightness.light,
        ),
        ThemeVariantId.dark,
      );
    });

    test('System follows the platform — a chosen following, never an '
        'assumption', () {
      expect(
        resolver.resolve(
          theme: ThemePreference.system,
          contrast: ContrastPreference.standard,
          platformBrightness: Brightness.dark,
        ),
        ThemeVariantId.dark,
      );
    });

    test('the contrast axis declines the same modes', () {
      expect(
        resolver.resolve(
          theme: ThemePreference.light,
          contrast: ContrastPreference.high,
          platformBrightness: Brightness.light,
        ),
        ThemeVariantId.lightHighContrast,
      );
      expect(
        resolver.resolve(
          theme: ThemePreference.system,
          contrast: ContrastPreference.high,
          platformBrightness: Brightness.dark,
        ),
        ThemeVariantId.darkHighContrast,
      );
    });
  });

  group('DesignThemeRegistry and ThemeValidator', () {
    test('one bundle per variant, duplicates refused', () {
      final registry = DesignThemeRegistry<String>();
      registry.register(
        ThemeBundle(variant: ThemeVariantId.light, build: () => 'light'),
      );
      expect(
        () => registry.register(
          ThemeBundle(variant: ThemeVariantId.light, build: () => 'again'),
        ),
        throwsStateError,
      );
      expect(registry.bundleFor(ThemeVariantId.light).build(), 'light');
    });

    test('an unknown variant is refused — never a silent fallback', () {
      final registry = DesignThemeRegistry<String>();
      expect(
        () => registry.bundleFor(ThemeVariantId.dark),
        throwsStateError,
      );
    });

    test('the validator refuses an incomplete registry', () {
      final registry = DesignThemeRegistry<String>()
        ..register(
          ThemeBundle(variant: ThemeVariantId.light, build: () => 'l'),
        );
      expect(
        () => const ThemeValidator().validate(registry),
        throwsStateError,
      );

      registry
        ..register(ThemeBundle(variant: ThemeVariantId.dark, build: () => 'd'))
        ..register(
          ThemeBundle(
            variant: ThemeVariantId.lightHighContrast,
            build: () => 'lh',
          ),
        )
        ..register(
          ThemeBundle(
            variant: ThemeVariantId.darkHighContrast,
            build: () => 'dh',
          ),
        );
      const ThemeValidator().validate(registry);
    });
  });

  group('Semantic roles — the receiving structure matches the catalog', () {
    test('exactly 27 color roles, in the six official groups', () {
      expect(ColorRole.values.length, 27);
    });

    test('exactly 27 typography roles', () {
      expect(TypographyRole.values.length, 27);
    });

    test('exactly 8 spacing relations', () {
      expect(SpacingRelation.values.length, 8);
    });

    test('the official surfaces and the four elevation meanings', () {
      expect(SurfaceRole.values.map((role) => role.name).toList(), [
        'scene',
        'primarySurface',
        'secondarySurface',
        'protectedSurface',
        'immersiveSurface',
      ]);
      expect(ElevationMeaning.values.map((m) => m.name).toList(), [
        'aparte',
        'decision',
        'immersion',
        'signalement',
      ]);
    });

    test('the form contracts exist as roles only', () {
      expect(ShapeRole.values, isNotEmpty);
      expect(RadiusRole.values, isNotEmpty);
      expect(BorderRole.values, isNotEmpty);
      expect(OpacityRole.values, isNotEmpty);
    });
  });

  group('ComponentThemeFoundation — one recipe per chapter', () {
    test('registers and resolves a chapter fragment', () {
      final foundation = ComponentThemeFoundation<String>();
      foundation.registerChapter('Action', (variant) => 'action:$variant');
      expect(
        foundation.fragmentFor('Action', ThemeVariantId.dark),
        'action:${ThemeVariantId.dark}',
      );
    });

    test('duplicates and unknown chapters are refused', () {
      final foundation = ComponentThemeFoundation<String>();
      foundation.registerChapter('Action', (variant) => 'a');
      expect(
        () => foundation.registerChapter('Action', (variant) => 'b'),
        throwsStateError,
      );
      expect(
        () => foundation.fragmentFor('Ghost', ThemeVariantId.light),
        throwsStateError,
      );
    });
  });

  group('Governance — the receiving structure is contract-pure', () {
    test('no value literal lives in the registry contracts', () {
      final files = Directory('lib/foundation/design_kit/registry')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));
      for (final file in files) {
        final source = file.readAsStringSync();
        for (final forbidden in const [
          'Color(0x',
          'Colors.',
          'Duration(milliseconds',
          'fontSize:',
          'FontWeight.w',
        ]) {
          expect(
            source.contains(forbidden),
            isFalse,
            reason:
                '${file.path} must stay contract-pure: no $forbidden '
                '(values live only in the tokens layer / bindings).',
          );
        }
      }
    });
  });
}
