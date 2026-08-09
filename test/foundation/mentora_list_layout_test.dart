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
import 'package:mentora/foundation/design_kit/composition/list_tile/mentora_list_tile.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_context.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_kind.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_style.dart';
import 'package:mentora/foundation/design_kit/layout/list_layout/mentora_list_layout.dart';
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

const String _list = 'Les transactions du mois';

/// The elements the application owns — recognisable, already built,
/// and never touched by the layout that presents them.
Widget _element(String id) => MentoraText(
  'Élément $id',
  key: Key('element-$id'),
  role: MentoraTextRole.body,
);

MentoraIdentifiedContent _item(String id, {Widget? content}) =>
    MentoraIdentifiedContent(id: id, content: content ?? _element(id));

const MentoraLayoutContext _frame = MentoraLayoutContext(
  semanticLabel: 'Contexte de travail',
  navigation: MentoraNavigationAnnouncement(destinationId: 'home'),
);

MentoraListLayout _layout({
  List<MentoraIdentifiedContent>? items,
  MentoraLayoutContext frame = _frame,
  String pageSemanticLabel = 'Page courante',
  String listId = 'transactions',
  String listSemanticLabel = _list,
  MentoraAppBar? place,
  List<MentoraButton> acts = const [],
}) {
  return MentoraListLayout(
    frame: frame,
    pageSemanticLabel: pageSemanticLabel,
    listId: listId,
    listSemanticLabel: listSemanticLabel,
    place: place,
    acts: acts,
    items: items ?? [_item('premier'), _item('second'), _item('tiers')],
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

Finder _collection(String id) => find.byKey(Key('list-$id'));
Finder _items(String id) => find.byKey(Key('list-items-$id'));
Finder _itemOf(String id) => find.byKey(Key('list-item-$id'));

void main() {
  group('MentoraListLayout — the official presentation of a collection', () {
    testWidgets('it is a specialization of the one foundation, and the '
        'registry knows its shape', (tester) async {
      expect(_layout(), isA<MentoraLayout>());
      expect(_layout().kind, MentoraLayoutKind.list);

      await _pump(tester, _layout());
      expect(find.byKey(const Key('layout-list')), findsOneWidget);
      expect(find.byType(MentoraWorkspace), findsOneWidget);
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
    });

    testWidgets('it describes the collection and builds nothing: the '
        'assembly places it', (tester) async {
      await _pump(tester, _layout());

      expect(_collection('transactions'), findsOneWidget);
      expect(_items('transactions'), findsOneWidget);
      for (final id in const ['premier', 'second', 'tiers']) {
        expect(_itemOf(id), findsOneWidget, reason: id);
      }
    });

    testWidgets('the elements are handed on strictly intact: each one '
        'occupies exactly what it is', (tester) async {
      await _pump(tester, _layout());

      for (final id in const ['premier', 'second', 'tiers']) {
        expect(
          tester.getRect(_itemOf(id)),
          tester.getRect(find.byKey(Key('element-$id'))),
          reason: 'the layout wraps $id in nothing',
        );
      }
    });

    testWidgets('the first element starts exactly where the collection '
        'starts', (tester) async {
      await _pump(tester, _layout(items: [_item('premier')]));

      expect(
        tester.getTopLeft(_itemOf('premier')),
        tester.getTopLeft(_collection('transactions')),
      );
      expect(
        tester.getTopLeft(_collection('transactions')),
        tester.getTopLeft(find.byType(MentoraPageScaffold)),
      );
    });

    testWidgets('the order announced is the order read', (tester) async {
      await _pump(tester, _layout());
      final tops = [
        for (final id in const ['premier', 'second', 'tiers'])
          tester.getRect(_itemOf(id)).top,
      ];
      expect(tops[1], greaterThan(tops[0]));
      expect(tops[2], greaterThan(tops[1]));

      // The same elements, announced in another order, are read in
      // that order: nothing is sorted, nothing is reversed.
      await _pump(
        tester,
        _layout(items: [_item('tiers'), _item('second'), _item('premier')]),
      );
      expect(
        tester.getRect(_itemOf('tiers')).top,
        lessThan(tester.getRect(_itemOf('premier')).top),
      );
    });

    testWidgets('it adds no room and no separation between the elements', (
      tester,
    ) async {
      await _pump(tester, _layout());

      final premier = tester.getRect(_itemOf('premier'));
      final second = tester.getRect(_itemOf('second'));
      final tiers = tester.getRect(_itemOf('tiers'));
      expect(second.top, premier.bottom);
      expect(tiers.top, second.bottom);
      // The absence is a declared value, never an accident of code.
      expect(layoutContentGap, 0);
      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('it creates no scroll view, no sliver and no '
        'virtualization', (tester) async {
      await _pump(tester, _layout());

      expect(find.byType(Scrollable), findsNothing);
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.byType(ListView), findsNothing);
      expect(find.byType(CustomScrollView), findsNothing);
      expect(find.byType(Scrollbar), findsNothing);
    });

    testWidgets('it creates no padding of its own: a collection takes '
        'the whole room it was given, from its very edge', (tester) async {
      await _pump(tester, _layout());

      final page = tester.getRect(find.byType(MentoraPageScaffold));
      final collection = tester.getRect(_collection('transactions'));
      expect(collection.left, page.left);
      expect(collection.width, page.width);
      expect(collection.top, page.top);
    });

    testWidgets('only the collection is announced: the layout never '
        'speaks in an element place', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _layout());

      expect(find.bySemanticsLabel(_list), findsOneWidget);
      expect(tester.getSemantics(_collection('transactions')).label, _list);
      // Every element keeps its own voice, and the layout adds none.
      for (final id in const ['premier', 'second', 'tiers']) {
        expect(find.bySemanticsLabel('Élément $id'), findsOneWidget);
      }
      handle.dispose();
    });

    testWidgets('an element keeps its own semantics, whole', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        _layout(
          items: [
            _item(
              'awa',
              content: const MentoraListTile(
                key: Key('element-awa'),
                headline: 'Awa Mensah',
                semanticLabel: 'Awa Mensah, consultation confirmée',
              ),
            ),
          ],
        ),
      );

      expect(
        find.bySemanticsLabel('Awa Mensah, consultation confirmée'),
        findsOneWidget,
      );
      expect(find.byType(MentoraListTile), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a collection is one landmark and one focus group', (
      tester,
    ) async {
      await _pump(tester, _layout());

      expect(
        find.descendant(
          of: _collection('transactions'),
          matching: find.byType(FocusTraversalGroup),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the focus stays where the person left it: the layout '
        'never takes it', (tester) async {
      final inside = FocusNode(debugLabel: 'element');
      addTearDown(inside.dispose);

      await _pump(
        tester,
        _layout(
          items: [
            _item(
              'premier',
              content: Focus(focusNode: inside, child: _element('premier')),
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

    testWidgets('an element is an identity: it is found by what it is, '
        'never by where it stands', (tester) async {
      await _pump(tester, _layout());

      expect(_itemOf('premier'), findsOneWidget);
      expect(_itemOf('elsewhere'), findsNothing);
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

    testWidgets('a list layout without a contract refuses to build — '
        'fail closed', (tester) async {
      Future<void> refuses(Widget layout) async {
        await _pump(tester, layout);
        expect(tester.takeException(), isStateError);
      }

      // A collection with no elements.
      await refuses(_layout(items: const []));
      // A collection without an identity.
      await refuses(_layout(listId: ''));
      // A collection without a name.
      await refuses(_layout(listSemanticLabel: ''));
      // An element without an identity.
      await refuses(_layout(items: [_item('')]));
      // Two elements sharing one identity.
      await refuses(_layout(items: [_item('premier'), _item('premier')]));
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
        expect(_collection('transactions'), findsOneWidget);
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
        expect(_itemOf('premier'), findsOneWidget);
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

    testWidgets('it holds in both reading directions, and the elements '
        'still take the whole width', (tester) async {
      for (final direction in TextDirection.values) {
        await _pump(tester, _layout(), direction: direction);
        expect(tester.takeException(), isNull, reason: direction.name);
        expect(
          tester.getRect(_itemOf('premier')).width,
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

    Iterable<File> listFiles() =>
        dartFilesOf('lib/foundation/design_kit/layout/list_layout');

    test('a collection scrolls nothing, virtualizes nothing and '
        'separates nothing', () {
      // Structural, never lexical: a type USED carries a constructor,
      // a member or a type argument behind it — the prose above may
      // name what the code may not carry.
      final forbidden = <String, RegExp>{
        'a scroll view': RegExp(
          r'(?<![A-Za-z])(ListView|CustomScrollView|SingleChildScrollView|'
          r'Scrollable|ScrollView|Scrollbar|ScrollbarTheme|'
          r'ScrollController|NestedScrollView|PageView)\s*[(.<]',
        ),
        'a sliver': RegExp(r'(?<![A-Za-z])(Sliver\w*|ListBody)\s*[(.<]'),
        'a separation': RegExp(
          r'(?<![A-Za-z])(Divider|VerticalDivider)\s*[(.<]',
        ),
        'a grid': RegExp(
          r'(?<![A-Za-z])(GridView|GridPaper|Table|Flow)\s*[(.<]',
        ),
        'a lazy build': RegExp(
          r'(?<![A-Za-z])(itemBuilder|itemCount|separatorBuilder)'
          r'(?![A-Za-z])',
        ),
      };
      final files = listFiles();
      expect(files, isNotEmpty);
      for (final file in files) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: a collection is a sequence — it never '
                'carries ${entry.key}',
          );
        }
      }
    });

    test('a collection builds no framework widget and no room of its '
        'own', () {
      final forbidden = <String, RegExp>{
        'a padding': RegExp(r'(?<![A-Za-z])Padding\('),
        'a safe area': RegExp(r'(?<![A-Za-z])SafeArea\('),
        'a decorative box': RegExp(
          r'(?<![A-Za-z])(Container|DecoratedBox|ColoredBox)\(',
        ),
        'a flexible space': RegExp(
          r'(?<![A-Za-z])(Expanded|Flexible|Spacer)(?![A-Za-z])',
        ),
        'its own words': RegExp(r'(?<![A-Za-z])Text\('),
        'its own style': RegExp(r'(?<![A-Za-z])TextStyle\('),
      };
      for (final file in listFiles()) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason: '${file.path}: it never builds ${entry.key}',
          );
        }
      }
    });

    test('a collection orders nothing, measures nothing and knows no '
        'business', () {
      final forbidden = <String, RegExp>{
        'an order of its own': RegExp(
          r'\.(sort|reversed|where|firstWhere|lastWhere|singleWhere|'
          r'reduce|fold|groupBy|skip|take)\b',
        ),
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
        'a route type': RegExp(r'(?<![A-Za-z])Route<'),
        'a business domain': RegExp(
          r'(?<![A-Za-z])(Wallet|Orders?|Marketplace|Business|Inventory|'
          r'Payments?|Messages?|Consultation|Profile|Analytics|Settings|'
          r'Reports?|Invoice|Facture|Product|Chat|Dashboard|Tickets?|'
          r'Logs?)(?![a-z])',
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
      for (final file in listFiles()) {
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

    test('a collection reads no ambient theme and codes no value', () {
      final forbidden = <String, RegExp>{
        'an ambient theme': RegExp(r'Theme\.of\('),
        'a coded colour': RegExp(r'(Color\(0x|Colors\.)'),
        'a coded padding': RegExp(r'EdgeInsets\.\w+\(\s*[0-9]'),
        'a coded radius': RegExp(r'BorderRadius\.\w+\(\s*[0-9]'),
        'a coded extent': RegExp(r'(width|height|spacing|runSpacing):\s*[0-9]'),
        'a coded duration': RegExp(r'Duration\((milliseconds|seconds)'),
        'a coded voice': RegExp(r'(fontSize:|FontWeight\.)'),
      };
      for (final file in listFiles()) {
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

    test('one list layout exists in the whole product, it extends the '
        'foundation, and it builds nothing at all', () {
      final declarations = <String>[];
      for (final file in dartFilesOf('lib')) {
        if (RegExp(
          r'class\s+MentoraListLayout(?![A-Za-z])',
        ).hasMatch(file.readAsStringSync())) {
          declarations.add(file.path.replaceAll(r'\', '/'));
        }
      }
      expect(declarations, hasLength(1));
      expect(declarations.single, contains('layout/list_layout/'));

      final source = File(declarations.single).readAsStringSync();
      // It extends the COLLECTED foundation: it therefore owns no
      // identity, no refusal and no surface — it owns its official
      // kind, and the words it calls its collection by, which are
      // aliases over the one holder and never second fields.
      expect(
        RegExp(
          r'extends\s+MentoraCollectedLayout(?![A-Za-z])',
        ).hasMatch(source),
        isTrue,
      );
      expect(RegExp(r'Widget\s+build\(').hasMatch(source), isFalse);
      expect(RegExp(r'void\s+verify\(').hasMatch(source), isFalse);
      expect(RegExp(r'surfaceOf\(').hasMatch(source), isFalse);
      expect(RegExp(r'final\s+[\w<>?, ]+\s+\w+\s*;').hasMatch(source), isFalse);
      expect(
        RegExp(r'String\s+get\s+listId\s*=>\s*collectionId;').hasMatch(source),
        isTrue,
      );
      expect(
        RegExp(
          r'List<MentoraIdentifiedContent>\s+get\s+items\s*=>\s*contents;',
        ).hasMatch(source),
        isTrue,
      );
      // It describes: it never composes a widget of any kind.
      expect(
        RegExp(r'return\s+\w+\(\s*$', multiLine: true).hasMatch(source),
        isFalse,
      );
      for (final built in const [
        'MentoraWorkspace(',
        'MentoraPageScaffold(',
        'MentoraDialogHost(',
        'MentoraSnackbarHost(',
        'Column(',
        'Semantics(',
        'FocusTraversalGroup(',
      ]) {
        expect(source.contains(built), isFalse, reason: built);
      }
    });
  });
}
