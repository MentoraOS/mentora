import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart' show ThemeMode, Brightness;
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/bootstrap/app_bootstrap.dart';
import 'package:mentora/foundation/bootstrap/startup_pipeline.dart';
import 'package:mentora/foundation/core/di/foundation_services.dart';
import 'package:mentora/foundation/core/environment/environment_configuration.dart';
import 'package:mentora/foundation/core/logging/foundation_logger.dart';
import 'package:mentora/foundation/design_kit/accessibility/accessibility_engine.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/international/international_engine.dart';
import 'package:mentora/foundation/design_kit/motion/motion_engine.dart';
import 'package:mentora/foundation/design_kit/responsive/responsive_engine.dart';
import 'package:mentora/foundation/design_kit/theme/theme_engine.dart';
import 'package:mentora/foundation/design_kit/tokens/design_tokens.dart';
import 'package:mentora/foundation/localization/localization_engine.dart';
import 'package:mentora/foundation/localization/mentora_strings.dart';

final class _MemoryLogger implements FoundationLogger {
  final List<String> lines = [];

  @override
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    lines.add('${level.name}:$message');
  }
}

final class _RecordingStep implements StartupStep {
  @override
  final String name;
  final List<String> order;
  final bool fails;

  _RecordingStep(this.name, this.order, {this.fails = false});

  @override
  Future<void> run(FoundationServices services) async {
    if (fails) {
      throw StateError('boom');
    }
    order.add(name);
  }
}

void main() {
  group('FoundationServices — official DI, fail closed', () {
    test('registers and resolves lazily as singletons', () {
      final services = FoundationServices();
      var built = 0;
      services.register<AppearanceEngine>(() {
        built++;
        return AppearanceEngine();
      });

      expect(built, 0);
      final first = services.get<AppearanceEngine>();
      final second = services.get<AppearanceEngine>();
      expect(built, 1);
      expect(identical(first, second), isTrue);
    });

    test('missing dependency is a StateError — never a default', () {
      final services = FoundationServices();
      expect(services.get<ThemeEngine>, throwsStateError);
    });

    test('duplicate registration is refused', () {
      final services = FoundationServices();
      services.register<ThemeEngine>(() => const ThemeEngine());
      expect(
        () => services.register<ThemeEngine>(() => const ThemeEngine()),
        throwsStateError,
      );
    });
  });

  group('EnvironmentConfiguration — injected, fail closed', () {
    test('absent define resolves to unconfigured, never a guess', () {
      final configuration = EnvironmentConfiguration.fromDefines();
      expect(configuration.environment, MentoraEnvironment.unconfigured);
      expect(configuration.isConfigured, isFalse);
      expect(configuration.isProduction, isFalse);
    });
  });

  group('StartupPipeline — ordered, fail closed', () {
    test('runs the steps strictly in order', () async {
      final order = <String>[];
      final pipeline = StartupPipeline(
        steps: [
          _RecordingStep('first', order),
          _RecordingStep('second', order),
          _RecordingStep('third', order),
        ],
        logger: _MemoryLogger(),
      );

      final report = await pipeline.execute(FoundationServices());

      expect(order, ['first', 'second', 'third']);
      expect(report.completedSteps, ['first', 'second', 'third']);
    });

    test('stops at the first failure and names the step', () async {
      final order = <String>[];
      final pipeline = StartupPipeline(
        steps: [
          _RecordingStep('first', order),
          _RecordingStep('broken', order, fails: true),
          _RecordingStep('never', order),
        ],
        logger: _MemoryLogger(),
      );

      await expectLater(
        pipeline.execute(FoundationServices()),
        throwsA(
          isA<StartupFailure>().having((f) => f.stepName, 'step', 'broken'),
        ),
      );
      expect(order, ['first']);
    });
  });

  group('AppBootstrap — the composition root', () {
    test('initialize assembles every official engine', () async {
      final services = await AppBootstrap(logger: _MemoryLogger()).initialize();

      expect(services.contains<AppearanceEngine>(), isTrue);
      expect(services.contains<ThemeEngine>(), isTrue);
      expect(services.contains<MotionEngine>(), isTrue);
      expect(services.contains<AccessibilityEngine>(), isTrue);
      expect(services.contains<ResponsiveEngine>(), isTrue);
      expect(services.contains<InternationalEngine>(), isTrue);
      expect(services.contains<LocalizationEngine>(), isTrue);
      expect(services.contains<EnvironmentConfiguration>(), isTrue);
    });
  });

  group('AppearanceEngine — GE-16 independence', () {
    test('defaults are the worldwide fail-safe', () {
      const state = AppearanceState();
      expect(state.theme, ThemePreference.system);
      expect(state.accent, AccentPreference.emerald);
      expect(state.density, DensityPreference.standard);
      expect(state.motion, MotionPreference.full);
      expect(state.contrast, ContrastPreference.standard);
    });

    test('changing one preference never changes another', () {
      final engine = AppearanceEngine();
      engine.updateTheme(ThemePreference.dark);
      engine.updateFontScale(FontScalePreference.large);

      expect(engine.state.theme, ThemePreference.dark);
      expect(engine.state.fontScale, FontScalePreference.large);
      expect(engine.state.density, DensityPreference.standard);
      expect(engine.state.motion, MotionPreference.full);
      expect(engine.state.contrast, ContrastPreference.standard);
      expect(engine.state.accent, AccentPreference.emerald);
    });

    test('notifies its consumers on every update', () {
      final engine = AppearanceEngine();
      var notified = 0;
      engine.addListener(() => notified++);
      engine.updateDensity(DensityPreference.comfortable);
      engine.updateContrast(ContrastPreference.high);
      expect(notified, 2);
    });
  });

  group('ThemeEngine — themes are value sets under stable names', () {
    const engine = ThemeEngine();

    test('mode resolution maps the preference exactly', () {
      expect(
        engine.resolveMode(const AppearanceState(theme: ThemePreference.light)),
        ThemeMode.light,
      );
      expect(
        engine.resolveMode(const AppearanceState(theme: ThemePreference.dark)),
        ThemeMode.dark,
      );
      expect(engine.resolveMode(const AppearanceState()), ThemeMode.system);
    });

    test('light and dark themes consume the color tokens', () {
      const state = AppearanceState();
      final light = engine.lightTheme(state);
      final dark = engine.darkTheme(state);

      expect(light.colorScheme.primary, lightColorTokens.primary);
      expect(light.colorScheme.primary, mentoraEmerald);
      expect(light.scaffoldBackgroundColor, lightColorTokens.background);
      expect(dark.colorScheme.primary, darkColorTokens.primary);
      expect(dark.colorScheme.brightness, Brightness.dark);
    });

    test('high contrast declines values, never meanings', () {
      const state = AppearanceState(contrast: ContrastPreference.high);
      final light = engine.lightTheme(state);
      expect(light.colorScheme.primary, lightHighContrastColorTokens.primary);
      // Same role, another value set (DTV-03).
      expect(
        light.colorScheme.primary,
        isNot(equals(lightColorTokens.primary)),
      );
    });
  });

  group('MotionEngine — intentions declined by preference', () {
    const engine = MotionEngine();

    test('None silences every intention', () {
      const state = AppearanceState(motion: MotionPreference.none);
      for (final intention in MotionIntention.values) {
        expect(engine.durationFor(intention, state), Duration.zero);
      }
    });

    test('Reduced shortens, Full keeps the tokens', () {
      const full = AppearanceState();
      const reduced = AppearanceState(motion: MotionPreference.reduced);
      for (final intention in MotionIntention.values) {
        final fullDuration = engine.durationFor(intention, full);
        final reducedDuration = engine.durationFor(intention, reduced);
        expect(fullDuration, greaterThan(Duration.zero));
        expect(reducedDuration, lessThan(fullDuration));
        expect(reducedDuration, greaterThan(Duration.zero));
      }
    });
  });

  group('AccessibilityEngine — opposable, measured', () {
    const engine = AccessibilityEngine();

    test('font scale is monotonic and clamped', () {
      double scaleFor(FontScalePreference preference) {
        return engine.textScaleFor(AppearanceState(fontScale: preference));
      }

      expect(scaleFor(FontScalePreference.small), lessThan(1.0));
      expect(scaleFor(FontScalePreference.standard), 1.0);
      expect(
        scaleFor(FontScalePreference.large),
        lessThan(scaleFor(FontScalePreference.extraLarge)),
      );
      expect(
        scaleFor(FontScalePreference.extraLarge),
        lessThanOrEqualTo(maximumFontScale),
      );
    });

    test('the reachable target and immediacy come from the tokens', () {
      expect(engine.minimumTapTarget, interactionTokens.cibleAtteignable);
      expect(engine.minimumTapTarget, greaterThanOrEqualTo(48));
      expect(engine.acknowledgeImmediacy, interactionTokens.immediateteAccuse);
    });
  });

  group('ResponsiveEngine — contexts, phone as reference', () {
    const engine = ResponsiveEngine();

    test('classifies the official contexts by available space', () {
      expect(engine.resolve(const Size(250, 280)), DeviceContext.wearable);
      expect(engine.resolve(const Size(390, 844)), DeviceContext.phone);
      expect(engine.resolve(const Size(650, 840)), DeviceContext.foldable);
      expect(engine.resolve(const Size(800, 1280)), DeviceContext.tablet);
      expect(engine.resolve(const Size(1600, 1050)), DeviceContext.desktop);
      expect(engine.resolve(const Size(3840, 2160)), DeviceContext.tv);
    });

    test('the phone is the reference context', () {
      expect(engine.reference, DeviceContext.phone);
    });
  });

  group('LocalizationEngine — official resolution, worldwide', () {
    const engine = LocalizationEngine();

    test('supports exactly the six foundation locales', () {
      expect(
        LocalizationEngine.supportedLocales.map((l) => l.languageCode).toList(),
        ['fr', 'en', 'ar', 'es', 'pt', 'de'],
      );
    });

    test('explicit choice > system > worldwide fail-safe', () {
      expect(
        engine.resolve(
          explicitChoice: const Locale('ar'),
          systemLocale: const Locale('fr'),
        ),
        const Locale('ar'),
      );
      expect(
        engine.resolve(systemLocale: const Locale('pt', 'BR')),
        const Locale('pt'),
      );
      expect(engine.resolve(systemLocale: const Locale('ja')), const Locale('en'));
      expect(engine.resolve(), const Locale('en'));
    });

    test('every key exists in every locale — a missing key never ships', () {
      final reference = mentoraStringTables['en']!.keys.toSet();
      for (final entry in mentoraStringTables.entries) {
        expect(
          entry.value.keys.toSet(),
          reference,
          reason: 'Locale ${entry.key} must cover every key.',
        );
        for (final value in entry.value.values) {
          expect(value.trim(), isNotEmpty);
        }
      }
    });

    test('a missing key fails closed at read time', () {
      const strings = MentoraStrings(Locale('en'), {});
      expect(() => strings.appTitle, throwsStateError);
    });
  });

  group('InternationalEngine — canonical in, preference out', () {
    const engine = InternationalEngine();

    test('direction is logical: Arabic reads right-to-left', () {
      expect(engine.directionFor(const Locale('ar')), TextDirection.rtl);
      expect(engine.directionFor(const Locale('fr')), TextDirection.ltr);
    });

    test('instants are canonical — a local DateTime is rejected', () {
      expect(
        () => engine.formatInstant(
          canonicalUtc: DateTime(2026, 8, 2, 9),
          zoneOffset: Duration.zero,
          locale: const Locale('en'),
        ),
        throwsAssertionError,
      );
    });

    test('numbers follow the locale conventions, never a coded format', () {
      final english = engine.formatNumber(
        value: 1234.5,
        locale: const Locale('en'),
      );
      final french = engine.formatNumber(
        value: 1234.5,
        locale: const Locale('fr'),
      );
      expect(english, isNot(equals(french)));
    });
  });

  group('Governance — FDG scans shipped with the code', () {
    List<File> foundationFiles() {
      return Directory('lib/foundation')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .toList();
    }

    test('FDG-02: no raw color outside the tokens layer', () {
      for (final file in foundationFiles()) {
        final normalized = file.path.replaceAll('\\', '/');
        if (normalized.contains('design_kit/tokens/')) continue;
        final source = file.readAsStringSync();
        expect(
          source.contains('Color(0x') || source.contains('Colors.'),
          isFalse,
          reason: '$normalized must not contain a raw color (FDG-02).',
        );
      }
    });

    test('FDG-05: no raw duration outside the tokens layer', () {
      for (final file in foundationFiles()) {
        final normalized = file.path.replaceAll('\\', '/');
        if (normalized.contains('design_kit/tokens/')) continue;
        final source = file.readAsStringSync();
        expect(
          source.contains('Duration(milliseconds') ||
              source.contains('Duration(seconds'),
          isFalse,
          reason: '$normalized must not contain a raw duration (FDG-05).',
        );
      }
    });

    test('FDG-06: no raw font size outside the tokens layer', () {
      for (final file in foundationFiles()) {
        final normalized = file.path.replaceAll('\\', '/');
        if (normalized.contains('design_kit/tokens/')) continue;
        final source = file.readAsStringSync();
        expect(
          source.contains('fontSize: 1') || source.contains('fontSize: 2'),
          isFalse,
          reason: '$normalized must not contain a raw font size (FDG-06).',
        );
      }
    });

    test('foundation never imports the business layers', () {
      for (final file in foundationFiles()) {
        final source = file.readAsStringSync();
        for (final forbidden in const [
          "import 'package:mentora/screens/",
          "import 'package:mentora/application/",
          "import 'package:mentora/infrastructure/",
          "import 'package:mentora/domain/",
          "import 'package:provider/",
          "import 'package:cloud_firestore/",
          "import 'package:livekit_client/",
        ]) {
          expect(
            source.contains(forbidden),
            isFalse,
            reason: '${file.path} must not depend on $forbidden',
          );
        }
      }
    });

    test('the shell codes no interface string — words live in the '
        'strings layer', () {
      final source = File(
        'lib/foundation/navigation/navigation_shell.dart',
      ).readAsStringSync();
      expect(source, isNot(contains("Text('")));
      expect(source, isNot(contains('label: \'')));
      expect(source, contains('MentoraStrings.of(context)'));
    });

    test('the official root navigation has exactly five destinations', () {
      final source = File(
        'lib/foundation/navigation/navigation_shell.dart',
      ).readAsStringSync();
      expect(RegExp(r'NavigationDestination\(').allMatches(source).length, 5);
    });
  });
}
