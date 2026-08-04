import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/bootstrap/app_bootstrap.dart';
import 'package:mentora/foundation/core/di/foundation_services.dart';
import 'package:mentora/foundation/core/logging/foundation_logger.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/playground/playground_app.dart';
import 'package:mentora/foundation/playground/playground_guard.dart';

final class _SilentLogger implements FoundationLogger {
  @override
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {}
}

Future<FoundationServices> _services() {
  return AppBootstrap(logger: _SilentLogger()).initialize();
}

Future<void> _pumpPlayground(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1440, 3200);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final services = await _services();
  await tester.pumpWidget(PlaygroundApp(services: services));
  // The living catalogue hosts the components' waiting states: their
  // indicators never come to rest, by design. The laboratory is
  // therefore pumped, never settled.
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  test('the playground guard refuses release builds — fail closed', () {
    expect(() => guardPlaygroundAccess(isRelease: true), throwsStateError);
    guardPlaygroundAccess(isRelease: false);
  });

  testWidgets('the playground boots and every gallery is fed by the '
      'engines', (tester) async {
    await _pumpPlayground(tester);

    expect(find.byKey(const Key('playground-scroll')), findsOneWidget);
    expect(find.byKey(const Key('coverage-total')), findsOneWidget);
    expect(
      find.text('Coverage : 71 / 71 — 100 %'),
      findsOneWidget,
    );
  });

  testWidgets('the coverage panel reports the five domains', (tester) async {
    await _pumpPlayground(tester);

    expect(find.text('Color : 27 / 27'), findsOneWidget);
    expect(find.text('Typography : 27 / 27'), findsOneWidget);
    expect(find.text('Spacing : 8 / 8'), findsOneWidget);
    expect(find.text('Surface : 5 / 5'), findsOneWidget);
    expect(find.text('Elevation : 4 / 4'), findsOneWidget);
  });

  testWidgets('the integrity panel shows zero violations', (tester) async {
    await _pumpPlayground(tester);

    expect(find.text('Hardcoded Values : 0'), findsOneWidget);
    expect(find.text('Deprecated Tokens : 0'), findsOneWidget);
    expect(find.text('Orphan Tokens : 0'), findsOneWidget);
    expect(find.text('Unknown Tokens : 0'), findsOneWidget);
    expect(find.text('Missing Bindings : 0'), findsOneWidget);
  });

  testWidgets('runtime verification passes on the bootstrapped state', (
    tester,
  ) async {
    await _pumpPlayground(tester);

    expect(
      find.text('All verifications passed — fail closed armed.'),
      findsOneWidget,
    );
  });

  testWidgets('the galleries render every role: 27 colors, 27 '
      'typography samples, 8 spacing bars, 5 surfaces, 4 elevations', (
    tester,
  ) async {
    await _pumpPlayground(tester);

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget.key is ValueKey<String> &&
            (widget.key as ValueKey<String>).value.startsWith('color-swatch-'),
      ),
      findsNWidgets(27),
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget.key is ValueKey<String> &&
            (widget.key as ValueKey<String>).value.startsWith(
              'typography-sample-',
            ),
      ),
      findsNWidgets(27),
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget.key is ValueKey<String> &&
            (widget.key as ValueKey<String>).value.startsWith('spacing-bar-'),
      ),
      findsNWidgets(8),
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget.key is ValueKey<String> &&
            (widget.key as ValueKey<String>).value.startsWith('surface-tile-'),
      ),
      findsNWidgets(5),
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget.key is ValueKey<String> &&
            (widget.key as ValueKey<String>).value.startsWith('elevation-'),
      ),
      findsNWidgets(4),
    );
  });

  testWidgets('the appearance toggles drive the real engines — the '
      'render updates immediately', (tester) async {
    final services = await _services();
    tester.view.physicalSize = const Size(1440, 3200);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(PlaygroundApp(services: services));
    await tester.pump(const Duration(seconds: 1));

    services.get<AppearanceEngine>().updateTheme(ThemePreference.dark);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final context = tester.element(find.byKey(const Key('playground-scroll')));
    expect(Theme.of(context).colorScheme.brightness, Brightness.dark);
  });

  testWidgets('the Arabic locale flips the playground to RTL — first '
      'class, never a retrofit', (tester) async {
    await _pumpPlayground(tester);

    await tester.tap(find.text('ar'));
    await tester.pump(const Duration(seconds: 1));

    final context = tester.element(find.byKey(const Key('playground-scroll')));
    expect(Directionality.of(context), TextDirection.rtl);
  });

  group('Governance — the playground stays outside production', () {
    test('the production app never imports the playground', () {
      final productionDirs = [
        'lib/foundation/app',
        'lib/foundation/navigation',
        'lib/foundation/bootstrap',
        'lib/foundation/core',
        'lib/foundation/design_kit',
      ];
      for (final dir in productionDirs) {
        for (final file in Directory(dir)
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))) {
          expect(
            file.readAsStringSync().contains('playground'),
            isFalse,
            reason: '${file.path} must not reference the playground.',
          );
        }
      }
      expect(
        File('lib/main_foundation.dart')
            .readAsStringSync()
            .contains('playground'),
        isFalse,
      );
    });

    test('the playground codes no value: everything comes from the '
        'engines', () {
      for (final file in Directory('lib/foundation/playground')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        final source = file.readAsStringSync();
        for (final forbidden in const [
          'Color(0x',
          'Colors.',
          'Duration(milliseconds',
          'fontSize:',
        ]) {
          expect(
            source.contains(forbidden),
            isFalse,
            reason: '${file.path} must not contain $forbidden.',
          );
        }
      }
    });
  });
}
