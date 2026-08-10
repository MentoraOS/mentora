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
import 'package:mentora/foundation/design_kit/layout/catalog_layout/mentora_catalog_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_collected_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_context.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_kind.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_style.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_page_like_layout.dart';
import 'package:mentora/foundation/design_kit/layout/list_layout/mentora_list_layout.dart';
import 'package:mentora/foundation/design_kit/layout/timeline_layout/mentora_timeline_layout.dart';
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
/// touched by the layout that presents it. The words carry a date and
/// an hour on purpose: the layout must hand them on without
/// understanding them.
Widget _words(String id) => MentoraText(
  'Moment $id — 12 mars 2026, 14 h 05',
  key: Key('moment-$id'),
  role: MentoraTextRole.body,
);

MentoraIdentifiedContent _moment(String id, {Widget? content}) =>
    MentoraIdentifiedContent(id: id, content: content ?? _words(id));

/// The identities are words of the product, never ranks and never
/// instants: what they suggest chronologically is deliberately NOT the
/// order they are announced in.
const List<String> _identities = ['paiement', 'inscription', 'premier-appel'];

const MentoraLayoutContext _frame = MentoraLayoutContext(
  semanticLabel: 'Contexte de travail',
  navigation: MentoraNavigationAnnouncement(destinationId: 'home'),
);

MentoraTimelineLayout _layout({
  MentoraLayoutContext frame = _frame,
  String pageSemanticLabel = 'Page courante',
  String timelineId = 'parcours',
  String timelineSemanticLabel = 'Le parcours',
  List<MentoraIdentifiedContent>? moments,
  MentoraAppBar? place,
  List<MentoraButton> acts = const [],
}) {
  return MentoraTimelineLayout(
    frame: frame,
    pageSemanticLabel: pageSemanticLabel,
    timelineId: timelineId,
    timelineSemanticLabel: timelineSemanticLabel,
    moments: moments ?? [for (final id in _identities) _moment(id)],
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

Finder _timeline() => find.byKey(const Key('list-parcours'));

Finder _momentOf(String id) => find.byKey(Key('list-item-$id'));

void main() {
  group('MentoraTimelineLayout — a succession of moments, already '
      'ordered', () {
    testWidgets('it is a specialization of the one foundation, through '
        'the collected foundation, and the registry knows its shape', (
      tester,
    ) async {
      expect(_layout(), isA<MentoraLayout>());
      expect(_layout(), isA<MentoraPageLikeLayout>());
      expect(_layout(), isA<MentoraCollectedLayout>());
      expect(_layout().kind, MentoraLayoutKind.timeline);

      await _pump(tester, _layout());
      expect(find.byKey(const Key('layout-timeline')), findsOneWidget);
      expect(find.byType(MentoraWorkspace), findsOneWidget);
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
    });

    test('the words of a succession of moments are aliases over the one '
        'holder: there is no second field anywhere', () {
      final moments = [for (final id in _identities) _moment(id)];
      final layout = _layout(moments: moments);

      expect(layout.timelineId, 'parcours');
      expect(layout.timelineId, layout.collectionId);
      expect(layout.timelineSemanticLabel, layout.collectionSemanticLabel);
      expect(layout.moments, same(moments));
      expect(layout.moments, same(layout.contents));
    });

    test('the collection is never transformed: what was announced is '
        'the very object held, and the very object served', () {
      final moments = [for (final id in _identities) _moment(id)];
      final layout = _layout(moments: moments);

      // The SAME list instance, end to end: not a copy, not a view,
      // not a rearrangement — the layout never even touched it.
      expect(layout.contents, same(moments));
      expect(layout.moments, same(moments));
      for (var rank = 0; rank < moments.length; rank += 1) {
        expect(identical(layout.moments[rank], moments[rank]), isTrue);
      }
    });

    test('it is the third pure consumer of the collected foundation: '
        'list, catalog and timeline speak the very same machinery', () {
      final units = [for (final id in _identities) _moment(id)];
      final list = MentoraListLayout(
        frame: _frame,
        pageSemanticLabel: 'Page courante',
        listId: 'transactions',
        listSemanticLabel: 'Les transactions',
        items: units,
      );
      final catalog = MentoraCatalogLayout(
        frame: _frame,
        pageSemanticLabel: 'Page courante',
        catalogId: 'offre',
        catalogSemanticLabel: 'L’offre',
        entries: units,
      );
      final timeline = _layout(moments: units);

      for (final shape in [list, catalog, timeline]) {
        expect(shape, isA<MentoraCollectedLayout>());
      }
      expect(list.items, same(list.contents));
      expect(catalog.entries, same(catalog.contents));
      expect(timeline.moments, same(timeline.contents));
    });

    testWidgets('it asks the assembly for the single disposition: it '
        'arranges nothing itself', (tester) async {
      await _pump(tester, _layout());

      expect(_timeline(), findsOneWidget);
      for (final id in _identities) {
        expect(_momentOf(id), findsOneWidget, reason: id);
      }
    });

    testWidgets('a moment is an IDENTITY: the product refers to it by '
        'what it is, never by where it stands and never by an instant', (
      tester,
    ) async {
      await _pump(tester, _layout());

      expect(_momentOf('inscription'), findsOneWidget);
      expect(find.byKey(const Key('list-item-0')), findsNothing);
      expect(find.byKey(const Key('list-item-ailleurs')), findsNothing);
    });

    testWidgets('the order announced is the order read: no chronology '
        'is computed, and nothing is rearranged', (tester) async {
      // The words of every moment carry the SAME date and hour: any
      // shape that computed a chronology would have nothing to order
      // by — the announcement is the only order there is.
      await _pump(tester, _layout());

      var previous = tester.getRect(_momentOf(_identities.first)).top;
      for (final id in _identities.skip(1)) {
        final top = tester.getRect(_momentOf(id)).top;
        expect(top, greaterThan(previous), reason: id);
        previous = top;
      }
    });

    testWidgets('announced the other way, it is expressed the other '
        'way: the product owns the order, wherever it points', (tester) async {
      await _pump(
        tester,
        _layout(moments: [for (final id in _identities.reversed) _moment(id)]),
      );

      var previous = tester.getRect(_momentOf(_identities.last)).top;
      for (final id in _identities.reversed.skip(1)) {
        final top = tester.getRect(_momentOf(id)).top;
        expect(top, greaterThan(previous), reason: id);
        previous = top;
      }
    });

    testWidgets('every moment announced is expressed: nothing is '
        'grouped, nothing is paged, nothing is held back', (tester) async {
      await _pump(tester, _layout());

      for (final id in _identities) {
        expect(_momentOf(id), findsOneWidget, reason: id);
        expect(find.byKey(Key('moment-$id')), findsOneWidget, reason: id);
      }
      expect(find.byType(RefreshIndicator), findsNothing);
      expect(find.byType(PageView), findsNothing);
    });

    testWidgets('a moment is handed on strictly intact: the words carry '
        'a date and an hour, and the layout never reads them', (tester) async {
      await _pump(tester, _layout());

      // What was written is exactly what stands — no instant
      // understood, no zone applied, no interpretation of any kind.
      for (final id in _identities) {
        expect(find.text('Moment $id — 12 mars 2026, 14 h 05'), findsOneWidget);
        expect(
          tester.getTopLeft(find.byKey(Key('moment-$id'))),
          tester.getTopLeft(_momentOf(id)),
          reason: id,
        );
      }
    });

    testWidgets('it adds no room between the moments', (tester) async {
      await _pump(tester, _layout());

      var previous = tester.getRect(_momentOf(_identities.first));
      for (final id in _identities.skip(1)) {
        final rect = tester.getRect(_momentOf(id));
        expect(rect.top, previous.bottom, reason: id);
        previous = rect;
      }
      expect(layoutContentGap, 0);
    });

    testWidgets('it creates no scroll view and no padding of its own', (
      tester,
    ) async {
      await _pump(tester, _layout(moments: [_moment('inscription')]));

      expect(find.byType(Scrollable), findsNothing);
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.byType(ListView), findsNothing);
      expect(find.byType(GridView), findsNothing);

      final page = tester.getRect(find.byType(MentoraPageScaffold));
      final timeline = tester.getRect(_timeline());
      expect(timeline.left, page.left);
      expect(timeline.width, page.width);
      expect(timeline.top, page.top);
    });

    testWidgets('the components stay the owners of what a moment is '
        'made of', (tester) async {
      await _pump(
        tester,
        _layout(
          moments: [
            _moment(
              'inscription',
              content: const MentoraCard(
                key: Key('moment-inscription'),
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

    testWidgets('the same shape carries any succession: it represents '
        'no domain of the company', (tester) async {
      for (final subject in const ['premier parcours', 'second parcours']) {
        await _pump(
          tester,
          _layout(
            timelineSemanticLabel: subject,
            moments: [
              _moment(
                'inscription',
                content: MentoraText(subject, role: MentoraTextRole.body),
              ),
            ],
          ),
        );

        expect(tester.takeException(), isNull, reason: subject);
        expect(find.text(subject), findsOneWidget);
      }
    });

    testWidgets('only the timeline is announced: every moment keeps its '
        'own voice', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        _layout(
          moments: [
            _moment(
              'inscription',
              content: const MentoraListTile(
                key: Key('moment-inscription'),
                headline: 'Awa Diallo',
                semanticLabel: 'Awa Diallo',
              ),
            ),
          ],
        ),
      );

      expect(tester.getSemantics(_timeline()).label, 'Le parcours');
      expect(find.bySemanticsLabel('Le parcours'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Awa Diallo')), findsWidgets);
      handle.dispose();
    });

    testWidgets('a moment keeps its own rect: the key holder adds no '
        'geometry of its own', (tester) async {
      await _pump(tester, _layout(moments: [_moment('inscription')]));

      expect(
        tester.getRect(find.byKey(const Key('moment-inscription'))),
        tester.getRect(_momentOf('inscription')),
      );
    });

    testWidgets('the timeline travels as one focus group', (tester) async {
      await _pump(tester, _layout());

      expect(
        find.descendant(
          of: _timeline(),
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
          moments: [
            _moment(
              'inscription',
              content: Focus(focusNode: inside, child: _words('inscription')),
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
          moments: [_moment('inscription')],
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

    testWidgets('a timeline layout without a contract refuses to build — '
        'fail closed, ten times over', (tester) async {
      Future<void> refuses(Widget layout) async {
        await _pump(tester, layout);
        expect(tester.takeException(), isStateError);
      }

      // 1. A timeline without an identity is not one.
      await refuses(_layout(timelineId: ''));
      // 2. A timeline without a name is not a landmark.
      await refuses(_layout(timelineSemanticLabel: ''));
      // 3. A timeline with no moment presents nothing.
      await refuses(_layout(moments: const []));
      // 4. A moment without an identity is not a moment.
      await refuses(_layout(moments: [_moment('')]));
      // 5. And it is refused wherever it stands: the whole collection
      //    is walked, never its head alone.
      await refuses(_layout(moments: [_moment('inscription'), _moment('')]));
      // 6. Two moments never share one identity.
      await refuses(
        _layout(moments: [_moment('inscription'), _moment('inscription')]),
      );
      // 7. And identity is a set, not a comparison with the neighbour.
      await refuses(
        _layout(
          moments: [
            _moment('inscription'),
            _moment('paiement'),
            _moment('inscription'),
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

    testWidgets('a timeline layout is a whole screen: it never carries '
        'a second one — fail closed', (tester) async {
      final refusals = <Object>[];
      final reporter = FlutterError.onError;
      FlutterError.onError = (details) => refusals.add(details.exception);
      await _pump(
        tester,
        _layout(moments: [_moment('inscription', content: _layout())]),
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
        expect(_timeline(), findsOneWidget);
      }
    });

    testWidgets('it holds at every font scale', (tester) async {
      for (final scale in FontScalePreference.values) {
        await _pump(
          tester,
          _layout(moments: [_moment('inscription')]),
          appearance: AppearanceState(fontScale: scale),
        );
        expect(tester.takeException(), isNull, reason: scale.name);
        expect(_timeline(), findsOneWidget);
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

    testWidgets('it holds in both reading directions, and the timeline '
        'still takes the whole width', (tester) async {
      for (final direction in TextDirection.values) {
        await _pump(tester, _layout(), direction: direction);
        expect(tester.takeException(), isNull, reason: direction.name);
        expect(
          tester.getRect(_timeline()).width,
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
    Iterable<File> timelineFiles() => [
      ...dartFilesOf('lib/foundation/design_kit/layout/timeline_layout'),
      File(
        'lib/foundation/design_kit/layout/foundation/'
        'mentora_collected_layout.dart',
      ),
    ];

    void refuse(Map<String, RegExp> forbidden, String because) {
      final files = timelineFiles().toList();
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

    test('a timeline layout knows nothing of time', () {
      // Structural, never lexical: a concept USED carries a
      // constructor, a member or a named argument behind it — the
      // prose may name what the code may not carry.
      refuse({
        'a temporal type': RegExp(
          r'(?<![A-Za-z])(DateTime|TimeOfDay|TimeZone|Locale|Calendar|'
          r'Duration|Clock|Stopwatch|Timer|History)(?![A-Za-z])',
        ),
        'a temporal member': RegExp(
          r'(?<![A-Za-z])(date|time|hour|minute|second|month|year|week|'
          r'day|timestamp|epoch|instant|elapsed)\s*[:.(=]',
        ),
        'a chronology of its own': RegExp(
          r'\.(isBefore|isAfter|difference|toUtc|toLocal|'
          r'millisecondsSinceEpoch|compareTo)\b',
        ),
        'a comparison machinery': RegExp(
          r'(?<![A-Za-z])(Comparable|Comparator)(?![A-Za-z])',
        ),
      }, 'it never carries');
    });

    test('a timeline layout selects nothing, rearranges nothing, groups '
        'nothing and pages nothing', () {
      refuse({
        'a selection or an order of its own': RegExp(
          r'\.(where|firstWhere|lastWhere|singleWhere|sort|sorted|reversed|'
          r'reduce|fold|skip|take|expand|removeWhere|retainWhere)\s*[(.]',
        ),
        'a grouping': RegExp(
          r'(?<![A-Za-z])(groupBy|grouped|Group\w*)\s*[:.(=<]',
        ),
        'a filter or a search': RegExp(
          r'(?<![A-Za-z])(filter\w*|Filter|search|query)\s*[:.(=<]',
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

    test('a timeline layout knows no data, no network and no state', () {
      refuse({
        'a model': RegExp(
          r'(?<![A-Za-z])(User|Wallet|Expert|Consultation|Invoice|Business|'
          r'Account|Profile|Entity|Model|Repository|Event)(?![a-z])',
        ),
        'a source of data': RegExp(
          r'(?<![A-Za-z])(Provider|Bloc|Cubit|Riverpod|ChangeNotifier|'
          r'StreamBuilder|FutureBuilder)(?![A-Za-z])',
        ),
        'a network or a promise': RegExp(
          r'(?<![A-Za-z])(http|HttpClient|Firestore|WebSocket|Future|Stream|'
          r'async|await)(?![A-Za-z])',
        ),
        'a state of the succession': RegExp(
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
        'an untyped moment': RegExp(r'final\s+Widget\?\s'),
      }, 'it never carries');
    });

    test('a timeline layout builds no framework widget, runs no engine, '
        'measures nothing and navigates nowhere', () {
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
          r'(?<![A-Za-z])(ScrollController|AnimationController|Ticker|'
          r'TimelineEngine)(?![A-Za-z])',
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

    test('one timeline layout exists in the whole product, it extends '
        'the collected foundation, and it declares nothing else', () {
      final declarations = <String>[];
      for (final file in dartFilesOf('lib')) {
        if (RegExp(
          r'class\s+MentoraTimelineLayout(?![A-Za-z])',
        ).hasMatch(file.readAsStringSync())) {
          declarations.add(file.path.replaceAll(r'\', '/'));
        }
      }
      expect(declarations, hasLength(1));
      expect(declarations.single, contains('layout/timeline_layout/'));

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
      // The words of the succession are aliases over the one holder.
      expect(
        RegExp(
          r'String\s+get\s+timelineId\s*=>\s*collectionId;',
        ).hasMatch(source),
        isTrue,
      );
      expect(
        RegExp(
          r'String\s+get\s+timelineSemanticLabel\s*=>\s*'
          r'collectionSemanticLabel;',
        ).hasMatch(source),
        isTrue,
      );
      expect(
        RegExp(
          r'List<MentoraIdentifiedContent>\s+get\s+moments\s*=>\s*contents;',
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

    test('the collected foundation has exactly three consumers — list, '
        'catalog and timeline — and every one of them is pure', () {
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
      expect(shapes, hasLength(3));
      expect(shapes.map((path) => path.split('/layout/').last).toSet(), {
        'list_layout/mentora_list_layout.dart',
        'catalog_layout/mentora_catalog_layout.dart',
        'timeline_layout/mentora_timeline_layout.dart',
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
  });
}
