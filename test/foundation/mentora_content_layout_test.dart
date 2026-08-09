import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/bootstrap/design_kit_bootstrap.dart';
import 'package:mentora/foundation/core/di/foundation_services.dart';
import 'package:mentora/foundation/design_kit/accessibility/accessibility_engine.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/components/button/mentora_button.dart';
import 'package:mentora/foundation/design_kit/components/button/mentora_button_style.dart';
import 'package:mentora/foundation/design_kit/components/design_kit_scope.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text_role.dart';
import 'package:mentora/foundation/design_kit/layout/content_layout/mentora_content_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_context.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_kind.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_style.dart';
import 'package:mentora/foundation/design_kit/motion/motion_engine.dart';
import 'package:mentora/foundation/design_kit/registry/token_engines.dart';
import 'package:mentora/foundation/design_kit/structure/app_bar/mentora_app_bar.dart';
import 'package:mentora/foundation/design_kit/structure/page_scaffold/mentora_page_scaffold.dart';
import 'package:mentora/foundation/design_kit/structure/workspace/mentora_workspace.dart';
import 'package:mentora/foundation/design_kit/structure/workspace/mentora_workspace_style.dart';
import 'package:mentora/foundation/design_kit/theme/theme_engine.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';
import 'package:mentora/foundation/design_kit/tokens/layout_tokens.dart';
import 'package:mentora/foundation/design_kit/tokens/surface_elevation_tokens.dart';

/// The content the application owns — recognisable, and never touched
/// by the layout that disposes it.
Widget _content(String id) => MentoraText(
  'Contenu $id',
  key: Key('content-$id'),
  role: MentoraTextRole.body,
);

MentoraContentRegion _region(
  String id, {
  String? semanticLabel,
  Widget? content,
}) => MentoraContentRegion(
  id: id,
  semanticLabel: semanticLabel ?? 'Région $id',
  content: content ?? _content(id),
);

const MentoraLayoutContext _frame = MentoraLayoutContext(
  semanticLabel: 'Contexte de travail',
  navigation: MentoraNavigationAnnouncement(destinationId: 'home'),
);

MentoraContentLayout _layout({
  List<MentoraContentRegion>? regions,
  MentoraLayoutContext frame = _frame,
  String pageSemanticLabel = 'Page courante',
  MentoraAppBar? place,
  List<MentoraButton> acts = const [],
}) {
  return MentoraContentLayout(
    frame: frame,
    pageSemanticLabel: pageSemanticLabel,
    place: place,
    acts: acts,
    regions: regions ?? [_region('resume'), _region('details')],
  );
}

Future<FoundationServices> _services() async {
  final services = FoundationServices();
  await const DesignKitBootstrapStep().run(services);
  return services;
}

Future<FoundationServices> _pump(
  WidgetTester tester,
  Widget layout, {
  ThemeVariantId variant = ThemeVariantId.light,
  AppearanceState appearance = const AppearanceState(),
  TextDirection direction = TextDirection.ltr,
}) async {
  final services = await _services();
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
        child: Directionality(textDirection: direction, child: layout),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return services;
}

Finder _regionOf(String id) => find.byKey(Key('content-region-$id'));

void main() {
  group('MentoraContentLayout — the official disposition of content', () {
    testWidgets('it is a specialization of the one foundation, and the '
        'registry knows its shape', (tester) async {
      expect(_layout(), isA<MentoraLayout>());
      expect(_layout().kind, MentoraLayoutKind.content);

      await _pump(tester, _layout());
      expect(find.byKey(const Key('layout-content')), findsOneWidget);
      expect(find.byType(MentoraWorkspace), findsOneWidget);
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
    });

    testWidgets('the content is handed on strictly intact: a single '
        'region starts exactly where the page starts', (tester) async {
      await _pump(tester, _layout(regions: [_region('resume')]));

      expect(
        tester.getTopLeft(find.byKey(const Key('content-resume'))),
        tester.getTopLeft(find.byType(MentoraPageScaffold)),
        reason: 'a content layout adds nothing around what it disposes',
      );
      expect(
        tester.getTopLeft(_regionOf('resume')),
        tester.getTopLeft(find.byType(MentoraPageScaffold)),
      );
    });

    testWidgets('it adds no room between the regions it was handed: one '
        'region begins exactly where the previous one ends', (tester) async {
      await _pump(tester, _layout());

      final first = tester.getRect(_regionOf('resume'));
      final second = tester.getRect(_regionOf('details'));
      expect(second.top, first.bottom);
      // The absence is a declared value, never an accident of code.
      expect(layoutContentGap, 0);
    });

    testWidgets('the regions are read in the order they were announced', (
      tester,
    ) async {
      await _pump(
        tester,
        _layout(
          regions: [_region('premier'), _region('second'), _region('tiers')],
        ),
      );

      final tops = [
        for (final id in const ['premier', 'second', 'tiers'])
          tester.getRect(_regionOf(id)).top,
      ];
      expect(tops[1], greaterThan(tops[0]));
      expect(tops[2], greaterThan(tops[1]));
    });

    testWidgets('a region is an identity: the same content announced '
        'under another identity is another region', (tester) async {
      await _pump(tester, _layout());

      expect(_regionOf('resume'), findsOneWidget);
      expect(_regionOf('details'), findsOneWidget);
      expect(_regionOf('elsewhere'), findsNothing);
    });

    testWidgets('it creates no scroll view of its own', (tester) async {
      await _pump(tester, _layout());

      expect(find.byType(Scrollable), findsNothing);
      expect(find.byType(SingleChildScrollView), findsNothing);
    });

    testWidgets('it creates no padding of its own', (tester) async {
      await _pump(tester, _layout(regions: [_region('resume')]));

      // Geometric proof: the region occupies the full width the page
      // gives it, and begins at its very edge.
      final page = tester.getRect(find.byType(MentoraPageScaffold));
      final region = tester.getRect(_regionOf('resume'));
      expect(region.left, page.left);
      expect(region.width, page.width);
      expect(region.top, page.top);
    });

    testWidgets('every region is a landmark of its own', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _layout());

      expect(tester.getSemantics(_regionOf('resume')).label, 'Région resume');
      expect(tester.getSemantics(_regionOf('details')).label, 'Région details');
      handle.dispose();
    });

    testWidgets('a region never announces the same thing twice', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _layout(regions: [_region('resume')]));

      // The region names itself; what it carries keeps its own voice,
      // and neither repeats the other.
      expect(find.bySemanticsLabel('Région resume'), findsOneWidget);
      expect(find.bySemanticsLabel('Contenu resume'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('every region travels as its own focus group', (tester) async {
      await _pump(tester, _layout());

      for (final id in const ['resume', 'details']) {
        expect(
          find.descendant(
            of: _regionOf(id),
            matching: find.byType(FocusTraversalGroup),
          ),
          findsOneWidget,
          reason: id,
        );
      }
    });

    testWidgets('the focus stays where the person left it: the layout '
        'never takes it', (tester) async {
      final inside = FocusNode(debugLabel: 'region');
      addTearDown(inside.dispose);

      await _pump(
        tester,
        _layout(
          regions: [
            _region(
              'resume',
              content: Focus(focusNode: inside, child: _content('resume')),
            ),
          ],
        ),
      );

      inside.requestFocus();
      await tester.pumpAndSettle();
      expect(inside.hasPrimaryFocus, isTrue);

      await tester.pumpAndSettle();
      expect(inside.hasPrimaryFocus, isTrue);
    });

    testWidgets('the zones of the page it asks for stay the zones of '
        'the components that own them', (tester) async {
      await _pump(
        tester,
        _layout(
          place: const MentoraAppBar(title: 'Page courante'),
          acts: [
            MentoraButton(
              label: 'Confirmer',
              onPressed: () {},
              size: MentoraButtonSize.small,
            ),
          ],
        ),
      );

      expect(find.byType(MentoraAppBar), findsOneWidget);
      expect(find.byType(MentoraButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a content layout without a contract refuses to build — '
        'fail closed', (tester) async {
      Future<void> refuses(Widget layout) async {
        await _pump(tester, layout);
        expect(tester.takeException(), isStateError);
      }

      // Content absent.
      await refuses(_layout(regions: const []));
      // A region without an identity.
      await refuses(_layout(regions: [_region('')]));
      // A region without a name.
      await refuses(_layout(regions: [_region('resume', semanticLabel: '')]));
      // Two regions sharing one identity — an ambiguous disposition.
      await refuses(_layout(regions: [_region('resume'), _region('resume')]));
      // A page that announces nothing.
      await refuses(_layout(pageSemanticLabel: ''));
      // A working context that announces nothing.
      await refuses(
        _layout(
          frame: const MentoraLayoutContext(
            semanticLabel: '',
            navigation: MentoraNavigationAnnouncement(destinationId: 'home'),
          ),
        ),
      );
    });

    testWidgets('it holds in the four themes', (tester) async {
      for (final variant in ThemeVariantId.values) {
        await _pump(tester, _layout(), variant: variant);
        expect(tester.takeException(), isNull, reason: variant.name);
        expect(_regionOf('resume'), findsOneWidget);
      }
    });

    testWidgets('it holds at every font scale', (tester) async {
      for (final scale in FontScalePreference.values) {
        await _pump(
          tester,
          _layout(),
          appearance: AppearanceState(fontScale: scale),
        );
        expect(tester.takeException(), isNull, reason: scale.name);
        expect(_regionOf('details'), findsOneWidget);
      }
    });

    testWidgets('it holds at every reading comfort', (tester) async {
      for (final comfort in ReadingComfortPreference.values) {
        await _pump(
          tester,
          _layout(),
          appearance: AppearanceState(readingComfort: comfort),
        );
        expect(tester.takeException(), isNull, reason: comfort.name);
      }
    });

    testWidgets('it holds in both reading directions, and the regions '
        'still take the whole width', (tester) async {
      for (final direction in TextDirection.values) {
        await _pump(tester, _layout(), direction: direction);
        expect(tester.takeException(), isNull, reason: direction.name);
        expect(
          tester.getRect(_regionOf('resume')).width,
          tester.getRect(find.byType(MentoraPageScaffold)).width,
          reason: direction.name,
        );
      }
    });

    testWidgets('every transition still comes from the Motion Engine: '
        'None silences it', (tester) async {
      await _pump(
        tester,
        _layout(),
        appearance: const AppearanceState(motion: MotionPreference.none),
      );

      expect(
        tester
            .widget<AnimatedContainer>(
              find.byKey(const Key('workspace-surface')),
            )
            .duration,
        Duration.zero,
      );
    });

    testWidgets('outside the Design Kit it refuses to build — fail '
        'closed', (tester) async {
      await tester.pumpWidget(MaterialApp(home: _layout()));
      expect(tester.takeException(), isStateError);
    });
  });

  group('Governance — the executable scans ship with the layout', () {
    Iterable<File> dartFilesOf(String path) => Directory(path)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    Iterable<File> contentFiles() =>
        dartFilesOf('lib/foundation/design_kit/layout/content_layout');

    test('it builds no framework layout, and no room of its own', () {
      final forbidden = <String, RegExp>{
        'a framework scaffold': RegExp(r'(?<![A-Za-z])Scaffold\('),
        'a safe area': RegExp(r'(?<![A-Za-z])SafeArea\('),
        'a padding': RegExp(r'(?<![A-Za-z])Padding\('),
        'a flexible space': RegExp(
          r'(?<![A-Za-z])(Expanded|Flexible|Spacer)(?![A-Za-z])',
        ),
        'a scroll view': RegExp(
          r'(?<![A-Za-z])(ListView|SingleChildScrollView|CustomScrollView|'
          r'GridView|ScrollController|NestedScrollView)(?![A-Za-z])',
        ),
        'a decorative box': RegExp(
          r'(?<![A-Za-z])(Container|DecoratedBox|ColoredBox)\(',
        ),
        'its own words': RegExp(r'(?<![A-Za-z])Text\('),
        'its own style': RegExp(r'(?<![A-Za-z])TextStyle\('),
      };
      final files = contentFiles();
      expect(files, isNotEmpty);
      for (final file in files) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: a content layout disposes content — it '
                'never builds ${entry.key}',
          );
        }
      }
    });

    test('it measures no screen, knows no platform, no address, no '
        'business and no data', () {
      final forbidden = <String, RegExp>{
        'a measure of the screen': RegExp(
          r'(?<![A-Za-z])(MediaQuery|LayoutBuilder|ResponsiveEngine|'
          r'Breakpoint\w*|OrientationBuilder)(?![A-Za-z])',
        ),
        'a platform': RegExp(
          r'(?<![A-Za-z])(Platform|TargetPlatform|defaultTargetPlatform|'
          r'kIsWeb|isAndroid|isIOS)(?![A-Za-z])',
        ),
        'an address': RegExp(
          r'(?<![A-Za-z])(Navigator|GoRouter|routeName|pushNamed|'
          r'MaterialPageRoute)(?![A-Za-z])',
        ),
        'a business domain': RegExp(
          r'(?<![A-Za-z])(Wallet|Orders?|Marketplace|Business|Inventory|'
          r'Payments?|Messages?|Consultation|Profile|Analytics|Settings|'
          r'Reports?|Invoice|Facture|Product|Chat|Dashboard)(?![a-z])',
        ),
        'a model or a collection': RegExp(
          r'(?<![A-Za-z])(fromJson|toJson|Model|Repository|Entity|'
          r'HttpClient|Firestore)(?![A-Za-z])',
        ),
        'a selection of data': RegExp(
          r'\.(where|firstWhere|lastWhere|singleWhere|sort|reduce|fold)\(',
        ),
        'an untyped value': RegExp(
          r'(?<![A-Za-z])(dynamic|Object\?)(?![A-Za-z])',
        ),
        'an untyped zone': RegExp(r'final\s+Widget\?\s'),
      };
      for (final file in contentFiles()) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason: '${file.path}: it never carries ${entry.key}',
          );
        }
      }
    });

    test('it reads no ambient theme and codes no value', () {
      final forbidden = <String, RegExp>{
        'an ambient theme': RegExp(r'Theme\.of\('),
        'a coded colour': RegExp(r'(Color\(0x|Colors\.)'),
        'a coded padding': RegExp(r'EdgeInsets\.\w+\(\s*[0-9]'),
        'a coded radius': RegExp(r'BorderRadius\.\w+\(\s*[0-9]'),
        'a coded extent': RegExp(r'(width|height|spacing|runSpacing):\s*[0-9]'),
        'a coded duration': RegExp(r'Duration\((milliseconds|seconds)'),
      };
      for (final file in contentFiles()) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason: '${file.path}: it never carries ${entry.key}',
          );
        }
      }
    });

    test('one content layout exists in the whole product, it extends the '
        'foundation, and it never builds', () {
      final declarations = <String>[];
      for (final file in dartFilesOf('lib')) {
        if (RegExp(
          r'class\s+MentoraContentLayout(?![A-Za-z])',
        ).hasMatch(file.readAsStringSync())) {
          declarations.add(file.path.replaceAll(r'\', '/'));
        }
      }
      expect(declarations, hasLength(1));
      expect(declarations.single, contains('layout/content_layout/'));

      final source = File(declarations.single).readAsStringSync();
      // It extends the REGIONED foundation: it therefore owns no
      // region, no order, no refusal and no surface — it owns its
      // official kind, and nothing else at all.
      expect(
        RegExp(r'extends\s+MentoraRegionedLayout(?![A-Za-z])').hasMatch(source),
        isTrue,
      );
      expect(RegExp(r'Widget\s+build\(').hasMatch(source), isFalse);
      expect(RegExp(r'void\s+verify\(').hasMatch(source), isFalse);
      expect(RegExp(r'surfaceOf\(').hasMatch(source), isFalse);
      expect(RegExp(r'final\s+[\w<>?, ]+\s+\w+\s*;').hasMatch(source), isFalse);
      // It never assembles: no working context, no page, no layer.
      for (final built in const [
        'MentoraWorkspace(',
        'MentoraPageScaffold(',
        'MentoraDialogHost(',
        'MentoraSnackbarHost(',
      ]) {
        expect(source.contains(built), isFalse, reason: built);
      }
    });
  });
}
