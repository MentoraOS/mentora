import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/bootstrap/design_kit_bootstrap.dart';
import 'package:mentora/foundation/core/di/foundation_services.dart';
import 'package:mentora/foundation/design_kit/accessibility/accessibility_engine.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/components/button/mentora_button.dart';
import 'package:mentora/foundation/design_kit/components/button/mentora_button_style.dart';
import 'package:mentora/foundation/design_kit/components/card/mentora_card.dart';
import 'package:mentora/foundation/design_kit/components/card/mentora_card_style.dart';
import 'package:mentora/foundation/design_kit/components/design_kit_scope.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text_role.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_context.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_kind.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_style.dart';
import 'package:mentora/foundation/design_kit/layout/grid_layout/mentora_grid_layout.dart';
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

const String _grid = 'Les indicateurs du mois';
const double _extent = 160;

/// The cells the application owns — recognisable, already built, and
/// never touched by the layout that places them.
Widget _cellContent(String id) => MentoraText(
  'Cellule $id',
  key: Key('cell-$id'),
  role: MentoraTextRole.body,
);

MentoraGridCell _cell(String id, {double extent = _extent, Widget? content}) =>
    MentoraGridCell(
      id: id,
      extent: extent,
      content: content ?? _cellContent(id),
    );

const MentoraLayoutContext _frame = MentoraLayoutContext(
  semanticLabel: 'Contexte de travail',
  navigation: MentoraNavigationAnnouncement(destinationId: 'home'),
);

MentoraGridDisposition _disposition({List<MentoraGridRow>? rows}) =>
    MentoraGridDisposition(
      rows:
          rows ??
          [
            MentoraGridRow(id: 'haut', cells: [_cell('nord'), _cell('est')]),
            MentoraGridRow(id: 'bas', cells: [_cell('sud')]),
          ],
    );

MentoraGridLayout _layout({
  MentoraGridDisposition? disposition,
  MentoraLayoutContext frame = _frame,
  String pageSemanticLabel = 'Page courante',
  String gridId = 'indicateurs',
  String gridSemanticLabel = _grid,
  MentoraAppBar? place,
  List<MentoraButton> acts = const [],
}) {
  return MentoraGridLayout(
    frame: frame,
    pageSemanticLabel: pageSemanticLabel,
    gridId: gridId,
    gridSemanticLabel: gridSemanticLabel,
    place: place,
    acts: acts,
    disposition: disposition ?? _disposition(),
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

Finder _gridOf(String id) => find.byKey(Key('grid-$id'));
Finder _rowsOf(String id) => find.byKey(Key('grid-rows-$id'));
Finder _rowOf(String id) => find.byKey(Key('grid-row-$id'));
Finder _cellOf(String id) => find.byKey(Key('grid-cell-$id'));

void main() {
  group('MentoraGridLayout — a spatial collection already decided', () {
    testWidgets('it is a specialization of the one foundation, and the '
        'registry knows its shape', (tester) async {
      expect(_layout(), isA<MentoraLayout>());
      expect(_layout().kind, MentoraLayoutKind.grid);

      await _pump(tester, _layout());
      expect(find.byKey(const Key('layout-grid')), findsOneWidget);
      expect(find.byType(MentoraWorkspace), findsOneWidget);
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
    });

    testWidgets('it describes the grid and builds nothing: the assembly '
        'places it', (tester) async {
      await _pump(tester, _layout());

      expect(_gridOf('indicateurs'), findsOneWidget);
      expect(_rowsOf('indicateurs'), findsOneWidget);
      expect(_rowOf('haut'), findsOneWidget);
      expect(_rowOf('bas'), findsOneWidget);
      for (final id in const ['nord', 'est', 'sud']) {
        expect(_cellOf(id), findsOneWidget, reason: id);
      }
    });

    testWidgets('every cell takes exactly the room that was announced '
        'for it — never a room deduced', (tester) async {
      await _pump(
        tester,
        _layout(
          disposition: _disposition(
            rows: [
              MentoraGridRow(
                id: 'haut',
                cells: [_cell('nord', extent: 120), _cell('est', extent: 240)],
              ),
            ],
          ),
        ),
      );

      expect(tester.getRect(_cellOf('nord')).width, 120);
      expect(tester.getRect(_cellOf('est')).width, 240);
    });

    testWidgets('the same disposition gives the same places, whatever '
        'the room around it', (tester) async {
      await _pump(tester, _layout());
      final narrow = tester.getRect(_cellOf('nord')).width;

      tester.view.physicalSize = const Size(1600, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await _pump(tester, _layout());

      // Nothing was measured, so nothing changed: the grid expresses a
      // decision it was handed.
      expect(tester.getRect(_cellOf('nord')).width, narrow);
      expect(tester.getRect(_cellOf('est')).width, _extent);
    });

    testWidgets('the cells are handed on strictly intact: what a cell '
        'is starts exactly where the cell starts', (tester) async {
      await _pump(tester, _layout());

      for (final id in const ['nord', 'est', 'sud']) {
        expect(
          tester.getTopLeft(find.byKey(Key('cell-$id'))),
          tester.getTopLeft(_cellOf(id)),
          reason: 'the layout wraps $id in nothing',
        );
      }
    });

    testWidgets('the disposition announced is the disposition read', (
      tester,
    ) async {
      await _pump(tester, _layout());

      final nord = tester.getRect(_cellOf('nord'));
      final est = tester.getRect(_cellOf('est'));
      final sud = tester.getRect(_cellOf('sud'));
      // Two cells stand side by side in the row that holds them…
      expect(est.left, nord.right);
      expect(est.top, nord.top);
      // …and the next row stands under the previous one.
      expect(sud.top, greaterThanOrEqualTo(nord.bottom));
      expect(sud.left, nord.left);
    });

    testWidgets('it adds no room between the cells, and none between '
        'the rows', (tester) async {
      await _pump(tester, _layout());

      expect(
        tester.getRect(_cellOf('est')).left,
        tester.getRect(_cellOf('nord')).right,
      );
      expect(
        tester.getRect(_rowOf('bas')).top,
        tester.getRect(_rowOf('haut')).bottom,
      );
      // The absence is a declared value, never an accident of code.
      expect(layoutContentGap, 0);
    });

    testWidgets('a row never stretches what it places: a cell keeps the '
        'height it has', (tester) async {
      await _pump(
        tester,
        _layout(
          disposition: _disposition(
            rows: [
              MentoraGridRow(
                id: 'haut',
                cells: [
                  _cell('nord'),
                  _cell(
                    'est',
                    content: MentoraCard(
                      key: const Key('cell-est'),
                      variant: MentoraCardVariant.outlined,
                      child: MentoraText(
                        'Une cellule plus haute que sa voisine',
                        role: MentoraTextRole.body,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      final nord = tester.getRect(_cellOf('nord'));
      final est = tester.getRect(_cellOf('est'));
      expect(est.height, greaterThan(nord.height));
      // Neither was made to match the other, and both start at the top.
      expect(nord.top, est.top);
    });

    testWidgets('it creates no scroll view and no grid of the framework', (
      tester,
    ) async {
      await _pump(tester, _layout());

      expect(find.byType(Scrollable), findsNothing);
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.byType(GridView), findsNothing);
      expect(find.byType(Wrap), findsNothing);
      expect(find.byType(Flow), findsNothing);
      expect(find.byType(Table), findsNothing);
    });

    testWidgets('it creates no padding of its own: the grid starts at '
        'the very edge of the page', (tester) async {
      await _pump(tester, _layout());

      final page = tester.getRect(find.byType(MentoraPageScaffold));
      final grid = tester.getRect(_gridOf('indicateurs'));
      expect(grid.left, page.left);
      expect(grid.width, page.width);
      expect(grid.top, page.top);
      expect(tester.getRect(_cellOf('nord')).left, page.left);
    });

    testWidgets('only the grid is announced: the layout never speaks in '
        'a cell place', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _layout());

      expect(find.bySemanticsLabel(_grid), findsOneWidget);
      expect(tester.getSemantics(_gridOf('indicateurs')).label, _grid);
      for (final id in const ['nord', 'est', 'sud']) {
        expect(find.bySemanticsLabel('Cellule $id'), findsOneWidget);
      }
      handle.dispose();
    });

    testWidgets('a cell keeps its own semantics, whole', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        _layout(
          disposition: _disposition(
            rows: [
              MentoraGridRow(
                id: 'haut',
                cells: [
                  _cell(
                    'nord',
                    content: MentoraCard(
                      key: const Key('cell-nord'),
                      variant: MentoraCardVariant.outlined,
                      semanticLabel: 'Indicateur du nord',
                      child: MentoraText('Nord', role: MentoraTextRole.body),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      expect(find.bySemanticsLabel('Indicateur du nord'), findsOneWidget);
      expect(find.byType(MentoraCard), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a grid is one landmark and one focus group', (tester) async {
      await _pump(tester, _layout());

      expect(
        find.descendant(
          of: _gridOf('indicateurs'),
          matching: find.byType(FocusTraversalGroup),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the focus stays where the person left it: the layout '
        'never takes it', (tester) async {
      final inside = FocusNode(debugLabel: 'cell');
      addTearDown(inside.dispose);

      await _pump(
        tester,
        _layout(
          disposition: _disposition(
            rows: [
              MentoraGridRow(
                id: 'haut',
                cells: [
                  _cell(
                    'nord',
                    content: Focus(
                      focusNode: inside,
                      child: _cellContent('nord'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      inside.requestFocus();
      await tester.pumpAndSettle();
      expect(inside.hasPrimaryFocus, isTrue);

      await tester.pumpAndSettle();
      expect(inside.hasPrimaryFocus, isTrue);
    });

    testWidgets('a cell is an identity: it is found by what it is, '
        'never by where it stands', (tester) async {
      await _pump(tester, _layout());

      expect(_cellOf('nord'), findsOneWidget);
      expect(_cellOf('ailleurs'), findsNothing);
      expect(_rowOf('haut'), findsOneWidget);
      expect(_rowOf('milieu'), findsNothing);
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

    testWidgets('a grid layout without a contract refuses to build — '
        'fail closed', (tester) async {
      Future<void> refuses(Widget layout) async {
        await _pump(tester, layout);
        expect(tester.takeException(), isStateError);
      }

      // A grid without an identity, and a grid without a name.
      await refuses(_layout(gridId: ''));
      await refuses(_layout(gridSemanticLabel: ''));
      // A disposition that places nothing.
      await refuses(
        _layout(disposition: const MentoraGridDisposition(rows: [])),
      );
      // A row without an identity, and a row that stands for nothing.
      await refuses(
        _layout(
          disposition: _disposition(
            rows: [
              MentoraGridRow(id: '', cells: [_cell('nord')]),
            ],
          ),
        ),
      );
      await refuses(
        _layout(
          disposition: _disposition(
            rows: const [MentoraGridRow(id: 'haut', cells: [])],
          ),
        ),
      );
      // Two rows sharing one identity.
      await refuses(
        _layout(
          disposition: _disposition(
            rows: [
              MentoraGridRow(id: 'haut', cells: [_cell('nord')]),
              MentoraGridRow(id: 'haut', cells: [_cell('est')]),
            ],
          ),
        ),
      );
      // A cell without an identity.
      await refuses(
        _layout(
          disposition: _disposition(
            rows: [
              MentoraGridRow(id: 'haut', cells: [_cell('')]),
            ],
          ),
        ),
      );
      // Two cells sharing one identity, in two different rows.
      await refuses(
        _layout(
          disposition: _disposition(
            rows: [
              MentoraGridRow(id: 'haut', cells: [_cell('nord')]),
              MentoraGridRow(id: 'bas', cells: [_cell('nord')]),
            ],
          ),
        ),
      );
      // A room below the opposable floor, and a room that is no room.
      await refuses(
        _layout(
          disposition: _disposition(
            rows: [
              MentoraGridRow(
                id: 'haut',
                cells: [_cell('nord', extent: layoutMinimumCellExtent - 1)],
              ),
            ],
          ),
        ),
      );
      await refuses(
        _layout(
          disposition: _disposition(
            rows: [
              MentoraGridRow(
                id: 'haut',
                cells: [_cell('nord', extent: double.infinity)],
              ),
            ],
          ),
        ),
      );
      // A page that announces nothing, and a context that does not
      // announce itself.
      await refuses(_layout(pageSemanticLabel: ''));
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
        expect(_gridOf('indicateurs'), findsOneWidget);
      }
    });

    testWidgets('it holds at every font scale, and the announced room '
        'never changes', (tester) async {
      for (final scale in FontScalePreference.values) {
        await _pump(
          tester,
          _layout(),
          appearance: AppearanceState(fontScale: scale),
        );
        expect(tester.takeException(), isNull, reason: scale.name);
        expect(tester.getRect(_cellOf('nord')).width, _extent);
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

    testWidgets('the reading direction places the cells, and the layout '
        'mirrors nothing by hand', (tester) async {
      await _pump(tester, _layout());
      final ltr = tester.getRect(_cellOf('nord'));

      await _pump(tester, _layout(), direction: TextDirection.rtl);
      final rtl = tester.getRect(_cellOf('nord'));

      expect(rtl.width, ltr.width);
      expect(rtl.left, greaterThan(ltr.left));
      // The cell announced after it still stands beside it.
      expect(tester.getRect(_cellOf('est')).right, rtl.left);
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

    Iterable<File> gridFiles() =>
        dartFilesOf('lib/foundation/design_kit/layout/grid_layout');

    test('a grid builds no framework grid, no scroll view and no room '
        'of its own', () {
      // Structural, never lexical: a type USED carries a constructor,
      // a member or a type argument behind it — the prose may name
      // what the code may not carry.
      final forbidden = <String, RegExp>{
        'a framework grid': RegExp(
          r'(?<![A-Za-z])(GridView|SliverGrid|GridTile|GridPaper|Wrap|Flow|'
          r'Table|CustomMultiChildLayout|IntrinsicGrid)\s*[(.<]',
        ),
        'a scroll view': RegExp(
          r'(?<![A-Za-z])(Scrollable|ScrollView|SingleChildScrollView|'
          r'ListView|CustomScrollView|ScrollController)\s*[(.<]',
        ),
        'a padding': RegExp(r'(?<![A-Za-z])Padding\('),
        'a safe area': RegExp(r'(?<![A-Za-z])SafeArea\('),
        'a decorative box': RegExp(
          r'(?<![A-Za-z])(Container|DecoratedBox|ColoredBox)\(',
        ),
        'a flexible space': RegExp(
          r'(?<![A-Za-z])(Expanded|Flexible|Spacer)\s*[(.<]',
        ),
        'its own words': RegExp(r'(?<![A-Za-z])Text\('),
        'its own style': RegExp(r'(?<![A-Za-z])TextStyle\('),
      };
      final files = gridFiles();
      expect(files, isNotEmpty);
      for (final file in files) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: a grid expresses a decision it was '
                'handed — it never builds ${entry.key}',
          );
        }
      }
    });

    test('a grid counts no column, no row, and deduces no place', () {
      final forbidden = <String, RegExp>{
        'a count of columns or rows': RegExp(
          r'(?<![A-Za-z])(crossAxisCount|mainAxisCount|maxCrossAxisExtent|'
          r'childAspectRatio|columnCount|rowCount|columns|rows\s*=)'
          r'(?![A-Za-z])',
        ),
        'an arithmetic of places': RegExp(
          r'(~/|\s%\s|\.ceil\(|\.floor\(|\.round\()',
        ),
        'a measure of the screen': RegExp(
          r'(?<![A-Za-z])(MediaQuery|LayoutBuilder|ResponsiveEngine|'
          r'Breakpoint\w*|OrientationBuilder)\s*[(.<]',
        ),
        'a platform': RegExp(
          r'(?<![A-Za-z])(Platform|TargetPlatform|defaultTargetPlatform|'
          r'kIsWeb|isAndroid|isIOS)(?![A-Za-z])',
        ),
        'an order of its own': RegExp(
          r'\.(sort|reversed|where|firstWhere|lastWhere|singleWhere|'
          r'reduce|fold|skip|take)\b',
        ),
      };
      for (final file in gridFiles()) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: the disposition is announced — it never '
                'carries ${entry.key}',
          );
        }
      }
    });

    test('a grid knows no address, no business and no data', () {
      final forbidden = <String, RegExp>{
        'an address': RegExp(
          r'(?<![A-Za-z])(Navigator|GoRouter|routeName|pushNamed|'
          r'MaterialPageRoute)(?![A-Za-z])',
        ),
        'a route type': RegExp(r'(?<![A-Za-z])Route<'),
        'a business domain': RegExp(
          r'(?<![A-Za-z])(Wallet|Orders?|Marketplace|Business|Inventory|'
          r'Payments?|Messages?|Consultation|Profile|Analytics|Settings|'
          r'Reports?|Invoice|Facture|Product|Chat|Dashboard|Gallery|'
          r'Media)(?![a-z])',
        ),
        'a model or a collection of data': RegExp(
          r'(?<![A-Za-z])(fromJson|toJson|Model|Repository|Entity|'
          r'HttpClient|Firestore)(?![A-Za-z])',
        ),
        'an untyped value': RegExp(
          r'(?<![A-Za-z])(dynamic|Object\?)(?![A-Za-z])',
        ),
        'an untyped zone': RegExp(r'final\s+Widget\?\s'),
      };
      for (final file in gridFiles()) {
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

    test('a grid reads no ambient theme and codes no value', () {
      final forbidden = <String, RegExp>{
        'an ambient theme': RegExp(r'Theme\.of\('),
        'a coded colour': RegExp(r'(Color\(0x|Colors\.)'),
        'a coded padding': RegExp(r'EdgeInsets\.\w+\(\s*[0-9]'),
        'a coded radius': RegExp(r'BorderRadius\.\w+\(\s*[0-9]'),
        'a coded extent': RegExp(
          r'(width|height|extent|spacing|runSpacing):\s*[0-9]',
        ),
        'a coded duration': RegExp(r'Duration\((milliseconds|seconds)'),
        'a coded voice': RegExp(r'(fontSize:|FontWeight\.)'),
      };
      for (final file in gridFiles()) {
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

    test('one grid layout exists in the whole product, it extends the '
        'foundation, and it builds nothing at all', () {
      final declarations = <String>[];
      for (final file in dartFilesOf('lib')) {
        if (RegExp(
          r'class\s+MentoraGridLayout(?![A-Za-z])',
        ).hasMatch(file.readAsStringSync())) {
          declarations.add(file.path.replaceAll(r'\', '/'));
        }
      }
      expect(declarations, hasLength(1));
      expect(declarations.single, contains('layout/grid_layout/'));

      final source = File(declarations.single).readAsStringSync();
      expect(
        RegExp(r'extends\s+MentoraPageLikeLayout(?![A-Za-z])').hasMatch(source),
        isTrue,
      );
      expect(RegExp(r'Widget\s+build\(').hasMatch(source), isFalse);
      for (final built in const [
        'MentoraWorkspace(',
        'MentoraPageScaffold(',
        'MentoraDialogHost(',
        'MentoraSnackbarHost(',
        'Column(',
        'Row(',
        'SizedBox(',
        'Semantics(',
        'FocusTraversalGroup(',
      ]) {
        expect(source.contains(built), isFalse, reason: built);
      }
    });
  });
}
