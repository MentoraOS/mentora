import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/bootstrap/design_kit_bootstrap.dart';
import 'package:mentora/foundation/core/di/foundation_services.dart';
import 'package:mentora/foundation/design_kit/accessibility/accessibility_engine.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/components/design_kit_scope.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text_role.dart';
import 'package:mentora/foundation/design_kit/motion/motion_engine.dart';
import 'package:mentora/foundation/design_kit/registry/semantic_roles.dart';
import 'package:mentora/foundation/design_kit/registry/token_engines.dart';
import 'package:mentora/foundation/design_kit/structure/split_view/mentora_split_view.dart';
import 'package:mentora/foundation/design_kit/structure/split_view/mentora_split_view_style.dart';
import 'package:mentora/foundation/design_kit/theme/theme_engine.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';
import 'package:mentora/foundation/design_kit/tokens/split_view_tokens.dart';
import 'package:mentora/foundation/design_kit/tokens/surface_elevation_tokens.dart';

/// The contents the application owns — recognisable, and never touched
/// by the workspace that shares the room between them.
Widget _content(String id) => MentoraText(
  'Contenu $id',
  key: Key('content-$id'),
  role: MentoraTextRole.body,
);

/// Says "the test did not choose a name" — distinct from choosing
/// none, which is what the fail-closed contract refuses.
const String _named = '<named by the region>';

MentoraSplitRegion _regionOf(
  String id, {
  MentoraSplitRegionVisibility visibility = MentoraSplitRegionVisibility.shown,
  String? resizeSemanticLabel = _named,
  String? semanticLabel,
}) {
  return MentoraSplitRegion(
    id: id,
    semanticLabel: semanticLabel ?? 'Région $id',
    content: _content(id),
    visibility: visibility,
    // Every separation is named for the region it changes: two
    // controls never share one name.
    resizeSemanticLabel: resizeSemanticLabel == _named
        ? 'Redimensionner $id'
        : resizeSemanticLabel,
  );
}

const MentoraSplitLayoutSpecification _layout = MentoraSplitLayoutSpecification(
  extents: {'navigation': 240, 'inspector': 280},
  fillsRemainingRegionId: 'workspace',
);

Future<FoundationServices> _services() async {
  final services = FoundationServices();
  await const DesignKitBootstrapStep().run(services);
  return services;
}

MentoraSplitView _split({
  List<MentoraSplitRegion>? regions,
  MentoraSplitLayoutSpecification layout = _layout,
  ValueChanged<MentoraSplitResizeIntention>? onResizeRequested,
}) {
  return MentoraSplitView(
    regions:
        regions ??
        [
          _regionOf('navigation'),
          _regionOf('workspace'),
          _regionOf('inspector'),
        ],
    layout: layout,
    onResizeRequested: onResizeRequested,
  );
}

Future<FoundationServices> _pump(
  WidgetTester tester,
  Widget workspace, {
  ThemeVariantId variant = ThemeVariantId.light,
  AppearanceState appearance = const AppearanceState(),
  TextDirection direction = TextDirection.ltr,
  Size room = const Size(1000, 600),
}) async {
  final services = await _services();
  // The application decides the room the workspace is given: the
  // surface is set here, once, and never read by the component.
  tester.view.physicalSize = room;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
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
        child: Directionality(
          textDirection: direction,
          // The application decides the room; the workspace expresses
          // what it is given.
          child: Center(
            child: SizedBox(
              width: room.width,
              height: room.height,
              child: workspace,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return services;
}

Finder _region(String id) => find.byKey(Key('split-view-region-$id'));
Finder _separator(String id) => find.byKey(Key('split-view-separator-$id'));
Finder _grab(String id) => find.byKey(Key('split-view-grab-$id'));

void main() {
  group('MentoraSplitView — the shared workspace', () {
    testWidgets('every region is designated by its identity, and the '
        'room announced for it is the room it takes', (tester) async {
      await _pump(tester, _split());

      final navigation = tester.getRect(_region('navigation'));
      final workspace = tester.getRect(_region('workspace'));
      final inspector = tester.getRect(_region('inspector'));

      expect(navigation.width, _layout.extentOf('navigation'));
      expect(inspector.width, _layout.extentOf('inspector'));
      // What is left is exactly what is left — never a share.
      expect(
        workspace.width,
        1000 -
            _layout.extentOf('navigation')! -
            _layout.extentOf('inspector')! -
            2 * splitViewSeparatorThickness,
      );
      expect(workspace.left, navigation.right + splitViewSeparatorThickness);
      expect(inspector.left, workspace.right + splitViewSeparatorThickness);
    });

    testWidgets('the announced room never moves when the room around it '
        'does: nothing is measured, nothing is computed', (tester) async {
      await _pump(tester, _split());
      final narrow = tester.getRect(_region('navigation')).width;

      await _pump(tester, _split(), room: const Size(1600, 900));
      expect(tester.getRect(_region('navigation')).width, narrow);
      expect(
        tester.getRect(_region('inspector')).width,
        _layout.extentOf('inspector'),
      );
      // Only what is left changed, because only the room changed.
      expect(tester.getRect(_region('workspace')).width, greaterThan(600));
    });

    testWidgets('a workspace carries its regions, and changes nothing '
        'about what they hold', (tester) async {
      await _pump(tester, _split());

      for (final id in const ['navigation', 'workspace', 'inspector']) {
        expect(
          tester.getTopLeft(find.byKey(Key('content-$id'))),
          tester.getTopLeft(_region(id)),
          reason: 'a workspace adds nothing around the regions it holds',
        );
      }
    });

    testWidgets('the region that takes what is left is named by its '
        'identity, wherever it was announced', (tester) async {
      // The same three identities, announced in another order, with
      // the filling one first: no position exists anywhere.
      await _pump(
        tester,
        _split(
          regions: [
            _regionOf('workspace'),
            _regionOf('navigation'),
            _regionOf('inspector'),
          ],
        ),
      );

      final workspace = tester.getRect(_region('workspace'));
      final navigation = tester.getRect(_region('navigation'));
      expect(workspace.left, 0);
      expect(navigation.width, _layout.extentOf('navigation'));
      expect(navigation.left, workspace.right + splitViewSeparatorThickness);
      expect(tester.getRect(_region('inspector')).right, 1000);
    });

    testWidgets('a region that is hidden does not exist: it is not '
        'built, and nothing of it is reachable', (tester) async {
      await _pump(
        tester,
        _split(
          regions: [
            _regionOf('navigation'),
            _regionOf('workspace'),
            _regionOf(
              'inspector',
              visibility: MentoraSplitRegionVisibility.hidden,
            ),
          ],
        ),
      );

      expect(_region('inspector'), findsNothing);
      expect(find.byKey(const Key('content-inspector')), findsNothing);
      expect(_separator('inspector'), findsNothing);
      // The room it held goes back to what is left, and to nothing else.
      expect(tester.getRect(_region('workspace')).right, 1000);
      expect(
        tester.getRect(_region('navigation')).width,
        _layout.extentOf('navigation'),
      );
    });

    testWidgets('the workspace is shared along the announced axis, and '
        'reads no orientation of its own', (tester) async {
      await _pump(
        tester,
        _split(
          layout: const MentoraSplitLayoutSpecification(
            axis: MentoraSplitAxis.vertical,
            extents: {'navigation': 240, 'inspector': 280},
            fillsRemainingRegionId: 'workspace',
          ),
        ),
      );

      final navigation = tester.getRect(_region('navigation'));
      final workspace = tester.getRect(_region('workspace'));
      expect(navigation.height, 240);
      expect(navigation.width, 1000);
      expect(workspace.top, navigation.bottom + splitViewSeparatorThickness);
      expect(tester.getRect(_region('inspector')).height, 280);
    });

    testWidgets('a separation says that two regions exist, and carries '
        'no decoration', (tester) async {
      final services = await _pump(tester, _split());
      final colors = services.get<ColorTokenEngine>();

      // One separation per region that owns one — never one more.
      expect(_separator('navigation'), findsOneWidget);
      expect(_separator('inspector'), findsOneWidget);
      expect(find.byType(MentoraSplitView), findsOneWidget);

      final line = tester.widget<AnimatedContainer>(_separator('navigation'));
      final decoration = line.decoration as BoxDecoration?;
      expect(
        decoration?.color,
        colors.colorOf(ColorRole.divider, ThemeVariantId.light),
      );
      expect(decoration?.border, isNull);
      expect(decoration?.borderRadius, isNull);
      expect(decoration?.boxShadow, isNull);
      expect(decoration?.gradient, isNull);
      expect(
        tester.getSize(_separator('navigation')).width,
        splitViewSeparatorThickness,
      );
    });

    testWidgets('a workspace that cannot be moved offers nothing to take '
        'hold of', (tester) async {
      await _pump(tester, _split());

      expect(_grab('navigation'), findsNothing);
      expect(find.byType(GestureDetector), findsNothing);
      expect(_separator('navigation'), findsOneWidget);
    });

    testWidgets('moving a separation is reported, never performed', (
      tester,
    ) async {
      final asked = <MentoraSplitResizeIntention>[];
      await _pump(tester, _split(onResizeRequested: asked.add));

      final before = tester.getRect(_region('navigation'));
      await tester.drag(_grab('navigation'), const Offset(40, 0));
      await tester.pumpAndSettle();

      expect(asked, isNotEmpty);
      expect(asked.first.regionId, 'navigation');
      expect(asked.first.delta, greaterThan(0));
      // Nothing was performed: the room is exactly the room announced.
      expect(tester.getRect(_region('navigation')), before);
    });

    testWidgets('a separation reports the identity of the region whose '
        'room would change — on either side of what is left', (tester) async {
      final asked = <MentoraSplitResizeIntention>[];
      await _pump(tester, _split(onResizeRequested: asked.add));

      // Placed before what is left: moving away from the start makes
      // it bigger.
      await tester.drag(_grab('navigation'), const Offset(40, 0));
      await tester.pumpAndSettle();
      expect(asked.last.regionId, 'navigation');
      expect(asked.last.delta, greaterThan(0));

      // Placed after what is left: moving toward the start makes it
      // bigger.
      asked.clear();
      await tester.drag(_grab('inspector'), const Offset(-40, 0));
      await tester.pumpAndSettle();
      expect(asked.last.regionId, 'inspector');
      expect(asked.last.delta, greaterThan(0));
    });

    testWidgets('a separation can be moved without a pointer: each step '
        'asks for exactly one step of room', (tester) async {
      final handle = tester.ensureSemantics();
      final asked = <MentoraSplitResizeIntention>[];
      await _pump(tester, _split(onResizeRequested: asked.add));

      final separation = tester.getSemantics(_grab('navigation'));
      expect(separation.label, 'Redimensionner navigation');
      expect(separation.flagsCollection.isSlider, isTrue);

      final control = find.semantics.byLabel('Redimensionner navigation');
      tester.semantics.increase(control);
      await tester.pumpAndSettle();
      expect(asked.last.regionId, 'navigation');
      expect(asked.last.delta, splitViewResizeStep);

      tester.semantics.decrease(control);
      await tester.pumpAndSettle();
      expect(asked.last.delta, -splitViewResizeStep);
      handle.dispose();
    });

    testWidgets('what a person takes hold of honors the opposable '
        'reachable target', (tester) async {
      final services = await _pump(tester, _split(onResizeRequested: (_) {}));
      final accessibility = services.get<AccessibilityEngine>();

      expect(
        tester.getSize(_grab('navigation')).width,
        greaterThanOrEqualTo(accessibility.minimumTapTarget),
      );
      // The line itself never grows with it: what is painted stays a
      // line.
      expect(
        tester.getSize(_separator('navigation')).width,
        splitViewSeparatorThickness,
      );
    });

    testWidgets('every region is a landmark of its own, and its own '
        'focus group', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _split());

      for (final id in const ['navigation', 'workspace', 'inspector']) {
        expect(tester.getSemantics(_region(id)).label, 'Région $id');
      }
      expect(
        find.descendant(
          of: find.byType(MentoraSplitView),
          matching: find.byType(FocusTraversalGroup),
        ),
        findsNWidgets(3),
      );
      handle.dispose();
    });

    testWidgets('the focus stays where the person left it, and the '
        'workspace never takes it', (tester) async {
      final inside = FocusNode(debugLabel: 'workspace');
      addTearDown(inside.dispose);

      await _pump(
        tester,
        _split(
          regions: [
            _regionOf('navigation'),
            MentoraSplitRegion(
              id: 'workspace',
              semanticLabel: 'Région workspace',
              content: Focus(focusNode: inside, child: _content('workspace')),
            ),
            _regionOf('inspector'),
          ],
        ),
      );

      inside.requestFocus();
      await tester.pumpAndSettle();
      expect(inside.hasPrimaryFocus, isTrue);

      await tester.pumpAndSettle();
      expect(inside.hasPrimaryFocus, isTrue);
    });

    testWidgets('the reading direction places the regions, and the '
        'workspace mirrors nothing by hand', (tester) async {
      await _pump(tester, _split());
      final ltr = tester.getRect(_region('navigation'));

      await _pump(tester, _split(), direction: TextDirection.rtl);
      final rtl = tester.getRect(_region('navigation'));

      expect(rtl.width, ltr.width);
      expect(rtl.right, 1000);
      expect(ltr.left, 0);
    });

    testWidgets('what a person asks for follows the reading direction', (
      tester,
    ) async {
      final asked = <MentoraSplitResizeIntention>[];
      await _pump(
        tester,
        _split(onResizeRequested: asked.add),
        direction: TextDirection.rtl,
      );

      // The same movement of the hand, mirrored: it still makes the
      // same region bigger.
      await tester.drag(_grab('navigation'), const Offset(-40, 0));
      await tester.pumpAndSettle();
      expect(asked.last.regionId, 'navigation');
      expect(asked.last.delta, greaterThan(0));
    });

    testWidgets('a workspace without a contract refuses to build — fail '
        'closed', (tester) async {
      Future<void> refuses(MentoraSplitView workspace) async {
        await _pump(tester, workspace);
        expect(tester.takeException(), isStateError);
      }

      // Below two regions nothing is shared.
      await refuses(_split(regions: [_regionOf('workspace')]));
      // Two regions never share one identity.
      await refuses(
        _split(
          regions: [
            _regionOf('navigation'),
            _regionOf('navigation'),
            _regionOf('workspace'),
          ],
        ),
      );
      // A region without an identity, or without a name, is not one.
      await refuses(_split(regions: [_regionOf(''), _regionOf('workspace')]));
      await refuses(
        _split(
          regions: [
            _regionOf('navigation', semanticLabel: ''),
            _regionOf('workspace'),
          ],
        ),
      );
      // A room below the opposable floor is not a room.
      await refuses(
        _split(
          layout: const MentoraSplitLayoutSpecification(
            extents: {'navigation': splitViewMinimumRegionExtent - 1},
            fillsRemainingRegionId: 'workspace',
          ),
        ),
      );
      // What is left is not a room one announces.
      await refuses(
        _split(
          layout: const MentoraSplitLayoutSpecification(
            extents: {'workspace': 240},
            fillsRemainingRegionId: 'workspace',
          ),
        ),
      );
      // A room announced for a region that does not exist.
      await refuses(
        _split(
          layout: const MentoraSplitLayoutSpecification(
            extents: {'navigation': 240, 'elsewhere': 240},
            fillsRemainingRegionId: 'workspace',
          ),
        ),
      );
      // A region that exists and takes no announced room.
      await refuses(
        _split(
          layout: const MentoraSplitLayoutSpecification(
            extents: {'navigation': 240},
            fillsRemainingRegionId: 'workspace',
          ),
        ),
      );
      // The region that takes what is left is not shown.
      await refuses(
        _split(
          regions: [
            _regionOf('navigation'),
            _regionOf(
              'workspace',
              visibility: MentoraSplitRegionVisibility.hidden,
            ),
            _regionOf('inspector'),
          ],
        ),
      );
      // A separation one can move is a control: it is never unnamed.
      await refuses(
        _split(
          regions: [
            _regionOf('navigation', resizeSemanticLabel: null),
            _regionOf('workspace'),
            _regionOf('inspector'),
          ],
          onResizeRequested: (_) {},
        ),
      );
    });

    testWidgets('the workspace holds in the four themes and every '
        'reading comfort', (tester) async {
      for (final variant in ThemeVariantId.values) {
        final services = await _pump(tester, _split(), variant: variant);
        expect(tester.takeException(), isNull);
        expect(
          (tester.widget<AnimatedContainer>(_region('workspace')).decoration
                  as BoxDecoration?)
              ?.color,
          services.get<SurfaceTokenEngine>().surfaceOf(
            SurfaceRole.primarySurface,
            variant,
          ),
        );
      }

      for (final comfort in ReadingComfortPreference.values) {
        await _pump(
          tester,
          _split(),
          appearance: AppearanceState(readingComfort: comfort),
        );
        expect(tester.takeException(), isNull);
        expect(_region('workspace'), findsOneWidget);
      }
    });

    testWidgets('every transition comes from the Motion Engine: None '
        'silences it', (tester) async {
      const appearance = AppearanceState();
      final services = await _pump(tester, _split());
      expect(
        tester.widget<AnimatedContainer>(_separator('navigation')).duration,
        services.get<MotionEngine>().durationFor(
          MotionIntention.montrerLaContinuite,
          appearance,
        ),
      );

      await _pump(
        tester,
        _split(),
        appearance: const AppearanceState(motion: MotionPreference.none),
      );
      expect(
        tester.widget<AnimatedContainer>(_region('workspace')).duration,
        Duration.zero,
      );
    });

    testWidgets('outside the Design Kit the workspace refuses to build — '
        'fail closed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(width: 1000, height: 600, child: _split()),
          ),
        ),
      );
      expect(tester.takeException(), isStateError);
    });
  });

  group('Governance — the executable scans ship with the component', () {
    Iterable<File> dartFilesOf(String path) => Directory(path)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    Iterable<File> workspaceFiles() =>
        dartFilesOf('lib/foundation/design_kit/structure/split_view');

    test('no framework split view survives in the foundation: Flutter '
        'stays a primitive', () {
      final forbidden = <String, RegExp>{
        'SplitView': RegExp(r'(?<![A-Za-z])SplitView(?![A-Za-z])'),
        'TwoPaneView': RegExp(r'(?<![A-Za-z])TwoPaneView(?![A-Za-z])'),
        'MultiSplitView': RegExp(r'(?<![A-Za-z])MultiSplitView(?![A-Za-z])'),
        'ResizableWidget': RegExp(r'(?<![A-Za-z])Resizable\w*(?![A-Za-z])'),
        'a framework scaffold': RegExp(r'(?<![A-Za-z])Scaffold\('),
      };
      for (final file in dartFilesOf('lib/foundation')) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: a shared workspace is a MentoraSplitView '
                '— never a ${entry.key}',
          );
        }
      }
    });

    test('a workspace measures no screen, knows no platform and reads no '
        'breakpoint', () {
      // Structural, never lexical: these are identifiers of the code.
      final forbidden = <String, RegExp>{
        'a measure of the screen': RegExp(
          r'(?<![A-Za-z])(MediaQuery|LayoutBuilder|ResponsiveEngine|'
          r'FractionallySizedBox|AspectRatio|IntrinsicWidth|'
          r'IntrinsicHeight|OrientationBuilder)(?![A-Za-z])',
        ),
        'a platform': RegExp(
          r'(?<![A-Za-z])(Platform|TargetPlatform|defaultTargetPlatform|'
          r'kIsWeb|isAndroid|isIOS)(?![A-Za-z])',
        ),
        // Structural, never lexical: these are identifiers of the
        // code — the prose may name what the code may not carry.
        'a breakpoint': RegExp(
          r'(?<![A-Za-z])(Breakpoint\w*|ResponsiveContext|screenWidth|'
          r'screenHeight|aspectRatio|widthFactor|heightFactor)'
          r'(?![A-Za-z])',
        ),
        'a share of the room': RegExp(
          r'(?<![A-Za-z])(Expanded|Flexible|Spacer|flex)(?![A-Za-z])',
        ),
      };
      final files = workspaceFiles();
      expect(files, isNotEmpty);
      for (final file in files) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: a workspace never carries ${entry.key} — '
                'the room is announced, never computed',
          );
        }
      }
    });

    test('a workspace carries no position: identities travel, ranks do '
        'not exist', () {
      final positions = <String, RegExp>{
        'a position field': RegExp(r'final\s+int\s'),
        'a position parameter': RegExp(r'(?<![A-Za-z])int\s+\w*[Ii]ndex'),
        'a lookup by position': RegExp(r'\.(indexOf|elementAt)\('),
        'a selected position': RegExp(
          r'(?<![A-Za-z])(selectedIndex|currentIndex|activeIndex)'
          r'(?![A-Za-z])',
        ),
      };
      for (final file in workspaceFiles()) {
        final source = file.readAsStringSync();
        for (final entry in positions.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: ${entry.key} — a region is an identity, '
                'never a position',
          );
        }
      }
    });

    test('a workspace knows no business and no data', () {
      final forbidden = <String, RegExp>{
        'a business domain': RegExp(
          r'(?<![A-Za-z])(Wallet|Business|Marketplace|Orders?|'
          r'Consultation|Inventory|Messages?|Chat|Settings|Dashboard|'
          r'Invoice|Facture|Product|Profile)(?![a-z])',
        ),
        'an address': RegExp(
          r'(?<![A-Za-z])(Navigator|GoRouter|routeName|pushNamed|'
          r'MaterialPageRoute)(?![A-Za-z])',
        ),
        'a selection of data': RegExp(
          r'\.(where|firstWhere|lastWhere|singleWhere|sort|reduce|fold)\(',
        ),
      };
      for (final file in workspaceFiles()) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason: '${file.path}: a workspace never carries ${entry.key}',
          );
        }
      }
    });

    test('a workspace rebuilds nothing it does not own, reads no ambient '
        'theme and codes no value', () {
      final forbidden = <String, RegExp>{
        'its own words': RegExp(r'(?<![A-Za-z])Text\('),
        'its own style': RegExp(r'(?<![A-Za-z])TextStyle\('),
        'an ambient theme': RegExp(r'Theme\.of\('),
        'a coded colour': RegExp(r'(Color\(0x|Colors\.)'),
        'a coded padding': RegExp(r'EdgeInsets\.\w+\(\s*[0-9]'),
        'a coded radius': RegExp(r'BorderRadius\.\w+\(\s*[0-9]'),
        'a coded extent': RegExp(r'(width|height|extent):\s*[1-9]'),
        'a coded duration': RegExp(r'Duration\((milliseconds|seconds)'),
      };
      for (final file in workspaceFiles()) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason: '${file.path}: a workspace never carries ${entry.key}',
          );
        }
      }
    });

    test('one shared workspace exists in the product, and it lives in '
        'the Design Kit', () {
      final declarations = <String>[];
      for (final file in dartFilesOf('lib/foundation')) {
        if (RegExp(
          r'class\s+MentoraSplitView(?![A-Za-z])',
        ).hasMatch(file.readAsStringSync())) {
          declarations.add(file.path.replaceAll(r'\', '/'));
        }
      }
      expect(declarations, hasLength(1));
      expect(declarations.single, contains('design_kit/structure/split_view/'));
    });
  });
}
