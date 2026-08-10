import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_navigation_announcement.dart';
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
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_collected_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_context.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_kind.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_style.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_page_like_layout.dart';
import 'package:mentora/foundation/design_kit/layout/search_results_layout/mentora_search_results_layout.dart';
import 'package:mentora/foundation/design_kit/motion/motion_engine.dart';
import 'package:mentora/foundation/design_kit/registry/token_engines.dart';
import 'package:mentora/foundation/design_kit/structure/app_bar/mentora_app_bar.dart';
import 'package:mentora/foundation/design_kit/structure/page_scaffold/mentora_page_scaffold.dart';
import 'package:mentora/foundation/design_kit/structure/workspace/mentora_workspace.dart';
import 'package:mentora/foundation/design_kit/theme/theme_engine.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';
import 'package:mentora/foundation/design_kit/tokens/layout_tokens.dart';
import 'package:mentora/foundation/design_kit/tokens/surface_elevation_tokens.dart';

/// What the application owns — recognisable, already built, and never
/// touched by the layout that presents it. The words carry the marks
/// of a seeking on purpose — a relevance, a rank among the others —
/// so the layout must hand them on without understanding any of them.
Widget _words(String id) => MentoraText(
  'Résultat $id — 97 % pertinent, 1er sur 3',
  key: Key('result-$id'),
  role: MentoraTextRole.body,
);

MentoraIdentifiedContent _result(String id, {Widget? content}) =>
    MentoraIdentifiedContent(id: id, content: content ?? _words(id));

/// The identities are words of the product, never ranks and never
/// measures: what they suggest as an order is deliberately NOT the
/// order they are announced in.
const List<String> _identities = [
  'troisieme-trouvaille',
  'premiere-trouvaille',
  'deuxieme-trouvaille',
];

const MentoraLayoutContext _frame = MentoraLayoutContext(
  semanticLabel: 'Contexte de travail',
  navigation: MentoraNavigationAnnouncement(destinationId: 'home'),
);

MentoraSearchResultsLayout _layout({
  MentoraLayoutContext frame = _frame,
  String pageSemanticLabel = 'Page courante',
  String searchResultsId = 'trouvailles',
  String searchResultsSemanticLabel = 'Ce qui a été trouvé',
  List<MentoraIdentifiedContent>? results,
  MentoraAppBar? place,
  List<MentoraButton> acts = const [],
}) {
  return MentoraSearchResultsLayout(
    frame: frame,
    pageSemanticLabel: pageSemanticLabel,
    searchResultsId: searchResultsId,
    searchResultsSemanticLabel: searchResultsSemanticLabel,
    results: results ?? [for (final id in _identities) _result(id)],
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

Finder _collection() => find.byKey(const Key('list-trouvailles'));

Finder _resultOf(String id) => find.byKey(Key('list-item-$id'));

void main() {
  group('MentoraSearchResultsLayout — a collection of results already '
      'found', () {
    testWidgets('it is a specialization of the one foundation, through '
        'the collected foundation, and the registry knows its shape', (
      tester,
    ) async {
      expect(_layout(), isA<MentoraLayout>());
      expect(_layout(), isA<MentoraPageLikeLayout>());
      expect(_layout(), isA<MentoraCollectedLayout>());
      expect(_layout().kind, MentoraLayoutKind.searchResults);

      await _pump(tester, _layout());
      expect(find.byKey(const Key('layout-searchResults')), findsOneWidget);
      expect(find.byType(MentoraWorkspace), findsOneWidget);
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
    });

    test('the words of a collection of results are aliases over the '
        'one holder: there is no second field anywhere', () {
      final results = [for (final id in _identities) _result(id)];
      final layout = _layout(results: results);

      expect(layout.searchResultsId, 'trouvailles');
      expect(layout.searchResultsId, layout.collectionId);
      expect(layout.searchResultsSemanticLabel, layout.collectionSemanticLabel);
      expect(layout.results, same(results));
      expect(layout.results, same(layout.contents));
    });

    test('the collection is never transformed: the results announced '
        'are exactly the results held, and exactly the results served', () {
      final results = [for (final id in _identities) _result(id)];
      final layout = _layout(results: results);

      // The SAME list instance, end to end: not a copy, not a view,
      // not a rearrangement — the layout never even touched it.
      expect(identical(layout.results, results), isTrue);
      expect(identical(layout.contents, results), isTrue);
      for (var rank = 0; rank < results.length; rank += 1) {
        expect(identical(layout.results[rank], results[rank]), isTrue);
      }
    });

    testWidgets('it asks the assembly for the single disposition: it '
        'arranges nothing itself', (tester) async {
      await _pump(tester, _layout());

      expect(_collection(), findsOneWidget);
      for (final id in _identities) {
        expect(_resultOf(id), findsOneWidget, reason: id);
      }
    });

    testWidgets('a result is an IDENTITY: the product refers to it by '
        'what it is, never by where it stands and never by a rank', (
      tester,
    ) async {
      await _pump(tester, _layout());

      expect(_resultOf('premiere-trouvaille'), findsOneWidget);
      expect(find.byKey(const Key('list-item-0')), findsNothing);
      expect(find.byKey(const Key('list-item-ailleurs')), findsNothing);
    });

    testWidgets('the order announced is the order read: nothing is '
        'ranked here, and nothing is rearranged', (tester) async {
      // The words of every result claim the SAME relevance and the
      // SAME rank, and the identities contradict the announced order
      // on purpose: any shape that ordered by relevance, by rank or by
      // words would betray itself — the announcement is the only order
      // there is.
      await _pump(tester, _layout());

      var previous = tester.getRect(_resultOf(_identities.first)).top;
      for (final id in _identities.skip(1)) {
        final top = tester.getRect(_resultOf(id)).top;
        expect(top, greaterThan(previous), reason: id);
        previous = top;
      }
    });

    testWidgets('announced the other way, it is expressed the other '
        'way: the product owns the order, wherever it points', (tester) async {
      await _pump(
        tester,
        _layout(results: [for (final id in _identities.reversed) _result(id)]),
      );

      var previous = tester.getRect(_resultOf(_identities.last)).top;
      for (final id in _identities.reversed.skip(1)) {
        final top = tester.getRect(_resultOf(id)).top;
        expect(top, greaterThan(previous), reason: id);
        previous = top;
      }
    });

    testWidgets('every result announced is expressed: nothing is '
        'filtered away, nothing is paged, nothing is held back', (
      tester,
    ) async {
      await _pump(tester, _layout());

      for (final id in _identities) {
        expect(_resultOf(id), findsOneWidget, reason: id);
        expect(find.byKey(Key('result-$id')), findsOneWidget, reason: id);
      }
      expect(find.byType(RefreshIndicator), findsNothing);
      expect(find.byType(PageView), findsNothing);
    });

    testWidgets('a result is handed on strictly intact: the words '
        'carry a relevance and a rank, and the layout never reads '
        'them', (tester) async {
      await _pump(tester, _layout());

      // What was written is exactly what stands — no relevance
      // understood, no rank obeyed, no interpretation of any kind.
      for (final id in _identities) {
        expect(
          find.text('Résultat $id — 97 % pertinent, 1er sur 3'),
          findsOneWidget,
          reason: id,
        );
        expect(
          tester.getTopLeft(find.byKey(Key('result-$id'))),
          tester.getTopLeft(_resultOf(id)),
          reason: id,
        );
      }
    });

    testWidgets('it adds no room between the results', (tester) async {
      await _pump(tester, _layout());

      var previous = tester.getRect(_resultOf(_identities.first));
      for (final id in _identities.skip(1)) {
        final rect = tester.getRect(_resultOf(id));
        expect(rect.top, previous.bottom, reason: id);
        previous = rect;
      }
      expect(layoutContentGap, 0);
    });

    testWidgets('it creates no scroll view and no padding of its own', (
      tester,
    ) async {
      await _pump(tester, _layout(results: [_result('premiere-trouvaille')]));

      expect(find.byType(Scrollable), findsNothing);
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.byType(ListView), findsNothing);
      expect(find.byType(GridView), findsNothing);

      final page = tester.getRect(find.byType(MentoraPageScaffold));
      final collection = tester.getRect(_collection());
      expect(collection.left, page.left);
      expect(collection.width, page.width);
      expect(collection.top, page.top);
    });

    testWidgets('the components stay the owners of what a result is '
        'made of', (tester) async {
      await _pump(
        tester,
        _layout(
          results: [
            _result(
              'premiere-trouvaille',
              content: const MentoraCard(
                key: Key('result-premiere-trouvaille'),
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

    testWidgets('the same shape carries any results: it represents no '
        'domain of the company', (tester) async {
      for (final subject in const [
        'premières trouvailles',
        'secondes trouvailles',
      ]) {
        await _pump(
          tester,
          _layout(
            searchResultsSemanticLabel: subject,
            results: [
              _result(
                'premiere-trouvaille',
                content: MentoraText(subject, role: MentoraTextRole.body),
              ),
            ],
          ),
        );

        expect(tester.takeException(), isNull, reason: subject);
        expect(find.text(subject), findsOneWidget);
      }
    });

    testWidgets('only the collection is announced: every result keeps '
        'its own voice', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        _layout(
          results: [
            _result(
              'premiere-trouvaille',
              content: const MentoraListTile(
                key: Key('result-premiere-trouvaille'),
                headline: 'Awa Diallo',
                semanticLabel: 'Awa Diallo',
              ),
            ),
          ],
        ),
      );

      expect(tester.getSemantics(_collection()).label, 'Ce qui a été trouvé');
      expect(find.bySemanticsLabel('Ce qui a été trouvé'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Awa Diallo')), findsWidgets);
      handle.dispose();
    });

    testWidgets('a result keeps its own rect: the key holder adds no '
        'geometry of its own', (tester) async {
      await _pump(tester, _layout(results: [_result('premiere-trouvaille')]));

      expect(
        tester.getRect(find.byKey(const Key('result-premiere-trouvaille'))),
        tester.getRect(_resultOf('premiere-trouvaille')),
      );
    });

    testWidgets('the collection travels as one focus group', (tester) async {
      await _pump(tester, _layout());

      expect(
        find.descendant(
          of: _collection(),
          matching: find.byType(FocusTraversalGroup),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the zones of the page it asks for stay the zones of '
        'the components that own them', (tester) async {
      await _pump(
        tester,
        _layout(
          results: [_result('premiere-trouvaille')],
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

    testWidgets('a collection of results without a contract refuses to '
        'build — fail closed, ten times over', (tester) async {
      Future<void> refuses(Widget layout) async {
        await _pump(tester, layout);
        expect(tester.takeException(), isStateError);
      }

      // 1. A collection without an identity is not one.
      await refuses(_layout(searchResultsId: ''));
      // 2. A collection without a name is not a landmark.
      await refuses(_layout(searchResultsSemanticLabel: ''));
      // 3. A collection with no result presents nothing.
      await refuses(_layout(results: const []));
      // 4. A result without an identity is not a result.
      await refuses(_layout(results: [_result('')]));
      // 5. And it is refused wherever it stands: the whole collection
      //    is walked, never its head alone.
      await refuses(
        _layout(results: [_result('premiere-trouvaille'), _result('')]),
      );
      // 6. Two results never share one identity.
      await refuses(
        _layout(
          results: [
            _result('premiere-trouvaille'),
            _result('premiere-trouvaille'),
          ],
        ),
      );
      // 7. And identity is a set, not a comparison with the neighbour.
      await refuses(
        _layout(
          results: [
            _result('premiere-trouvaille'),
            _result('deuxieme-trouvaille'),
            _result('premiere-trouvaille'),
          ],
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

    testWidgets('a search results layout is a whole screen: it never '
        'carries a second one — fail closed', (tester) async {
      final refusals = <Object>[];
      final reporter = FlutterError.onError;
      FlutterError.onError = (details) => refusals.add(details.exception);
      await _pump(
        tester,
        _layout(results: [_result('premiere-trouvaille', content: _layout())]),
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
        expect(_collection(), findsOneWidget);
      }
    });

    testWidgets('it holds at every font scale', (tester) async {
      for (final scale in FontScalePreference.values) {
        await _pump(
          tester,
          _layout(results: [_result('premiere-trouvaille')]),
          appearance: AppearanceState(fontScale: scale),
        );
        expect(tester.takeException(), isNull, reason: scale.name);
        expect(_collection(), findsOneWidget);
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

    testWidgets('it holds in both reading directions, and the '
        'collection still takes the whole width', (tester) async {
      for (final direction in TextDirection.values) {
        await _pump(tester, _layout(), direction: direction);
        expect(tester.takeException(), isNull, reason: direction.name);
        expect(
          tester.getRect(_collection()).width,
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
    Iterable<File> searchResultsFiles() => [
      ...dartFilesOf('lib/foundation/design_kit/layout/search_results_layout'),
      File(
        'lib/foundation/design_kit/layout/foundation/'
        'mentora_collected_layout.dart',
      ),
    ];

    void refuse(Map<String, RegExp> forbidden, String because) {
      final files = searchResultsFiles().toList();
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

    test('the seeking belongs to the product: no engine, no question '
        'and no way of looking anywhere near this shape', () {
      // Structural, never lexical: a concept USED carries a
      // constructor, a member or a named argument behind it — the
      // prose may name what the code may not carry.
      refuse({
        'an engine or a question': RegExp(
          r'(?<![A-Za-z])(SearchQuery|SearchEngine|SearchProvider|'
          r'SearchService|SearchRepository|Index|Elastic\w*|Meilisearch|'
          r'Algolia|Lucene|Sql|GraphQL)(?![a-z])',
        ),
        'a way of matching words': RegExp(
          r'\.(contains|startsWith|endsWith|indexOf|matchAsPrefix|'
          r'allMatches|toLowerCase|toUpperCase)\(',
        ),
        'a machinery of seeking': RegExp(
          r'(?<![A-Za-z])(match\w*|fuzzy|stemming|synonym\w*|'
          r'highlight\w*|autocomplete|suggestion\w*|spellcheck|'
          r'query|token\w*)\s*[:.(=<]',
        ),
        'a measure of answering': RegExp(
          r'(?<![A-Za-z])(rank\w*|score|scoring|relevance|weight|'
          r'boost)\s*[:.(=]',
        ),
      }, 'it never carries');
    });

    test('a search results layout selects nothing, orders nothing and '
        'pages nothing', () {
      refuse({
        'a selection or an order of its own': RegExp(
          r'\.(where|firstWhere|lastWhere|singleWhere|sort|sorted|reversed|'
          r'reduce|fold|skip|take|expand|removeWhere|retainWhere)\s*[(.]',
        ),
        'a filter or a search': RegExp(
          r'(?<![A-Za-z])(filter\w*|Filter|search)\s*[:.(=<]',
        ),
        'a paging': RegExp(
          r'(?<![A-Za-z])(pageSize|pageToken|offset|cursor|limit|hasMore|'
          r'loadMore|nextPage|paginat\w+|lazy\w*|Lazy\w*)\s*[:.(=]',
        ),
        'a count or an arithmetic': RegExp(
          r'(\.length|~/|\.ceil\(|\.floor\(|\.round\()',
        ),
      }, 'it never carries');
    });

    test('a search results layout knows no data, no network, no clock '
        'and no state', () {
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
          r'(?<![A-Za-z])(http|HttpClient|Rest\w*|Firestore|Firebase|'
          r'Socket|WebSocket|Grpc|Future|Stream|async|await)(?![A-Za-z])',
        ),
        'a clock of its own': RegExp(
          r'(?<![A-Za-z])(DateTime|Timer|Stopwatch|Duration)(?![A-Za-z])',
        ),
        'a state of the results': RegExp(
          r'(?<![A-Za-z])(loading|refreshing|error|success|offline|'
          r'processing|waiting|empty\w+)(?![A-Za-z])',
        ),
        'a memory of its own': RegExp(
          r'(?<![A-Za-z])(StatefulWidget|setState|initState|ValueNotifier)'
          r'(?![A-Za-z])',
        ),
        'an untyped value': RegExp(
          r'(?<![A-Za-z])(dynamic|Object\?)(?![A-Za-z])',
        ),
        'an untyped result': RegExp(r'final\s+Widget\?\s'),
        'a serialization': RegExp(r'(?<![A-Za-z])(fromJson|toJson)\s*[(<]'),
      }, 'it never carries');
    });

    test('a search results layout builds no framework widget, runs no '
        'machinery, measures nothing and navigates nowhere', () {
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
        'a machinery of motion or of scroll': RegExp(
          r'(?<![A-Za-z])(ScrollController|AnimationController|Ticker)'
          r'(?![A-Za-z])',
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

    test('one search results layout exists in the whole product, it '
        'extends the collected foundation, and it declares nothing '
        'else', () {
      final declarations = <String>[];
      for (final file in dartFilesOf('lib')) {
        if (RegExp(
          r'class\s+MentoraSearchResultsLayout(?![A-Za-z])',
        ).hasMatch(file.readAsStringSync())) {
          declarations.add(file.path.replaceAll(r'\', '/'));
        }
      }
      expect(declarations, hasLength(1));
      expect(declarations.single, contains('layout/search_results_layout/'));

      final source = codeOf(File(declarations.single));
      expect(
        RegExp(
          r'extends\s+MentoraCollectedLayout(?![A-Za-z])',
        ).hasMatch(source),
        isTrue,
      );
      // The shape declares no machinery of its own — and it cannot
      // even name the loom the foundation is woven on.
      expect(source.contains('BuildContext'), isFalse);
      for (final owned in const [
        r'Widget\s+build\(',
        r'surfaceOf\(',
        r'void\s+verify\w*\(',
        r'throw\s',
        r'final\s+[\w<>?, ]+\s+\w+\s*;',
        r'enum\s+\w+',
      ]) {
        expect(RegExp(owned).hasMatch(source), isFalse, reason: owned);
      }
      // The words of the results are aliases over the one holder.
      expect(
        RegExp(
          r'String\s+get\s+searchResultsId\s*=>\s*collectionId;',
        ).hasMatch(source),
        isTrue,
      );
      expect(
        RegExp(
          r'String\s+get\s+searchResultsSemanticLabel\s*=>\s*'
          r'collectionSemanticLabel;',
        ).hasMatch(source),
        isTrue,
      );
      expect(
        RegExp(
          r'List<MentoraIdentifiedContent>\s+get\s+results\s*=>\s*contents;',
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
      // It reaches exactly the foundation, and nothing else: the three
      // files a pure consumer needs, and not one more.
      final imports = source
          .split('\n')
          .where((line) => line.trimLeft().startsWith('import '))
          .map((line) => line.trim())
          .toList();
      expect(imports, [
        "import '../foundation/mentora_collected_layout.dart';",
        "import '../foundation/mentora_layout_kind.dart';",
        "import '../foundation/mentora_layout_style.dart';",
      ]);
    });

    test('the collected foundation has exactly four consumers — list, '
        'catalog, timeline and search results — and no pair of them '
        'duplicates anything', () {
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
      expect(shapes, hasLength(4));
      expect(shapes.map((path) => path.split('/layout/').last).toSet(), {
        'list_layout/mentora_list_layout.dart',
        'catalog_layout/mentora_catalog_layout.dart',
        'timeline_layout/mentora_timeline_layout.dart',
        'search_results_layout/mentora_search_results_layout.dart',
      });

      // The machinery exists once — in the foundation they extend.
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
      expect(
        RegExp(r'MentoraLayoutSurface\.collection\(').hasMatch(foundation),
        isTrue,
      );
    });

    test('the living catalogue presents the search results layout', () {
      final gallery = File(
        'lib/foundation/playground/playground_galleries.dart',
      ).readAsStringSync();
      final mounted = File(
        'lib/foundation/playground/playground_app.dart',
      ).readAsStringSync();

      expect(gallery.contains('layout/search_results_layout/'), isTrue);
      expect(gallery.contains('class SearchResultsLayoutGallery'), isTrue);
      expect(mounted.contains('SearchResultsLayoutGallery('), isTrue);
    });
  });
}
