import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/bootstrap/design_kit_bootstrap.dart';
import 'package:mentora/foundation/core/di/foundation_services.dart';
import 'package:mentora/foundation/design_kit/accessibility/accessibility_engine.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/components/avatar/mentora_avatar.dart';
import 'package:mentora/foundation/design_kit/components/avatar/mentora_avatar_style.dart';
import 'package:mentora/foundation/design_kit/components/badge/mentora_badge.dart';
import 'package:mentora/foundation/design_kit/components/badge/mentora_badge_style.dart';
import 'package:mentora/foundation/design_kit/components/button/mentora_button.dart';
import 'package:mentora/foundation/design_kit/components/button/mentora_button_style.dart';
import 'package:mentora/foundation/design_kit/components/card/mentora_card.dart';
import 'package:mentora/foundation/design_kit/components/card/mentora_card_style.dart';
import 'package:mentora/foundation/design_kit/components/design_kit_scope.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text_role.dart';
import 'package:mentora/foundation/design_kit/composition/list_tile/mentora_list_tile.dart';
import 'package:mentora/foundation/design_kit/layout/catalog_layout/mentora_catalog_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_collected_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_context.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_kind.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_style.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_page_like_layout.dart';
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

/// What the application owns — recognisable, already built, and never
/// touched by the layout that presents it. The words carry an amount
/// on purpose: the layout must hand them on without understanding
/// them.
Widget _offer(String id) => MentoraText(
  'Entrée $id — 12 500 FCFA',
  key: Key('entry-$id'),
  role: MentoraTextRole.body,
);

MentoraIdentifiedContent _entry(String id, {Widget? content}) =>
    MentoraIdentifiedContent(id: id, content: content ?? _offer(id));

const List<String> _identities = ['conseil', 'formation', 'accompagnement'];

const MentoraLayoutContext _frame = MentoraLayoutContext(
  semanticLabel: 'Contexte de travail',
  navigation: MentoraNavigationAnnouncement(destinationId: 'home'),
);

MentoraCatalogLayout _layout({
  MentoraLayoutContext frame = _frame,
  String pageSemanticLabel = 'Page courante',
  String catalogId = 'offre',
  String catalogSemanticLabel = 'L’offre',
  List<MentoraIdentifiedContent>? entries,
  MentoraAppBar? place,
  List<MentoraButton> acts = const [],
}) {
  return MentoraCatalogLayout(
    frame: frame,
    pageSemanticLabel: pageSemanticLabel,
    catalogId: catalogId,
    catalogSemanticLabel: catalogSemanticLabel,
    entries: entries ?? [for (final id in _identities) _entry(id)],
    place: place,
    acts: acts,
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

Finder _catalog() => find.byKey(const Key('list-offre'));

Finder _entryOf(String id) => find.byKey(Key('list-item-$id'));

void main() {
  group('MentoraCatalogLayout — a person going through an offer', () {
    testWidgets('it is a specialization of the one foundation, through '
        'the collected foundation, and the registry knows its shape', (
      tester,
    ) async {
      expect(_layout(), isA<MentoraLayout>());
      expect(_layout(), isA<MentoraPageLikeLayout>());
      expect(_layout(), isA<MentoraCollectedLayout>());
      expect(_layout().kind, MentoraLayoutKind.catalog);

      await _pump(tester, _layout());
      expect(find.byKey(const Key('layout-catalog')), findsOneWidget);
      expect(find.byType(MentoraWorkspace), findsOneWidget);
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
    });

    test('the words of an offer are aliases over the one holder: there '
        'is no second field anywhere', () {
      final entries = [for (final id in _identities) _entry(id)];
      final layout = _layout(entries: entries);

      expect(layout.catalogId, 'offre');
      expect(layout.catalogId, layout.collectionId);
      expect(layout.catalogSemanticLabel, layout.collectionSemanticLabel);
      expect(layout.entries, same(entries));
      expect(layout.entries, same(layout.contents));
    });

    test('the list speaks the same machinery: its words are aliases '
        'over the very same holder — the migration is total', () {
      final items = [for (final id in _identities) _entry(id)];
      final list = MentoraListLayout(
        frame: _frame,
        pageSemanticLabel: 'Page courante',
        listId: 'transactions',
        listSemanticLabel: 'Les transactions',
        items: items,
      );

      expect(list, isA<MentoraCollectedLayout>());
      expect(list.listId, list.collectionId);
      expect(list.listSemanticLabel, list.collectionSemanticLabel);
      expect(list.items, same(list.contents));
    });

    testWidgets('it asks the assembly for the single disposition: it '
        'arranges nothing itself', (tester) async {
      await _pump(tester, _layout());

      expect(_catalog(), findsOneWidget);
      for (final id in _identities) {
        expect(_entryOf(id), findsOneWidget, reason: id);
      }
    });

    testWidgets('an entry is an IDENTITY: the product refers to it by '
        'what it is, never by where it stands', (tester) async {
      await _pump(tester, _layout());

      expect(_entryOf('formation'), findsOneWidget);
      expect(find.byKey(const Key('list-item-0')), findsNothing);
      expect(find.byKey(const Key('list-item-ailleurs')), findsNothing);
    });

    testWidgets('an entry is never a position: announced in another '
        'order it is still the same entry, whole', (tester) async {
      await _pump(
        tester,
        _layout(entries: [for (final id in _identities.reversed) _entry(id)]),
      );

      expect(_entryOf('formation'), findsOneWidget);
      expect(find.byKey(const Key('entry-formation')), findsOneWidget);
    });

    testWidgets('the order announced is the order read — the reversed '
        'announcement is expressed reversed, never rearranged', (tester) async {
      await _pump(
        tester,
        _layout(entries: [for (final id in _identities.reversed) _entry(id)]),
      );

      var previous = tester.getRect(_entryOf(_identities.last)).top;
      for (final id in _identities.reversed.skip(1)) {
        final top = tester.getRect(_entryOf(id)).top;
        expect(top, greaterThan(previous), reason: id);
        previous = top;
      }
    });

    testWidgets('every entry announced is expressed: nothing is '
        'filtered away, nothing is paged, nothing is held back', (
      tester,
    ) async {
      await _pump(tester, _layout());

      for (final id in _identities) {
        expect(_entryOf(id), findsOneWidget, reason: id);
        expect(find.byKey(Key('entry-$id')), findsOneWidget, reason: id);
      }
      expect(find.byType(RefreshIndicator), findsNothing);
      expect(find.byType(PageView), findsNothing);
    });

    testWidgets('an entry is handed on strictly intact: the words carry '
        'an amount, and the layout never reads it', (tester) async {
      await _pump(tester, _layout());

      // What was written is exactly what stands — no currency
      // understood, no rounding, no interpretation of any kind.
      for (final id in _identities) {
        expect(find.text('Entrée $id — 12 500 FCFA'), findsOneWidget);
        expect(
          tester.getTopLeft(find.byKey(Key('entry-$id'))),
          tester.getTopLeft(_entryOf(id)),
          reason: id,
        );
      }
    });

    testWidgets('it adds no room between the entries', (tester) async {
      await _pump(tester, _layout());

      var previous = tester.getRect(_entryOf(_identities.first));
      for (final id in _identities.skip(1)) {
        final rect = tester.getRect(_entryOf(id));
        expect(rect.top, previous.bottom, reason: id);
        previous = rect;
      }
      expect(layoutContentGap, 0);
    });

    testWidgets('it creates no scroll view and no padding of its own', (
      tester,
    ) async {
      await _pump(tester, _layout(entries: [_entry('conseil')]));

      expect(find.byType(Scrollable), findsNothing);
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.byType(ListView), findsNothing);
      expect(find.byType(GridView), findsNothing);

      final page = tester.getRect(find.byType(MentoraPageScaffold));
      final catalog = tester.getRect(_catalog());
      expect(catalog.left, page.left);
      expect(catalog.width, page.width);
      expect(catalog.top, page.top);
    });

    testWidgets('the components stay the owners of what an entry is '
        'made of', (tester) async {
      await _pump(
        tester,
        _layout(
          entries: [
            _entry(
              'conseil',
              content: const MentoraCard(
                key: Key('entry-conseil'),
                variant: MentoraCardVariant.surface,
                child: MentoraListTile(
                  headline: 'Awa Diallo',
                  semanticLabel: 'Awa Diallo',
                  leading: MentoraAvatar(
                    identity: MentoraAvatarIdentity.initials,
                    name: 'Awa Diallo',
                    initials: 'AD',
                  ),
                  badges: [
                    MentoraBadge(
                      variant: MentoraBadgeVariant.verified,
                      label: 'Vérifié',
                      semanticLabel: 'Vérifié',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

      expect(find.byType(MentoraCard), findsOneWidget);
      expect(find.byType(MentoraListTile), findsOneWidget);
      expect(find.byType(MentoraAvatar), findsOneWidget);
      expect(find.byType(MentoraBadge), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the same shape carries any offer: it represents no '
        'domain of the company', (tester) async {
      for (final subject in const ['première offre', 'seconde offre']) {
        await _pump(
          tester,
          _layout(
            catalogSemanticLabel: subject,
            entries: [
              _entry(
                'conseil',
                content: MentoraText(subject, role: MentoraTextRole.body),
              ),
            ],
          ),
        );

        expect(tester.takeException(), isNull, reason: subject);
        expect(find.text(subject), findsOneWidget);
      }
    });

    testWidgets('only the catalog is announced: every entry keeps its '
        'own voice', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        _layout(
          entries: [
            _entry(
              'conseil',
              content: const MentoraListTile(
                key: Key('entry-conseil'),
                headline: 'Awa Diallo',
                semanticLabel: 'Awa Diallo',
              ),
            ),
          ],
        ),
      );

      expect(tester.getSemantics(_catalog()).label, 'L’offre');
      expect(find.bySemanticsLabel('L’offre'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Awa Diallo')), findsWidgets);
      handle.dispose();
    });

    testWidgets('an entry keeps its own rect: the key holder adds no '
        'geometry of its own', (tester) async {
      await _pump(tester, _layout(entries: [_entry('conseil')]));

      expect(
        tester.getRect(find.byKey(const Key('entry-conseil'))),
        tester.getRect(_entryOf('conseil')),
      );
    });

    testWidgets('the catalog travels as one focus group', (tester) async {
      await _pump(tester, _layout());

      expect(
        find.descendant(
          of: _catalog(),
          matching: find.byType(FocusTraversalGroup),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the layout never takes the focus, and never gives it '
        'back to itself', (tester) async {
      final inside = FocusNode(debugLabel: 'inside');
      addTearDown(inside.dispose);

      await _pump(
        tester,
        _layout(
          entries: [
            _entry(
              'conseil',
              content: Focus(focusNode: inside, child: _offer('conseil')),
            ),
          ],
        ),
      );

      expect(inside.hasPrimaryFocus, isFalse);
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
          entries: [_entry('conseil')],
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

    testWidgets('a catalog layout without a contract refuses to build — '
        'fail closed, ten times over', (tester) async {
      Future<void> refuses(Widget layout) async {
        await _pump(tester, layout);
        expect(tester.takeException(), isStateError);
      }

      // 1. A catalog without an identity is not one.
      await refuses(_layout(catalogId: ''));
      // 2. A catalog without a name is not a landmark.
      await refuses(_layout(catalogSemanticLabel: ''));
      // 3. A catalog with no entry presents nothing.
      await refuses(_layout(entries: const []));
      // 4. An entry without an identity is not an entry.
      await refuses(_layout(entries: [_entry('')]));
      // 5. And it is refused wherever it stands: the whole collection
      //    is walked, never its head alone.
      await refuses(_layout(entries: [_entry('conseil'), _entry('')]));
      // 6. Two entries never share one identity.
      await refuses(_layout(entries: [_entry('conseil'), _entry('conseil')]));
      // 7. And identity is a set, not a comparison with the neighbour.
      await refuses(
        _layout(
          entries: [_entry('conseil'), _entry('formation'), _entry('conseil')],
        ),
      );
      // 8. A page announces itself.
      await refuses(_layout(pageSemanticLabel: ''));
      // 9. The working context announces itself.
      await refuses(
        _layout(
          frame: const MentoraLayoutContext(
            semanticLabel: '',
            navigation: MentoraNavigationAnnouncement(destinationId: 'home'),
          ),
        ),
      );
      // 10. Outside the Design Kit nothing is resolved.
      await tester.pumpWidget(MaterialApp(home: _layout()));
      expect(tester.takeException(), isStateError);
    });

    testWidgets('a catalog layout is a whole screen: it never carries a '
        'second one — fail closed', (tester) async {
      final refusals = <Object>[];
      final reporter = FlutterError.onError;
      FlutterError.onError = (details) => refusals.add(details.exception);
      await _pump(
        tester,
        _layout(entries: [_entry('conseil', content: _layout())]),
      );
      FlutterError.onError = reporter;

      expect(refusals.whereType<StateError>(), isNotEmpty);
      expect(
        refusals.whereType<StateError>().first.message,
        contains('never placed inside another'),
      );
    });

    testWidgets('it holds in the four themes', (tester) async {
      for (final variant in ThemeVariantId.values) {
        await _pump(tester, _layout(), variant: variant);
        expect(tester.takeException(), isNull, reason: variant.name);
        expect(_catalog(), findsOneWidget);
      }
    });

    testWidgets('it holds at every font scale', (tester) async {
      for (final scale in FontScalePreference.values) {
        await _pump(
          tester,
          _layout(entries: [_entry('conseil')]),
          appearance: AppearanceState(fontScale: scale),
        );
        expect(tester.takeException(), isNull, reason: scale.name);
        expect(_catalog(), findsOneWidget);
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

    testWidgets('it holds in both reading directions, and the catalog '
        'still takes the whole width', (tester) async {
      for (final direction in TextDirection.values) {
        await _pump(tester, _layout(), direction: direction);
        expect(tester.takeException(), isNull, reason: direction.name);
        expect(
          tester.getRect(_catalog()).width,
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
  });

  group('Governance — the executable scans ship with the layout', () {
    Iterable<File> dartFilesOf(String path) => Directory(path)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    /// What a file COMMITS.
    ///
    /// A scan opposes code, and a comment is not code: documenting a
    /// prohibition has never been committing it.
    String codeOf(File file) => file
        .readAsLinesSync()
        .map((line) {
          final comment = line.indexOf('//');
          return comment == -1 ? line : line.substring(0, comment);
        })
        .join('\n');

    /// The shape AND the foundation it is built on: the machinery
    /// lives there, so the scans follow it.
    Iterable<File> catalogFiles() => [
      ...dartFilesOf('lib/foundation/design_kit/layout/catalog_layout'),
      File(
        'lib/foundation/design_kit/layout/foundation/'
        'mentora_collected_layout.dart',
      ),
    ];

    void refuse(Map<String, RegExp> forbidden, String because) {
      final files = catalogFiles().toList();
      expect(files, isNotEmpty);
      for (final file in files) {
        final source = codeOf(file);
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason: '${file.path}: $because ${entry.key}',
          );
        }
      }
    }

    test('a catalog layout knows nothing of commerce', () {
      // Structural, never lexical: a concept USED carries a
      // constructor, a member or a named argument behind it — the
      // prose may name what the code may not carry.
      refuse({
        'an article of commerce': RegExp(
          r'(?<![A-Za-z])(Product|Price|Currency|Category|Stock|Promotion|'
          r'Discount|Cart|Order|Sku)(?![a-z])',
        ),
        'an amount understood': RegExp(
          r'(?<![A-Za-z])(price|amount|currency|cost|total)\s*[:.(=]',
        ),
        'an availability': RegExp(
          r'(?<![A-Za-z])(availability|available|inStock|outOfStock)'
          r'\s*[:.(=]',
        ),
      }, 'it never carries');
    });

    test('a catalog layout selects nothing, rearranges nothing and '
        'pages nothing', () {
      refuse({
        'a selection or an order of its own': RegExp(
          r'\.(where|firstWhere|lastWhere|singleWhere|sort|sorted|reversed|'
          r'reduce|fold|skip|take|expand|removeWhere|retainWhere)\s*[(.]',
        ),
        'a filter or a search': RegExp(
          r'(?<![A-Za-z])(filter\w*|Filter|search|query)\s*[:.(=<]',
        ),
        'a paging': RegExp(
          r'(?<![A-Za-z])(pageSize|pageToken|offset|cursor|limit|hasMore|'
          r'loadMore|nextPage|paginat\w+)\s*[:.(=]',
        ),
        'a count or an arithmetic': RegExp(
          r'(\.length|~/|\.ceil\(|\.floor\(|\.round\()',
        ),
      }, 'it never carries');
    });

    test('a catalog layout knows no data, no network and no state', () {
      refuse({
        'a model': RegExp(
          r'(?<![A-Za-z])(User|Wallet|Expert|Consultation|Invoice|Business|'
          r'Account|Profile|Entity|Model|Repository)(?![a-z])',
        ),
        'a source of data': RegExp(
          r'(?<![A-Za-z])(Provider|Bloc|Cubit|Riverpod|ChangeNotifier|'
          r'StreamBuilder|FutureBuilder)(?![A-Za-z])',
        ),
        'a network or a promise': RegExp(
          r'(?<![A-Za-z])(http|HttpClient|Firestore|Future|Stream|async|'
          r'await)(?![A-Za-z])',
        ),
        'a state of the offer': RegExp(
          r'(?<![A-Za-z])(loading|refreshing|error|success|offline|'
          r'processing|waiting)(?![A-Za-z])',
        ),
        'a memory of its own': RegExp(
          r'(?<![A-Za-z])(StatefulWidget|setState|initState|ValueNotifier)'
          r'(?![A-Za-z])',
        ),
        'an untyped value': RegExp(
          r'(?<![A-Za-z])(dynamic|Object\?)(?![A-Za-z])',
        ),
        'an untyped entry': RegExp(r'final\s+Widget\?\s'),
      }, 'it never carries');
    });

    test('a catalog layout builds no framework widget, measures nothing '
        'and navigates nowhere', () {
      refuse({
        'a room of its own': RegExp(
          r'(?<![A-Za-z])(Padding|SafeArea|Expanded|Flexible|Spacer|Wrap|'
          r'Flow)\s*[(.<]',
        ),
        'a scroll view or a collection': RegExp(
          r'(?<![A-Za-z])(Scrollable|ScrollView|SingleChildScrollView|'
          r'ListView|GridView|Sliver\w*|Scrollbar|RefreshIndicator|'
          r'PageView)\s*[(.<]',
        ),
        'its own words': RegExp(r'(?<![A-Za-z])Text\('),
        'its own style': RegExp(r'(?<![A-Za-z])TextStyle\('),
        'a measure of the screen': RegExp(
          r'(?<![A-Za-z])(MediaQuery|LayoutBuilder|ResponsiveEngine|'
          r'Breakpoint\w*|OrientationBuilder)\s*[(.<]',
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
        'an ambient theme': RegExp(r'Theme\.of\('),
        'a coded colour': RegExp(r'(Color\(0x|Colors\.)'),
        'a coded extent': RegExp(r'(width|height|spacing|runSpacing):\s*[0-9]'),
        'a coded duration': RegExp(r'Duration\((milliseconds|seconds)'),
      }, 'it never carries');
    });

    test('one catalog layout exists in the whole product, it extends '
        'the collected foundation, and it declares nothing else', () {
      final declarations = <String>[];
      for (final file in dartFilesOf('lib')) {
        if (RegExp(
          r'class\s+MentoraCatalogLayout(?![A-Za-z])',
        ).hasMatch(file.readAsStringSync())) {
          declarations.add(file.path.replaceAll(r'\', '/'));
        }
      }
      expect(declarations, hasLength(1));
      expect(declarations.single, contains('layout/catalog_layout/'));

      final source = codeOf(File(declarations.single));
      expect(
        RegExp(
          r'extends\s+MentoraCollectedLayout(?![A-Za-z])',
        ).hasMatch(source),
        isTrue,
      );
      for (final owned in const [
        r'Widget\s+build\(',
        r'surfaceOf\(',
        r'void\s+verify\(',
        r'final\s+[\w<>?, ]+\s+\w+\s*;',
        r'enum\s+\w+',
      ]) {
        expect(RegExp(owned).hasMatch(source), isFalse, reason: owned);
      }
      // The words of the offer are aliases over the one holder.
      expect(
        RegExp(
          r'String\s+get\s+catalogId\s*=>\s*collectionId;',
        ).hasMatch(source),
        isTrue,
      );
      expect(
        RegExp(
          r'List<MentoraIdentifiedContent>\s+get\s+entries\s*=>\s*contents;',
        ).hasMatch(source),
        isTrue,
      );
      for (final built in const [
        'MentoraWorkspace(',
        'MentoraPageScaffold(',
        'MentoraCard(',
        'MentoraListTile(',
        'MentoraButton(',
        'Column(',
        'Semantics(',
        'FocusTraversalGroup(',
        'KeyedSubtree(',
      ]) {
        expect(source.contains(built), isFalse, reason: built);
      }
    });

    test('no duplication was introduced: every shape that presents a '
        'collection owns nothing of how it is presented', () {
      final shapes = <String>[];
      for (final file in dartFilesOf('lib')) {
        final source = codeOf(file);
        if (!RegExp(
          r'extends\s+MentoraCollectedLayout(?![A-Za-z])',
        ).hasMatch(source)) {
          continue;
        }
        shapes.add(file.path.replaceAll(r'\', '/'));
        for (final owned in const [
          r'MentoraLayoutSurface\.',
          r'void\s+verify\(',
          r'final\s+List<MentoraIdentifiedContent>',
          r'final\s+String\s+collection',
        ]) {
          expect(
            RegExp(owned).hasMatch(source),
            isFalse,
            reason: '$file: the collected foundation owns $owned',
          );
        }
      }
      // More than one shape presents a collection, and the machinery
      // exists once — in the foundation they extend.
      expect(shapes.length, greaterThan(1));

      final foundation = codeOf(
        File(
          'lib/foundation/design_kit/layout/foundation/'
          'mentora_collected_layout.dart',
        ),
      );
      expect(
        RegExp(
          r'final List<MentoraIdentifiedContent> contents;',
        ).hasMatch(foundation),
        isTrue,
      );
    });

    test('the unit of a collection is the one identified content: no '
        'entry type of its own was opened', () {
      final twins = <String>[];
      for (final file in dartFilesOf('lib/foundation/design_kit/layout')) {
        final source = file.readAsStringSync();
        for (final match in RegExp(
          r'final class (Mentora\w+) \{',
        ).allMatches(source)) {
          final declaration = source.substring(match.start);
          final body = declaration.substring(0, declaration.indexOf('\n}') + 1);
          final fields = RegExp(
            r'final \w+\??\s+(\w+);',
          ).allMatches(body).map((field) => field.group(1)).toSet();
          if (fields.length == 2 &&
              fields.contains('id') &&
              fields.contains('content')) {
            twins.add(match.group(1)!);
          }
        }
      }
      expect(twins, ['MentoraIdentifiedContent']);
    });
  });
}
