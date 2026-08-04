import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/bootstrap/design_kit_bootstrap.dart';
import 'package:mentora/foundation/core/di/foundation_services.dart';
import 'package:mentora/foundation/design_kit/accessibility/accessibility_engine.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/components/design_kit_scope.dart';
import 'package:mentora/foundation/design_kit/components/dialog/mentora_dialog.dart';
import 'package:mentora/foundation/design_kit/components/dialog/mentora_dialog_host.dart';
import 'package:mentora/foundation/design_kit/components/dialog/mentora_dialog_request.dart';
import 'package:mentora/foundation/design_kit/components/dialog/mentora_dialog_service.dart';
import 'package:mentora/foundation/design_kit/components/dialog/mentora_dialog_style.dart';
import 'package:mentora/foundation/design_kit/components/dialog/mentora_dialog_theme.dart';
import 'package:mentora/foundation/design_kit/motion/motion_engine.dart';
import 'package:mentora/foundation/design_kit/registry/semantic_roles.dart';
import 'package:mentora/foundation/design_kit/registry/token_engines.dart';
import 'package:mentora/foundation/design_kit/theme/theme_engine.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';
import 'package:mentora/foundation/design_kit/tokens/surface_elevation_tokens.dart';

const MentoraDialogRequest _information = MentoraDialogRequest(
  variant: MentoraDialogVariant.information,
  title: 'Consultation reportée',
  message: 'La séance a été déplacée.',
  actions: [
    MentoraDialogAction(
      id: 'understood',
      label: 'Compris',
      intent: MentoraDialogActionIntent.recommended,
    ),
  ],
);

const MentoraDialogRequest _confirmation = MentoraDialogRequest(
  variant: MentoraDialogVariant.confirmation,
  title: 'Confirmer la séance',
  message: 'La séance sera confirmée au client.',
  actions: [
    MentoraDialogAction(id: 'back', label: 'Revenir'),
    MentoraDialogAction(
      id: 'confirm',
      label: 'Confirmer',
      intent: MentoraDialogActionIntent.recommended,
    ),
  ],
);

const MentoraDialogRequest _critical = MentoraDialogRequest(
  variant: MentoraDialogVariant.critical,
  title: 'Supprimer le dossier',
  message: 'Le dossier sera supprimé.',
  consequence: 'Les documents partagés seront perdus.',
  actions: [
    MentoraDialogAction(id: 'back', label: 'Revenir'),
    MentoraDialogAction(
      id: 'delete',
      label: 'Supprimer',
      intent: MentoraDialogActionIntent.dangerous,
    ),
  ],
);

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

/// The host, above a scene that owns a focusable act — so the focus
/// trap and its restoration can be observed.
Future<(FoundationServices, MentoraDialogService)> _pumpHost(
  WidgetTester tester, {
  ThemeVariantId variant = ThemeVariantId.light,
  AppearanceState appearance = const AppearanceState(),
  MentoraDialogController? controller,
  FocusNode? sceneFocus,
}) async {
  final services = await _services();
  final dialogs = services.get<MentoraDialogService>();
  await tester.pumpWidget(
    _scoped(
      services,
      variant: variant,
      appearance: appearance,
      child: MentoraDialogHost(
        service: dialogs,
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
  return (services, dialogs);
}

BoxDecoration _decorationOf(WidgetTester tester) {
  return tester
          .widget<DecoratedBox>(
            find
                .descendant(
                  of: find.byType(MentoraDialog),
                  matching: find.byType(DecoratedBox),
                )
                .first,
          )
          .decoration
      as BoxDecoration;
}

void main() {
  group('The request verifies its contracts at the door', () {
    test('a critical exchange states its consequence — a consequence is '
        'never hidden', () {
      expect(
        () => const MentoraDialogRequest(
          variant: MentoraDialogVariant.critical,
          title: 'Supprimer',
          message: 'Définitif.',
          actions: [
            MentoraDialogAction(id: 'a', label: 'a'),
            MentoraDialogAction(id: 'b', label: 'b'),
          ],
        ).verify(),
        throwsStateError,
      );
      _critical.verify();
    });

    test('an exchange that asks offers at least two ways out — a person '
        'is never forced', () {
      expect(
        () => const MentoraDialogRequest(
          variant: MentoraDialogVariant.confirmation,
          title: 'Confirmer',
          message: 'Maintenant.',
          actions: [MentoraDialogAction(id: 'only', label: 'Seul')],
        ).verify(),
        throwsStateError,
      );
    });

    test('one recommendation at most — two recommendations recommend '
        'nothing', () {
      expect(
        () => const MentoraDialogRequest(
          variant: MentoraDialogVariant.decision,
          title: 'Choisir',
          message: 'Deux chemins.',
          actions: [
            MentoraDialogAction(
              id: 'a',
              label: 'A',
              intent: MentoraDialogActionIntent.recommended,
            ),
            MentoraDialogAction(
              id: 'b',
              label: 'B',
              intent: MentoraDialogActionIntent.recommended,
            ),
          ],
        ).verify(),
        throwsStateError,
      );
    });

    test('an act without a name, a title without words and two acts '
        'sharing an identity are all refused', () {
      expect(
        () => const MentoraDialogRequest(
          variant: MentoraDialogVariant.information,
          title: '',
          message: 'x',
        ).verify(),
        throwsStateError,
      );
      expect(
        () => const MentoraDialogRequest(
          variant: MentoraDialogVariant.information,
          title: 'x',
          message: 'x',
          actions: [MentoraDialogAction(id: 'a', label: '')],
        ).verify(),
        throwsStateError,
      );
      expect(
        () => const MentoraDialogRequest(
          variant: MentoraDialogVariant.information,
          title: 'x',
          message: 'x',
          actions: [
            MentoraDialogAction(id: 'a', label: 'A'),
            MentoraDialogAction(id: 'a', label: 'B'),
          ],
        ).verify(),
        throwsStateError,
      );
    });

    test('the keyboard default is a recommendation, and never a danger', () {
      expect(_confirmation.keyboardDefault?.id, 'confirm');
      expect(
        const MentoraDialogRequest(
          variant: MentoraDialogVariant.critical,
          title: 'x',
          message: 'x',
          consequence: 'x',
          actions: [
            MentoraDialogAction(id: 'back', label: 'Revenir'),
            MentoraDialogAction(
              id: 'delete',
              label: 'Supprimer',
              intent: MentoraDialogActionIntent.dangerous,
            ),
          ],
        ).keyboardDefault,
        isNull,
      );
    });
  });

  group('The service carries demands, never business', () {
    test('show is immediate or refused — a demand is never silently '
        'deferred', () async {
      final service = MentoraDialogService();
      addTearDown(service.dispose);

      unawaited(service.show(_information));
      expect(service.current, _information);
      expect(() => service.show(_confirmation), throwsStateError);
    });

    test('queue waits its turn and opens as soon as the layer is free', () {
      final service = MentoraDialogService();
      addTearDown(service.dispose);

      unawaited(service.show(_information));
      unawaited(service.queue(_confirmation));
      expect(service.pendingCount, 1);

      service.close();
      expect(service.current, _confirmation);
      expect(service.pendingCount, 0);
    });

    test('every outcome reaches its caller — answered, dismissed, '
        'replaced, closed', () async {
      final service = MentoraDialogService();
      addTearDown(service.dispose);

      final answered = service.show(_confirmation);
      service.answer(_confirmation.actions.last);
      expect(await answered, const MentoraDialogResult.answered('confirm'));

      final dismissed = service.show(_information);
      service.dismiss();
      expect(await dismissed, const MentoraDialogResult.dismissed());

      final replaced = service.show(_information);
      unawaited(service.replace(_confirmation));
      expect(await replaced, const MentoraDialogResult.replaced());
      service.close();

      final closed = service.show(_information);
      service.close();
      expect(await closed, const MentoraDialogResult.closed());
    });

    test('a decision is answered, never abandoned: stepping back is '
        'refused where the meaning encloses', () {
      final service = MentoraDialogService();
      addTearDown(service.dispose);

      unawaited(service.show(_confirmation));
      expect(() => service.dismiss(), throwsStateError);
      expect(MentoraDialogService.allowsStepBack(_information), isTrue);
      expect(MentoraDialogService.allowsStepBack(_confirmation), isFalse);
    });

    test('closing, dismissing or answering nothing is refused', () {
      final service = MentoraDialogService();
      addTearDown(service.dispose);

      expect(() => service.close(), throwsStateError);
      expect(() => service.dismiss(), throwsStateError);
      expect(
        () => service.answer(const MentoraDialogAction(id: 'x', label: 'x')),
        throwsStateError,
      );
    });

    test('nothing is left waiting for an answer that will never come', () async {
      final service = MentoraDialogService();
      final open = service.show(_information);
      final pending = service.queue(_confirmation);

      service.dispose();
      expect(await open, const MentoraDialogResult.closed());
      expect(await pending, const MentoraDialogResult.closed());
    });
  });

  group('The layer expresses the exchange', () {
    testWidgets('a dialog carries an elevation MEANING: the aparté dims '
        'and lets one step back, the decision encloses', (tester) async {
      final services = await _services();
      final adapter = MentoraDialogTheme(
        colors: services.get<ColorTokenEngine>(),
        surfaces: services.get<SurfaceTokenEngine>(),
        spacing: services.get<SpacingTokenEngine>(),
        elevation: services.get<ElevationTokenEngine<ElevationExpression>>(),
        motion: services.get<MotionEngine>(),
        appearance: const AppearanceState(),
        variant: ThemeVariantId.light,
      );

      final aparte = adapter.expressionOf(MentoraDialogVariant.information);
      expect(aparte.dimsScene, isTrue);
      expect(aparte.blocksBelow, isFalse);
      expect(adapter.allowsStepBack(MentoraDialogVariant.information), isTrue);

      final decision = adapter.expressionOf(
        MentoraDialogVariant.confirmation,
      );
      expect(decision.blocksBelow, isTrue);
      expect(
        adapter.allowsStepBack(MentoraDialogVariant.confirmation),
        isFalse,
      );
      // Every dialog meaning is exclusive — which is why the service
      // queues instead of stacking.
      for (final variant in MentoraDialogVariant.values) {
        expect(adapter.expressionOf(variant).isExclusive, isTrue);
      }
    });

    testWidgets('the recommendation is visible, the danger stays '
        'explicit, the rest steps back', (tester) async {
      final services = await _services();
      await tester.pumpWidget(
        _scoped(
          services,
          child: Scaffold(
            body: MentoraDialog(
              request: _critical,
              state: MentoraDialogState.opened,
              onAction: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('dialog-action-back')), findsOneWidget);
      expect(find.byKey(const Key('dialog-action-delete')), findsOneWidget);
      // The consequence is on screen, never folded into the message.
      expect(find.text('Les documents partagés seront perdus.'), findsOneWidget);
    });

    testWidgets('each variant names its meaning with a role', (tester) async {
      final services = await _services();
      final colors = services.get<ColorTokenEngine>();
      for (final variant in const [
        (MentoraDialogVariant.information, ColorRole.information),
        (MentoraDialogVariant.success, ColorRole.success),
        (MentoraDialogVariant.warning, ColorRole.warning),
        (MentoraDialogVariant.critical, ColorRole.critical),
      ]) {
        await tester.pumpWidget(
          _scoped(
            services,
            child: Scaffold(
              body: MentoraDialog(
                request: MentoraDialogRequest(
                  variant: variant.$1,
                  title: 'titre',
                  message: 'message',
                  consequence: 'conséquence',
                ),
                state: MentoraDialogState.opened,
                onAction: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final icon = tester.widget<Icon>(
          find
              .descendant(
                of: find.byType(MentoraDialog),
                matching: find.byType(Icon),
              )
              .first,
        );
        expect(icon.color, colors.colorOf(variant.$2, ThemeVariantId.light));
      }
    });

    testWidgets('while the application works, no act is offered twice', (
      tester,
    ) async {
      final services = await _services();
      var acted = 0;
      await tester.pumpWidget(
        _scoped(
          services,
          child: Scaffold(
            body: MentoraDialog(
              request: _confirmation,
              state: MentoraDialogState.processing,
              onAction: (_) => acted++,
            ),
          ),
        ),
      );
      // A pending exchange shows a signal that never rests: the test
      // pumps, it never settles.
      await tester.pump();

      await tester.tap(find.byKey(const Key('dialog-action-confirm')));
      await tester.pump();
      expect(acted, 0);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('the four theme variants serve their own roles', (
      tester,
    ) async {
      final services = await _services();
      for (final variant in ThemeVariantId.values) {
        await tester.pumpWidget(
          _scoped(
            services,
            variant: variant,
            child: Scaffold(
              body: MentoraDialog(
                request: _information,
                state: MentoraDialogState.opened,
                onAction: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          _decorationOf(tester).color,
          services.get<SurfaceTokenEngine>().surfaceOf(
            SurfaceRole.protectedSurface,
            variant,
          ),
        );
      }
    });

    testWidgets('both reading directions are served without any special '
        'handling', (tester) async {
      final services = await _services();
      for (final direction in TextDirection.values) {
        await tester.pumpWidget(
          _scoped(
            services,
            direction: direction,
            child: Scaffold(
              body: MentoraDialog(
                request: _information,
                state: MentoraDialogState.opened,
                onAction: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('The host holds the guarantees a layer owes', () {
    testWidgets('the exchange opens above the scene and closes with its '
        'answer', (tester) async {
      final (_, dialogs) = await _pumpHost(tester);

      final answer = dialogs.show(_confirmation);
      await tester.pumpAndSettle();
      expect(find.byType(MentoraDialog), findsOneWidget);
      expect(find.text('Confirmer la séance'), findsOneWidget);

      await tester.tap(find.byKey(const Key('dialog-action-confirm')));
      await tester.pumpAndSettle();
      expect(await answer, const MentoraDialogResult.answered('confirm'));
      expect(find.byType(MentoraDialog), findsNothing);
    });

    testWidgets('the focus is trapped while it lasts and restored where '
        'it was', (tester) async {
      final sceneFocus = FocusNode(debugLabel: 'scene');
      addTearDown(sceneFocus.dispose);
      final (_, dialogs) = await _pumpHost(tester, sceneFocus: sceneFocus);

      sceneFocus.requestFocus();
      await tester.pumpAndSettle();
      expect(sceneFocus.hasFocus, isTrue);

      unawaited(dialogs.show(_confirmation));
      await tester.pumpAndSettle();
      // The scene below can no longer hold the focus.
      expect(sceneFocus.hasFocus, isFalse);
      expect(
        tester
            .widget<ExcludeFocus>(find.byKey(const Key('dialog-scene-focus')))
            .excluding,
        isTrue,
      );

      dialogs.answer(_confirmation.actions.first);
      await tester.pumpAndSettle();
      expect(sceneFocus.hasFocus, isTrue, reason: 'the focus comes home');
    });

    testWidgets('the scene below is silenced for screen readers', (
      tester,
    ) async {
      final (_, dialogs) = await _pumpHost(tester);
      expect(
        tester
            .widget<BlockSemantics>(
              find.byKey(const Key('dialog-scene-semantics')),
            )
            .blocking,
        isFalse,
      );

      unawaited(dialogs.show(_information));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<BlockSemantics>(
              find.byKey(const Key('dialog-scene-semantics')),
            )
            .blocking,
        isTrue,
      );
    });

    testWidgets('Escape steps back where stepping back exists — and is '
        'silent where it does not', (tester) async {
      final (_, dialogs) = await _pumpHost(tester);

      final dismissed = dialogs.show(_information);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(await dismissed, const MentoraDialogResult.dismissed());

      unawaited(dialogs.show(_confirmation));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(
        find.byType(MentoraDialog),
        findsOneWidget,
        reason: 'a decision is answered, never abandoned',
      );
    });

    testWidgets('Enter performs the recommendation — and never a '
        'dangerous act', (tester) async {
      final (_, dialogs) = await _pumpHost(tester);

      final answered = dialogs.show(_confirmation);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(await answered, const MentoraDialogResult.answered('confirm'));

      unawaited(dialogs.show(_critical));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(
        find.byType(MentoraDialog),
        findsOneWidget,
        reason: 'a dangerous act is always chosen deliberately',
      );
    });

    testWidgets('the barrier steps back only where the meaning allows '
        'it', (tester) async {
      final (_, dialogs) = await _pumpHost(tester);

      final dismissed = dialogs.show(_information);
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      expect(await dismissed, const MentoraDialogResult.dismissed());

      unawaited(dialogs.show(_confirmation));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      expect(find.byType(MentoraDialog), findsOneWidget);
    });

    testWidgets('the announced phase is expressed while the layer is '
        'settled', (tester) async {
      final controller = MentoraDialogController();
      addTearDown(controller.dispose);
      final (services, dialogs) = await _pumpHost(
        tester,
        controller: controller,
      );

      unawaited(dialogs.show(_confirmation));
      await tester.pumpAndSettle();

      controller.beginProcessing();
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      controller.showError();
      await tester.pump();
      expect(
        _decorationOf(tester).border?.top.color,
        services
            .get<ColorTokenEngine>()
            .colorOf(ColorRole.critical, ThemeVariantId.light),
      );

      controller.showSuccess();
      await tester.pump();
      expect(
        _decorationOf(tester).border?.top.color,
        services
            .get<ColorTokenEngine>()
            .colorOf(ColorRole.success, ThemeVariantId.light),
      );
    });

    testWidgets('the queue drains in order — one exchange at a time', (
      tester,
    ) async {
      final (_, dialogs) = await _pumpHost(tester);

      final first = dialogs.queue(_information);
      final second = dialogs.queue(_confirmation);
      await tester.pumpAndSettle();
      expect(find.text('Consultation reportée'), findsOneWidget);

      dialogs.dismiss();
      await tester.pumpAndSettle();
      expect(await first, const MentoraDialogResult.dismissed());
      expect(find.text('Confirmer la séance'), findsOneWidget);

      dialogs.answer(_confirmation.actions.last);
      await tester.pumpAndSettle();
      expect(await second, const MentoraDialogResult.answered('confirm'));
      expect(find.byType(MentoraDialog), findsNothing);
    });

    testWidgets('the Motion preference commands the arrival: None makes '
        'it instantaneous, never absent', (tester) async {
      final (_, dialogs) = await _pumpHost(
        tester,
        appearance: const AppearanceState(motion: MotionPreference.none),
      );

      unawaited(dialogs.show(_information));
      // A single frame: with no motion, the layer is already there.
      await tester.pump();
      expect(find.byType(MentoraDialog), findsOneWidget);
      expect(
        tester.widget<Opacity>(
          find
              .ancestor(
                of: find.byType(MentoraDialog),
                matching: find.byType(Opacity),
              )
              .last,
        ).opacity,
        1.0,
      );
    });
  });

  group('Governance — the executable scans ship with the component', () {
    Iterable<File> dartFilesOf(String path) => Directory(path)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    test('no Material dialog and no imperative opening survive in the '
        'foundation', () {
      final forbidden = <String, RegExp>{
        'AlertDialog': RegExp(r'(?<![A-Za-z])AlertDialog\('),
        'Dialog': RegExp(r'(?<![A-Za-z])Dialog\('),
        'SimpleDialog': RegExp(r'(?<![A-Za-z])SimpleDialog\('),
        'showDialog': RegExp(r'(?<![A-Za-z])showDialog\('),
        'showAdaptiveDialog': RegExp(r'(?<![A-Za-z])showAdaptiveDialog\('),
      };
      for (final file in dartFilesOf('lib/foundation')) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: an exchange is a layer of the application, '
                'never a ${entry.key}',
          );
        }
      }
    });

    test('no Core Component reads the ambient theme, and no duration is '
        'ever coded', () {
      for (final file in dartFilesOf('lib/foundation')) {
        final normalized = file.path.replaceAll('\\', '/');
        final source = file.readAsStringSync();
        expect(
          RegExp(r'Theme\.of\(').hasMatch(source),
          isFalse,
          reason: '${file.path}: the scope serves, the ambient theme does not',
        );
        if (normalized.contains('design_kit/tokens/')) continue;
        expect(
          RegExp(r'Duration\((milliseconds|seconds)').hasMatch(source),
          isFalse,
          reason: '${file.path}: every duration comes from the Motion Engine',
        );
      }
    });

    test('the dialog layer is never opened outside the official '
        'service', () {
      for (final file in dartFilesOf('lib/foundation')) {
        final normalized = file.path.replaceAll('\\', '/');
        if (normalized.contains('components/dialog/')) continue;
        if (normalized.contains('playground/')) continue;
        expect(
          RegExp(r'(?<![A-Za-z])MentoraDialog\(').hasMatch(
            file.readAsStringSync(),
          ),
          isFalse,
          reason:
              '${file.path}: a screen addresses the service, it never '
              'builds the layer',
        );
      }
    });
  });
}

/// Explicitly ignoring a future is a decision, not an oversight: the
/// outcome is asserted elsewhere in the same test.
void unawaited(Future<Object?> future) {}
