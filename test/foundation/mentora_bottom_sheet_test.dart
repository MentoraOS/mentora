import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/bootstrap/design_kit_bootstrap.dart';
import 'package:mentora/foundation/core/di/foundation_services.dart';
import 'package:mentora/foundation/design_kit/accessibility/accessibility_engine.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/components/bottom_sheet/mentora_bottom_sheet.dart';
import 'package:mentora/foundation/design_kit/components/bottom_sheet/mentora_bottom_sheet_host.dart';
import 'package:mentora/foundation/design_kit/components/bottom_sheet/mentora_bottom_sheet_request.dart';
import 'package:mentora/foundation/design_kit/components/bottom_sheet/mentora_bottom_sheet_service.dart';
import 'package:mentora/foundation/design_kit/components/bottom_sheet/mentora_bottom_sheet_style.dart';
import 'package:mentora/foundation/design_kit/components/bottom_sheet/mentora_bottom_sheet_theme.dart';
import 'package:mentora/foundation/design_kit/components/design_kit_scope.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text_role.dart';
import 'package:mentora/foundation/design_kit/motion/motion_engine.dart';
import 'package:mentora/foundation/design_kit/registry/semantic_roles.dart';
import 'package:mentora/foundation/design_kit/registry/token_engines.dart';
import 'package:mentora/foundation/design_kit/theme/theme_engine.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';
import 'package:mentora/foundation/design_kit/tokens/bottom_sheet_tokens.dart';
import 'package:mentora/foundation/design_kit/tokens/surface_elevation_tokens.dart';

MentoraBottomSheetRequest _demand([
  MentoraBottomSheetVariant variant = MentoraBottomSheetVariant.standard,
]) {
  return MentoraBottomSheetRequest(
    variant: variant,
    title: 'Filtrer les consultations',
    content: const MentoraText('Contenu', role: MentoraTextRole.body),
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

/// The host, above a scene that owns a focusable act — so the focus
/// trap and its restoration can be observed.
Future<(FoundationServices, MentoraBottomSheetService)> _pumpHost(
  WidgetTester tester, {
  ThemeVariantId variant = ThemeVariantId.light,
  AppearanceState appearance = const AppearanceState(),
  MentoraBottomSheetController? controller,
  FocusNode? sceneFocus,
}) async {
  final services = await _services();
  final sheets = services.get<MentoraBottomSheetService>();
  await tester.pumpWidget(
    _scoped(
      services,
      variant: variant,
      appearance: appearance,
      child: MentoraBottomSheetHost(
        service: sheets,
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
  return (services, sheets);
}

BoxDecoration _decorationOf(WidgetTester tester) {
  return tester
          .widget<DecoratedBox>(
            find
                .descendant(
                  of: find.byType(MentoraBottomSheet),
                  matching: find.byType(DecoratedBox),
                )
                .first,
          )
          .decoration
      as BoxDecoration;
}

MentoraBottomSheetTheme _adapter(FoundationServices services) {
  return MentoraBottomSheetTheme(
    colors: services.get<ColorTokenEngine>(),
    surfaces: services.get<SurfaceTokenEngine>(),
    spacing: services.get<SpacingTokenEngine>(),
    elevation: services.get<ElevationTokenEngine<ElevationExpression>>(),
    motion: services.get<MotionEngine>(),
    accessibility: services.get<AccessibilityEngine>(),
    appearance: const AppearanceState(),
    variant: ThemeVariantId.light,
  );
}

void main() {
  group('A sheet accompanies — it never encloses', () {
    testWidgets('its elevation meaning is always the aparté: it dims '
        'without blocking, whatever the variant', (tester) async {
      final services = await _services();
      final adapter = _adapter(services);

      expect(bottomSheetElevationMeaning, ElevationMeaning.aparte);
      expect(adapter.expression.dimsScene, isTrue);
      expect(
        adapter.expression.blocksBelow,
        isFalse,
        reason: 'what must be answered is a dialog, never a sheet',
      );
    });

    test('a sheet never occupies room without a reason: each variant '
        'declares where it rests and whether it may grow', () {
      expect(
        initialDetentOf(MentoraBottomSheetVariant.editor),
        MentoraBottomSheetDetent.expanded,
      );
      expect(
        initialDetentOf(MentoraBottomSheetVariant.expanded),
        MentoraBottomSheetDetent.expanded,
      );
      for (final variant in const [
        MentoraBottomSheetVariant.standard,
        MentoraBottomSheetVariant.action,
        MentoraBottomSheetVariant.selection,
        MentoraBottomSheetVariant.filter,
        MentoraBottomSheetVariant.preview,
        MentoraBottomSheetVariant.custom,
      ]) {
        expect(initialDetentOf(variant), MentoraBottomSheetDetent.collapsed);
      }
      // A short list of acts never grows to fill a screen it does not
      // need.
      expect(isExpandable(MentoraBottomSheetVariant.action), isFalse);
      for (final variant in MentoraBottomSheetVariant.values) {
        if (variant == MentoraBottomSheetVariant.action) continue;
        expect(isExpandable(variant), isTrue);
      }
    });

    test('a demand without a title announces nothing', () {
      expect(
        () => MentoraBottomSheetRequest(
          variant: MentoraBottomSheetVariant.standard,
          title: '',
          content: const SizedBox.shrink(),
        ).verify(),
        throwsStateError,
      );
      _demand().verify();
    });
  });

  group('The layer expresses the accompaniment', () {
    testWidgets('every variant resolves its official surface — the '
        'preview rests on the calm one', (tester) async {
      final services = await _services();
      final surfaces = services.get<SurfaceTokenEngine>();
      for (final variant in MentoraBottomSheetVariant.values) {
        await tester.pumpWidget(
          _scoped(
            services,
            child: Scaffold(
              body: MentoraBottomSheet(
                request: _demand(variant),
                state: MentoraBottomSheetState.opened,
                detent: initialDetentOf(variant),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          _decorationOf(tester).color,
          surfaces.surfaceOf(
            variant == MentoraBottomSheetVariant.preview
                ? SurfaceRole.secondarySurface
                : SurfaceRole.primarySurface,
            ThemeVariantId.light,
          ),
          reason: '${variant.name} must speak a surface role',
        );
      }
    });

    testWidgets('only what rises above the scene is rounded — a sheet '
        'is anchored to the bottom', (tester) async {
      final services = await _services();
      await tester.pumpWidget(
        _scoped(
          services,
          child: Scaffold(
            body: MentoraBottomSheet(
              request: _demand(),
              state: MentoraBottomSheetState.opened,
              detent: MentoraBottomSheetDetent.collapsed,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final radius = _decorationOf(tester).borderRadius! as BorderRadius;
      expect(radius.topLeft, Radius.circular(bottomSheetCornerRadius));
      expect(radius.bottomLeft, Radius.zero);
    });

    testWidgets('the grip is painted discreet and reachable large — and '
        'absent where nothing may be moved', (tester) async {
      final services = await _services();
      await tester.pumpWidget(
        _scoped(
          services,
          child: Scaffold(
            body: MentoraBottomSheet(
              request: _demand(MentoraBottomSheetVariant.selection),
              state: MentoraBottomSheetState.opened,
              detent: MentoraBottomSheetDetent.collapsed,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byKey(const Key('sheet-handle'))).height,
        greaterThanOrEqualTo(48),
      );

      await tester.pumpWidget(
        _scoped(
          services,
          child: Scaffold(
            body: MentoraBottomSheet(
              request: _demand(MentoraBottomSheetVariant.action),
              state: MentoraBottomSheetState.opened,
              detent: MentoraBottomSheetDetent.collapsed,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sheet-handle')), findsNothing);
    });

    testWidgets('while it is held, the sheet says so', (tester) async {
      final services = await _services();
      final colors = services.get<ColorTokenEngine>();
      for (final entry in const [
        (MentoraBottomSheetState.dragging, ColorRole.focus),
        (MentoraBottomSheetState.collapsed, ColorRole.outline),
      ]) {
        await tester.pumpWidget(
          _scoped(
            services,
            child: Scaffold(
              body: MentoraBottomSheet(
                request: _demand(),
                state: entry.$1,
                detent: MentoraBottomSheetDetent.collapsed,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          (_decorationOf(tester).border! as Border).top.color,
          colors.colorOf(entry.$2, ThemeVariantId.light),
        );
      }
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
              body: MentoraBottomSheet(
                request: _demand(),
                state: MentoraBottomSheetState.opened,
                detent: MentoraBottomSheetDetent.collapsed,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          _decorationOf(tester).color,
          services.get<SurfaceTokenEngine>().surfaceOf(
            SurfaceRole.primarySurface,
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
              body: MentoraBottomSheet(
                request: _demand(),
                state: MentoraBottomSheetState.opened,
                detent: MentoraBottomSheetDetent.collapsed,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('The service carries demands, never business', () {
    test('show is immediate or refused; queue waits its turn', () {
      final service = MentoraBottomSheetService();
      addTearDown(service.dispose);

      service.show(_demand());
      expect(service.current, isNotNull);
      expect(() => service.show(_demand()), throwsStateError);

      service.queue(_demand(MentoraBottomSheetVariant.filter));
      expect(service.pendingCount, 1);

      service.close();
      expect(service.current?.variant, MentoraBottomSheetVariant.filter);
      expect(service.pendingCount, 0);
    });

    test('a sheet always steps back — it disappears as soon as its '
        'purpose is served', () async {
      final service = MentoraBottomSheetService();
      addTearDown(service.dispose);

      final dismissed = service.show(_demand());
      service.dismiss();
      expect(await dismissed, const MentoraBottomSheetResult.dismissed());
      expect(service.isBusy, isFalse);
    });

    test('every outcome reaches its caller', () async {
      final service = MentoraBottomSheetService();
      addTearDown(service.dispose);

      final replaced = service.show(_demand());
      service.replace(_demand(MentoraBottomSheetVariant.editor));
      expect(await replaced, const MentoraBottomSheetResult.replaced());

      final closed = service.current == null
          ? service.show(_demand())
          : Future.value(const MentoraBottomSheetResult.closed());
      service.close();
      expect(await closed, const MentoraBottomSheetResult.closed());
    });

    test('the detent follows the demand, and expanding is refused '
        'where the variant has no reason to grow', () {
      final service = MentoraBottomSheetService();
      addTearDown(service.dispose);

      service.show(_demand(MentoraBottomSheetVariant.editor));
      expect(service.detent, MentoraBottomSheetDetent.expanded);
      service.collapse();
      expect(service.detent, MentoraBottomSheetDetent.collapsed);
      service.expand();
      expect(service.detent, MentoraBottomSheetDetent.expanded);
      service.close();

      service.show(_demand(MentoraBottomSheetVariant.action));
      expect(service.detent, MentoraBottomSheetDetent.collapsed);
      expect(() => service.expand(), throwsStateError);
    });

    test('closing, dismissing, expanding or collapsing nothing is '
        'refused', () {
      final service = MentoraBottomSheetService();
      addTearDown(service.dispose);

      expect(() => service.close(), throwsStateError);
      expect(() => service.dismiss(), throwsStateError);
      expect(() => service.expand(), throwsStateError);
      expect(() => service.collapse(), throwsStateError);
    });

    test('nothing is left waiting for an answer that will never come', () async {
      final service = MentoraBottomSheetService();
      final open = service.show(_demand());
      final pending = service.queue(_demand());

      service.dispose();
      expect(await open, const MentoraBottomSheetResult.closed());
      expect(await pending, const MentoraBottomSheetResult.closed());
    });
  });

  group('The host holds the guarantees a layer owes', () {
    testWidgets('the sheet rises above the scene and leaves with its '
        'outcome', (tester) async {
      final (_, sheets) = await _pumpHost(tester);

      final outcome = sheets.show(_demand());
      await tester.pumpAndSettle();
      expect(find.byType(MentoraBottomSheet), findsOneWidget);
      expect(find.text('Filtrer les consultations'), findsOneWidget);

      sheets.dismiss();
      await tester.pumpAndSettle();
      expect(await outcome, const MentoraBottomSheetResult.dismissed());
      expect(find.byType(MentoraBottomSheet), findsNothing);
    });

    testWidgets('the focus is trapped while it lasts and restored where '
        'it was', (tester) async {
      final sceneFocus = FocusNode(debugLabel: 'scene');
      addTearDown(sceneFocus.dispose);
      final (_, sheets) = await _pumpHost(tester, sceneFocus: sceneFocus);

      sceneFocus.requestFocus();
      await tester.pumpAndSettle();
      expect(sceneFocus.hasFocus, isTrue);

      sheets.show(_demand());
      await tester.pumpAndSettle();
      expect(sceneFocus.hasFocus, isFalse);
      expect(
        tester
            .widget<ExcludeFocus>(find.byKey(const Key('sheet-scene-focus')))
            .excluding,
        isTrue,
      );

      sheets.dismiss();
      await tester.pumpAndSettle();
      expect(sceneFocus.hasFocus, isTrue, reason: 'the focus comes home');
    });

    testWidgets('the scene below is silenced for screen readers', (
      tester,
    ) async {
      final (_, sheets) = await _pumpHost(tester);
      expect(
        tester
            .widget<BlockSemantics>(
              find.byKey(const Key('sheet-scene-semantics')),
            )
            .blocking,
        isFalse,
      );

      sheets.show(_demand());
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<BlockSemantics>(
              find.byKey(const Key('sheet-scene-semantics')),
            )
            .blocking,
        isTrue,
      );
    });

    testWidgets('Escape and the barrier both step back — a sheet never '
        'holds anyone', (tester) async {
      final (_, sheets) = await _pumpHost(tester);

      final byKey = sheets.show(_demand());
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(await byKey, const MentoraBottomSheetResult.dismissed());

      final byBarrier = sheets.show(_demand());
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      expect(await byBarrier, const MentoraBottomSheetResult.dismissed());
    });

    testWidgets('the detent is a ceiling, never a forced height: a '
        'modest sheet stays modest', (tester) async {
      final (services, sheets) = await _pumpHost(tester);
      final adapter = _adapter(services);
      final available = tester.getSize(find.byType(MentoraBottomSheetHost));

      sheets.show(_demand(MentoraBottomSheetVariant.selection));
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(MentoraBottomSheet)).height,
        lessThan(
          available.height *
              adapter.fractionOf(MentoraBottomSheetDetent.collapsed),
        ),
        reason: 'a sheet never occupies room without a reason',
      );
    });

    testWidgets('a sheet that wants everything is held at its detent — '
        'and expanding raises the ceiling', (tester) async {
      final (services, sheets) = await _pumpHost(tester);
      final adapter = _adapter(services);
      final available = tester.getSize(find.byType(MentoraBottomSheetHost));

      sheets.show(
        MentoraBottomSheetRequest(
          variant: MentoraBottomSheetVariant.selection,
          title: 'Filtrer les consultations',
          content: const SizedBox(height: 4000),
        ),
      );
      await tester.pumpAndSettle();
      final collapsed = tester.getSize(find.byType(MentoraBottomSheet)).height;
      expect(
        collapsed,
        closeTo(
          available.height *
              adapter.fractionOf(MentoraBottomSheetDetent.collapsed),
          1,
        ),
      );

      sheets.expand();
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(MentoraBottomSheet)).height,
        closeTo(
          available.height *
              adapter.fractionOf(MentoraBottomSheetDetent.expanded),
          1,
        ),
      );
    });

    testWidgets('a held sheet says it is held, and a released gesture '
        'settles on the nearest detent', (tester) async {
      final (_, sheets) = await _pumpHost(tester);
      sheets.show(_demand(MentoraBottomSheetVariant.selection));
      await tester.pumpAndSettle();

      final handle = tester.getCenter(find.byKey(const Key('sheet-handle')));
      final gesture = await tester.startGesture(handle);
      await gesture.moveBy(const Offset(0, -260));
      await tester.pump();
      expect(
        tester.widget<MentoraBottomSheet>(find.byType(MentoraBottomSheet)).state,
        MentoraBottomSheetState.dragging,
      );

      await gesture.up();
      await tester.pumpAndSettle();
      expect(sheets.detent, MentoraBottomSheetDetent.expanded);
    });

    testWidgets('a gesture that says "I am done" lets the sheet go', (
      tester,
    ) async {
      final (_, sheets) = await _pumpHost(tester);
      final outcome = sheets.show(_demand(MentoraBottomSheetVariant.selection));
      await tester.pumpAndSettle();

      await tester.drag(
        find.byKey(const Key('sheet-handle')),
        const Offset(0, 300),
      );
      await tester.pumpAndSettle();

      expect(await outcome, const MentoraBottomSheetResult.dismissed());
      expect(find.byType(MentoraBottomSheet), findsNothing);
    });

    testWidgets('the announced work is expressed while the sheet is '
        'settled', (tester) async {
      final controller = MentoraBottomSheetController();
      addTearDown(controller.dispose);
      final (_, sheets) = await _pumpHost(tester, controller: controller);

      sheets.show(_demand());
      await tester.pumpAndSettle();

      controller.beginProcessing();
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.widget<MentoraBottomSheet>(find.byType(MentoraBottomSheet)).state,
        MentoraBottomSheetState.processing,
      );

      controller.reset();
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('the queue drains in order — one accompaniment at a '
        'time', (tester) async {
      final (_, sheets) = await _pumpHost(tester);

      final first = sheets.queue(_demand());
      sheets.queue(_demand(MentoraBottomSheetVariant.editor));
      await tester.pumpAndSettle();
      expect(find.byType(MentoraBottomSheet), findsOneWidget);

      sheets.dismiss();
      await tester.pumpAndSettle();
      expect(await first, const MentoraBottomSheetResult.dismissed());
      expect(
        sheets.current?.variant,
        MentoraBottomSheetVariant.editor,
      );
      // The next demand arrives where it declared it rests.
      expect(sheets.detent, MentoraBottomSheetDetent.expanded);
    });

    testWidgets('the Motion preference commands the arrival: None makes '
        'it instantaneous, never absent', (tester) async {
      final (_, sheets) = await _pumpHost(
        tester,
        appearance: const AppearanceState(motion: MotionPreference.none),
      );

      sheets.show(_demand());
      // A single frame: with no motion, the sheet is already there.
      await tester.pump();
      expect(find.byType(MentoraBottomSheet), findsOneWidget);
      expect(
        tester.widget<MentoraBottomSheet>(find.byType(MentoraBottomSheet)).state,
        isNot(MentoraBottomSheetState.opening),
      );
    });
  });

  group('Governance — the executable scans ship with the component', () {
    Iterable<File> dartFilesOf(String path) => Directory(path)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    test('no Material bottom sheet and no imperative opening survive in '
        'the foundation', () {
      final forbidden = <String, RegExp>{
        'showModalBottomSheet': RegExp(
          r'(?<![A-Za-z])showModalBottomSheet\(',
        ),
        'showBottomSheet': RegExp(r'(?<![A-Za-z])showBottomSheet\('),
        'BottomSheet': RegExp(r'(?<![A-Za-z])BottomSheet\('),
        'ModalBottomSheetRoute': RegExp(
          r'(?<![A-Za-z])ModalBottomSheetRoute\(',
        ),
      };
      for (final file in dartFilesOf('lib/foundation')) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: an accompaniment is a layer of the '
                'application, never a ${entry.key}',
          );
        }
      }
    });

    test('the sheet layer is never built outside the official service', () {
      for (final file in dartFilesOf('lib/foundation')) {
        final normalized = file.path.replaceAll('\\', '/');
        if (normalized.contains('components/bottom_sheet/')) continue;
        if (normalized.contains('playground/')) continue;
        expect(
          RegExp(
            r'(?<![A-Za-z])MentoraBottomSheet\(',
          ).hasMatch(file.readAsStringSync()),
          isFalse,
          reason:
              '${file.path}: a screen addresses the service, it never '
              'builds the layer',
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

    test('the overlay queue is written once and shared by both '
        'services', () {
      final shared = File(
        'lib/foundation/design_kit/components/overlay/overlay_demand_queue.dart',
      );
      expect(shared.existsSync(), isTrue);
      for (final service in const [
        'lib/foundation/design_kit/components/dialog/mentora_dialog_service.dart',
        'lib/foundation/design_kit/components/bottom_sheet/mentora_bottom_sheet_service.dart',
      ]) {
        expect(
          File(service).readAsStringSync().contains('OverlayDemandQueue'),
          isTrue,
          reason: '$service must not rewrite the queue',
        );
        expect(
          File(service).readAsStringSync().contains('Completer<'),
          isFalse,
          reason: '$service must not hold its own completers',
        );
      }
    });
  });
}
