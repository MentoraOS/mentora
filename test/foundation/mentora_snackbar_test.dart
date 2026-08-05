import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/bootstrap/design_kit_bootstrap.dart';
import 'package:mentora/foundation/core/di/foundation_services.dart';
import 'package:mentora/foundation/design_kit/accessibility/accessibility_engine.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/components/design_kit_scope.dart';
import 'package:mentora/foundation/design_kit/components/snackbar/mentora_snackbar.dart';
import 'package:mentora/foundation/design_kit/components/snackbar/mentora_snackbar_host.dart';
import 'package:mentora/foundation/design_kit/components/snackbar/mentora_snackbar_request.dart';
import 'package:mentora/foundation/design_kit/components/snackbar/mentora_snackbar_service.dart';
import 'package:mentora/foundation/design_kit/components/snackbar/mentora_snackbar_style.dart';
import 'package:mentora/foundation/design_kit/components/snackbar/mentora_snackbar_theme.dart';
import 'package:mentora/foundation/design_kit/motion/motion_engine.dart';
import 'package:mentora/foundation/design_kit/registry/semantic_roles.dart';
import 'package:mentora/foundation/design_kit/registry/token_engines.dart';
import 'package:mentora/foundation/design_kit/theme/theme_engine.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';
import 'package:mentora/foundation/design_kit/tokens/snackbar_tokens.dart';
import 'package:mentora/foundation/design_kit/tokens/surface_elevation_tokens.dart';

MentoraSnackbarRequest _demand([
  MentoraSnackbarVariant variant = MentoraSnackbarVariant.information,
]) {
  return MentoraSnackbarRequest(
    variant: variant,
    message: 'La séance a été confirmée.',
  );
}

Future<FoundationServices> _services() async {
  final services = FoundationServices();
  await const DesignKitBootstrapStep().run(services);
  return services;
}

Widget _scoped(
  FoundationServices services, {
  required Widget child,
  ThemeVariantId variant = ThemeVariantId.light,
  AppearanceState appearance = const AppearanceState(),
  TextDirection direction = TextDirection.ltr,
}) {
  return MaterialApp(
    theme: services.get<ThemeEngine>().themeForVariant(variant),
    home: DesignKitScope(
      colors: services.get<ColorTokenEngine>(),
      typography: services.get<TypographyTokenEngine>(),
      spacing: services.get<SpacingTokenEngine>(),
      surfaces: services.get<SurfaceTokenEngine>(),
      elevation: services.get<ElevationTokenEngine<ElevationExpression>>(),
      motion: services.get<MotionEngine>(),
      accessibility: services.get<AccessibilityEngine>(),
      appearance: appearance,
      variant: variant,
      child: Directionality(textDirection: direction, child: child),
    ),
  );
}

/// The host, above a scene that owns a focusable act — so it can be
/// proven that a message never touches the focus.
Future<(FoundationServices, MentoraSnackbarService)> _pumpHost(
  WidgetTester tester, {
  AppearanceState appearance = const AppearanceState(),
  MentoraSnackbarController? controller,
  FocusNode? sceneFocus,
}) async {
  final services = await _services();
  final messages = services.get<MentoraSnackbarService>();
  await tester.pumpWidget(
    _scoped(
      services,
      appearance: appearance,
      child: MentoraSnackbarHost(
        service: messages,
        controller: controller,
        child: Scaffold(
          body: Center(
            child: TextButton(
              focusNode: sceneFocus,
              onPressed: () {},
              child: const Text('scène'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (services, messages);
}

BoxDecoration _decorationOf(WidgetTester tester) {
  return tester
          .widget<DecoratedBox>(
            find
                .descendant(
                  of: find.byType(MentoraSnackbar),
                  matching: find.byType(DecoratedBox),
                )
                .first,
          )
          .decoration
      as BoxDecoration;
}

MentoraSnackbarTheme _adapter(FoundationServices services) {
  return MentoraSnackbarTheme(
    colors: services.get<ColorTokenEngine>(),
    surfaces: services.get<SurfaceTokenEngine>(),
    spacing: services.get<SpacingTokenEngine>(),
    elevation: services.get<ElevationTokenEngine<ElevationExpression>>(),
    motion: services.get<MotionEngine>(),
    appearance: const AppearanceState(),
    variant: ThemeVariantId.light,
  );
}

void main() {
  group('A message informs — it never asks', () {
    test('a demand carries a single sentence and its reading time — '
        'nothing else', () {
      final demand = _demand();
      expect(demand.message, isNotEmpty);
      expect(demand.dwell, snackbarStandardDwell);
      expect(demand.reportsOngoing, isFalse);
      // That it carries no act at all is enforced by the executable
      // scan below: an act to answer is a dialog, never a message.
    });

    testWidgets('its elevation meaning is the signalement: no veil, no '
        'blocking, no layer taken from anyone', (tester) async {
      final services = await _services();
      final expression = _adapter(services).expression;

      expect(snackbarElevationMeaning, ElevationMeaning.signalement);
      expect(expression.dimsScene, isFalse);
      expect(expression.blocksBelow, isFalse);
      expect(
        expression.isExclusive,
        isFalse,
        reason: 'a message takes no layer — the queue is its own rule',
      );
    });

    test('one message, one idea: a story is refused, and so is '
        'silence', () {
      expect(
        () => const MentoraSnackbarRequest(
          variant: MentoraSnackbarVariant.information,
          message: '',
        ).verify(),
        throwsStateError,
      );
      expect(
        () => const MentoraSnackbarRequest(
          variant: MentoraSnackbarVariant.information,
          message: 'Première idée.\nSeconde idée.',
        ).verify(),
        throwsStateError,
      );
      _demand().verify();
    });

    test('a message that reports an ongoing state never expires on its '
        'own — the others disappear alone', () {
      for (final variant in const [
        MentoraSnackbarVariant.sync,
        MentoraSnackbarVariant.processing,
        MentoraSnackbarVariant.offline,
      ]) {
        expect(dwellOf(variant), isNull);
        expect(reportsOngoingState(variant), isTrue);
      }
      expect(
        dwellOf(MentoraSnackbarVariant.warning),
        snackbarExtendedDwell,
      );
      expect(
        dwellOf(MentoraSnackbarVariant.error),
        snackbarExtendedDwell,
      );
      expect(
        dwellOf(MentoraSnackbarVariant.success),
        snackbarStandardDwell,
      );
    });
  });

  group('The layer expresses the signal', () {
    testWidgets('each variant names its meaning with a role', (tester) async {
      final services = await _services();
      final colors = services.get<ColorTokenEngine>();
      for (final pair in const [
        (MentoraSnackbarVariant.information, ColorRole.information),
        (MentoraSnackbarVariant.success, ColorRole.success),
        (MentoraSnackbarVariant.warning, ColorRole.warning),
        (MentoraSnackbarVariant.error, ColorRole.critical),
        (MentoraSnackbarVariant.offline, ColorRole.unavailable),
      ]) {
        await tester.pumpWidget(
          _scoped(
            services,
            child: Scaffold(
              body: MentoraSnackbar(
                request: _demand(pair.$1),
                state: MentoraSnackbarState.visible,
              ),
            ),
          ),
        );
        await tester.pump();
        final icon = tester.widget<Icon>(
          find
              .descendant(
                of: find.byType(MentoraSnackbar),
                matching: find.byType(Icon),
              )
              .first,
        );
        expect(icon.color, colors.colorOf(pair.$2, ThemeVariantId.light));
      }
    });

    testWidgets('a message rests on the protected surface, and says so '
        'while it is replaced in place', (tester) async {
      final services = await _services();
      final colors = services.get<ColorTokenEngine>();
      final surfaces = services.get<SurfaceTokenEngine>();

      await tester.pumpWidget(
        _scoped(
          services,
          child: Scaffold(
            body: MentoraSnackbar(
              request: _demand(),
              state: MentoraSnackbarState.visible,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(
        _decorationOf(tester).color,
        surfaces.surfaceOf(SurfaceRole.protectedSurface, ThemeVariantId.light),
      );
      expect(
        (_decorationOf(tester).border! as Border).top.color,
        colors.colorOf(ColorRole.outline, ThemeVariantId.light),
      );

      await tester.pumpWidget(
        _scoped(
          services,
          child: Scaffold(
            body: MentoraSnackbar(
              request: _demand(),
              state: MentoraSnackbarState.updating,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(
        (_decorationOf(tester).border! as Border).top.color,
        colors.colorOf(ColorRole.information, ThemeVariantId.light),
      );
    });

    testWidgets('a state still happening shows exactly one sober '
        'signal — never a story', (tester) async {
      final services = await _services();
      await tester.pumpWidget(
        _scoped(
          services,
          child: Scaffold(
            body: MentoraSnackbar(
              request: _demand(MentoraSnackbarVariant.sync),
              state: MentoraSnackbarState.visible,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('the four theme variants and both directions are '
        'served without any special handling', (tester) async {
      final services = await _services();
      for (final variant in ThemeVariantId.values) {
        await tester.pumpWidget(
          _scoped(
            services,
            variant: variant,
            child: Scaffold(
              body: MentoraSnackbar(
                request: _demand(),
                state: MentoraSnackbarState.visible,
              ),
            ),
          ),
        );
        await tester.pump();
        expect(
          _decorationOf(tester).color,
          services.get<SurfaceTokenEngine>().surfaceOf(
            SurfaceRole.protectedSurface,
            variant,
          ),
        );
      }

      for (final direction in TextDirection.values) {
        await tester.pumpWidget(
          _scoped(
            services,
            direction: direction,
            child: Scaffold(
              body: MentoraSnackbar(
                request: _demand(),
                state: MentoraSnackbarState.visible,
              ),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('the message is announced where it appears — never by '
        'taking the focus', (tester) async {
      final handle = tester.ensureSemantics();
      final services = await _services();
      await tester.pumpWidget(
        _scoped(
          services,
          child: Scaffold(
            body: MentoraSnackbar(
              request: const MentoraSnackbarRequest(
                variant: MentoraSnackbarVariant.success,
                message: 'La séance a été confirmée.',
                semanticLabel: 'Séance confirmée',
              ),
              state: MentoraSnackbarState.visible,
            ),
          ),
        ),
      );
      await tester.pump();

      final node = tester.getSemantics(find.byType(MentoraSnackbar));
      expect(node.label, 'Séance confirmée');
      expect(node.flagsCollection.isLiveRegion, isTrue);
      handle.dispose();
    });
  });

  group('The service carries messages, never business', () {
    test('show is immediate or refused; queue waits its turn', () {
      final service = MentoraSnackbarService();
      addTearDown(service.dispose);

      service.show(_demand());
      expect(service.isShowing, isTrue);
      expect(() => service.show(_demand()), throwsStateError);

      service.queue(_demand(MentoraSnackbarVariant.success));
      expect(service.pendingCount, 1);

      service.dismiss();
      expect(service.current?.variant, MentoraSnackbarVariant.success);
      expect(service.pendingCount, 0);
    });

    test('every outcome reaches its caller — expired, dismissed, '
        'replaced, cleared', () async {
      final service = MentoraSnackbarService();
      addTearDown(service.dispose);

      final expired = service.show(_demand());
      service.dismiss(const MentoraSnackbarResult.expired());
      expect(await expired, const MentoraSnackbarResult.expired());

      final dismissed = service.show(_demand());
      service.dismiss();
      expect(await dismissed, const MentoraSnackbarResult.dismissed());

      final replaced = service.show(_demand());
      service.replace(_demand(MentoraSnackbarVariant.warning));
      expect(await replaced, const MentoraSnackbarResult.replaced());

      final cleared = service.current == null
          ? service.show(_demand())
          : Future.value(const MentoraSnackbarResult.cleared());
      service.clear();
      expect(await cleared, const MentoraSnackbarResult.cleared());
    });

    test('clearing takes everything with it — nothing waits behind a '
        'context that no longer exists', () async {
      final service = MentoraSnackbarService();
      addTearDown(service.dispose);

      final first = service.show(_demand());
      final second = service.queue(_demand());
      service.clear();

      expect(await first, const MentoraSnackbarResult.cleared());
      expect(await second, const MentoraSnackbarResult.cleared());
      expect(service.isShowing, isFalse);
      expect(service.pendingCount, 0);
    });

    test('ending nothing is refused, and clearing nothing is calm', () {
      final service = MentoraSnackbarService();
      addTearDown(service.dispose);

      expect(() => service.dismiss(), throwsStateError);
      service.clear();
      expect(service.isShowing, isFalse);
    });

    test('nothing is left waiting for an outcome that will never come', () async {
      final service = MentoraSnackbarService();
      final open = service.show(_demand());
      final pending = service.queue(_demand());

      service.dispose();
      expect(await open, const MentoraSnackbarResult.cleared());
      expect(await pending, const MentoraSnackbarResult.cleared());
    });
  });

  group('The host holds the guarantees a message owes', () {
    testWidgets('the message appears above the scene and leaves with '
        'its outcome', (tester) async {
      final (_, messages) = await _pumpHost(tester);

      final outcome = messages.show(_demand());
      await tester.pumpAndSettle();
      expect(find.byType(MentoraSnackbar), findsOneWidget);
      expect(find.text('La séance a été confirmée.'), findsOneWidget);

      messages.dismiss();
      await tester.pumpAndSettle();
      expect(await outcome, const MentoraSnackbarResult.dismissed());
      expect(find.byType(MentoraSnackbar), findsNothing);
    });

    testWidgets('it disappears alone: the reading time is served, then '
        'the message expires', (tester) async {
      final (_, messages) = await _pumpHost(tester);

      final outcome = messages.show(_demand());
      await tester.pumpAndSettle();
      expect(find.byType(MentoraSnackbar), findsOneWidget);

      await tester.pump(snackbarStandardDwell);
      await tester.pumpAndSettle();

      expect(await outcome, const MentoraSnackbarResult.expired());
      expect(find.byType(MentoraSnackbar), findsNothing);
    });

    testWidgets('a message that reports an ongoing state waits for that '
        'state to end', (tester) async {
      final (_, messages) = await _pumpHost(tester);

      final outcome = messages.show(_demand(MentoraSnackbarVariant.sync));
      await tester.pump();
      await tester.pump(snackbarExtendedDwell);
      await tester.pump();
      expect(
        find.byType(MentoraSnackbar),
        findsOneWidget,
        reason: 'it leaves when the state ends, never before',
      );

      messages.dismiss();
      await tester.pumpAndSettle();
      expect(await outcome, const MentoraSnackbarResult.dismissed());
    });

    testWidgets('it never touches the focus and never blocks a pointer '
        'aimed elsewhere', (tester) async {
      final sceneFocus = FocusNode(debugLabel: 'scene');
      addTearDown(sceneFocus.dispose);
      var scenePresses = 0;
      final services = await _services();
      final messages = services.get<MentoraSnackbarService>();
      await tester.pumpWidget(
        _scoped(
          services,
          child: MentoraSnackbarHost(
            service: messages,
            child: Scaffold(
              body: Align(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                  focusNode: sceneFocus,
                  onPressed: () => scenePresses++,
                  child: const Text('scène'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      sceneFocus.requestFocus();
      await tester.pumpAndSettle();

      messages.show(_demand());
      await tester.pumpAndSettle();
      expect(
        sceneFocus.hasFocus,
        isTrue,
        reason: 'a message never interrupts keyboard navigation',
      );

      // The act underneath is still reachable — the message ignores
      // pointers entirely.
      await tester.tap(find.text('scène'), warnIfMissed: false);
      await tester.pump();
      expect(scenePresses, 1);

      messages.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('a message that arrives while another speaks takes its '
        'place — the layer never stacks', (tester) async {
      final (_, messages) = await _pumpHost(tester);

      final first = messages.show(_demand());
      await tester.pumpAndSettle();
      messages.replace(
        const MentoraSnackbarRequest(
          variant: MentoraSnackbarVariant.warning,
          message: 'La connexion est instable.',
        ),
      );
      await tester.pumpAndSettle();

      expect(await first, const MentoraSnackbarResult.replaced());
      expect(find.byType(MentoraSnackbar), findsOneWidget);
      expect(find.text('La connexion est instable.'), findsOneWidget);

      messages.dismiss();
      await tester.pumpAndSettle();
    });

    testWidgets('the queue drains in order — one message at a time', (
      tester,
    ) async {
      final (_, messages) = await _pumpHost(tester);

      final first = messages.queue(_demand());
      messages.queue(
        const MentoraSnackbarRequest(
          variant: MentoraSnackbarVariant.success,
          message: 'Le dossier est à jour.',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MentoraSnackbar), findsOneWidget);

      await tester.pump(snackbarStandardDwell);
      await tester.pumpAndSettle();
      expect(await first, const MentoraSnackbarResult.expired());
      expect(find.text('Le dossier est à jour.'), findsOneWidget);

      messages.clear();
      await tester.pumpAndSettle();
    });

    testWidgets('the Motion preference commands the arrival, never the '
        'reading time', (tester) async {
      final (_, messages) = await _pumpHost(
        tester,
        appearance: const AppearanceState(motion: MotionPreference.none),
      );

      messages.show(_demand());
      // A single frame: with no motion, the message is already there.
      await tester.pump();
      expect(find.byType(MentoraSnackbar), findsOneWidget);
      expect(
        tester.widget<MentoraSnackbar>(find.byType(MentoraSnackbar)).state,
        isNot(MentoraSnackbarState.showing),
      );

      // …and it still stays long enough to be read.
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(MentoraSnackbar), findsOneWidget);

      await tester.pump(snackbarStandardDwell);
      await tester.pumpAndSettle();
      expect(find.byType(MentoraSnackbar), findsNothing);
    });
  });

  group('Governance — the executable scans ship with the component', () {
    Iterable<File> dartFilesOf(String path) => Directory(path)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    test('no Material snackbar and no messenger survive in the '
        'foundation', () {
      final forbidden = <String, RegExp>{
        'SnackBar': RegExp(r'(?<![A-Za-z])SnackBar\('),
        'ScaffoldMessenger': RegExp(r'(?<![A-Za-z])ScaffoldMessenger'),
        'showSnackBar': RegExp(r'(?<![A-Za-z])showSnackBar\('),
        'hideCurrentSnackBar': RegExp(r'(?<![A-Za-z])hideCurrentSnackBar\('),
        'removeCurrentSnackBar': RegExp(
          r'(?<![A-Za-z])removeCurrentSnackBar\(',
        ),
      };
      for (final file in dartFilesOf('lib/foundation')) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: a transient signal is a layer of the '
                'application, never a ${entry.key}',
          );
        }
      }
    });

    test('the message layer is never built outside the official '
        'service', () {
      for (final file in dartFilesOf('lib/foundation')) {
        final normalized = file.path.replaceAll('\\', '/');
        if (normalized.contains('components/snackbar/')) continue;
        if (normalized.contains('playground/')) continue;
        expect(
          RegExp(
            r'(?<![A-Za-z])MentoraSnackbar\(',
          ).hasMatch(file.readAsStringSync()),
          isFalse,
          reason:
              '${file.path}: a screen addresses the service, it never '
              'builds the layer',
        );
      }
    });

    test('a message never carries an act: the demand offers none', () {
      final request = File(
        'lib/foundation/design_kit/components/snackbar/'
        'mentora_snackbar_request.dart',
      ).readAsStringSync();
      for (final forbidden in const [
        'onPressed',
        'VoidCallback',
        'Action',
        'actions',
      ]) {
        expect(
          request.contains(forbidden),
          isFalse,
          reason: 'a message never asks: what is decided is a dialog',
        );
      }
    });

    test('no Core Component reads the ambient theme, and no duration or '
        'form is ever coded outside the Tokens', () {
      final coded = <String, RegExp>{
        'ambient theme': RegExp(r'Theme\.of\('),
        'coded duration': RegExp(r'Duration\((milliseconds|seconds)'),
        'coded radius': RegExp(r'BorderRadius\.\w+\(\s*[0-9]'),
        'coded padding': RegExp(r'EdgeInsets\.\w+\(\s*[0-9]'),
      };
      for (final file in dartFilesOf('lib/foundation')) {
        final normalized = file.path.replaceAll('\\', '/');
        final source = file.readAsStringSync();
        for (final entry in coded.entries) {
          if (entry.key != 'ambient theme' &&
              normalized.contains('design_kit/tokens/')) {
            continue;
          }
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason: '${file.path}: ${entry.key} — everything is a Token',
          );
        }
      }
    });

    test('the three overlay services share one queue — written once', () {
      for (final service in const [
        'lib/foundation/design_kit/components/dialog/mentora_dialog_service.dart',
        'lib/foundation/design_kit/components/bottom_sheet/mentora_bottom_sheet_service.dart',
        'lib/foundation/design_kit/components/snackbar/mentora_snackbar_service.dart',
      ]) {
        final source = File(service).readAsStringSync();
        expect(
          source.contains('OverlayDemandQueue'),
          isTrue,
          reason: '$service must not rewrite the queue',
        );
        expect(
          source.contains('Completer<'),
          isFalse,
          reason: '$service must not hold its own completers',
        );
      }
    });
  });
}
