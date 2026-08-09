import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/bootstrap/design_kit_bootstrap.dart';
import 'package:mentora/foundation/core/di/foundation_services.dart';
import 'package:mentora/foundation/design_kit/accessibility/accessibility_engine.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/components/avatar/mentora_avatar.dart';
import 'package:mentora/foundation/design_kit/components/avatar/mentora_avatar_style.dart';
import 'package:mentora/foundation/design_kit/components/button/mentora_button.dart';
import 'package:mentora/foundation/design_kit/components/button/mentora_button_style.dart';
import 'package:mentora/foundation/design_kit/components/card/mentora_card.dart';
import 'package:mentora/foundation/design_kit/components/card/mentora_card_style.dart';
import 'package:mentora/foundation/design_kit/components/design_kit_scope.dart';
import 'package:mentora/foundation/design_kit/composition/list_tile/mentora_list_tile.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text_role.dart';
import 'package:mentora/foundation/design_kit/layout/feed_layout/mentora_feed_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_context.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_kind.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_style.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_principal_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_zoned_layout.dart';
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
/// touched by the layout that organises the way through it.
Widget _content(String id) => MentoraText(
  'Contenu $id',
  key: Key('zone-$id'),
  role: MentoraTextRole.body,
);

MentoraLayoutZone _zone(String id, {String? semanticLabel, Widget? content}) =>
    MentoraLayoutZone(
      semanticLabel: semanticLabel ?? 'Région $id',
      content: content ?? _content(id),
    );

const MentoraLayoutContext _frame = MentoraLayoutContext(
  semanticLabel: 'Contexte de travail',
  navigation: MentoraNavigationAnnouncement(destinationId: 'home'),
);

MentoraFeedLayout _layout({
  MentoraLayoutContext frame = _frame,
  String pageSemanticLabel = 'Page courante',
  MentoraLayoutZone? feed,
  bool complete = true,
  MentoraLayoutZone? header,
  MentoraLayoutZone? introduction,
  MentoraLayoutZone? supportingContent,
  MentoraLayoutZone? actions,
  MentoraLayoutZone? footer,
  Set<MentoraPrincipalRegion> without = const {},
  MentoraAppBar? place,
  List<MentoraButton> acts = const [],
}) {
  MentoraLayoutZone? optional(
    MentoraPrincipalRegion region,
    MentoraLayoutZone? given,
  ) {
    if (given != null) return given;
    if (without.contains(region)) return null;
    return complete ? _zone(region.name) : null;
  }

  return MentoraFeedLayout(
    frame: frame,
    pageSemanticLabel: pageSemanticLabel,
    place: place,
    acts: acts,
    header: optional(MentoraPrincipalRegion.header, header),
    introduction: optional(MentoraPrincipalRegion.introduction, introduction),
    feed: feed ?? _zone('principal'),
    supportingContent: optional(
      MentoraPrincipalRegion.supportingContent,
      supportingContent,
    ),
    actions: optional(MentoraPrincipalRegion.actions, actions),
    footer: optional(MentoraPrincipalRegion.footer, footer),
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

Finder _regionOf(MentoraPrincipalRegion region) =>
    find.byKey(Key('content-region-${region.name}'));

void main() {
  group('MentoraFeedLayout — a person going through a succession', () {
    testWidgets('it is a specialization of the one foundation, through '
        'the principal foundation, and the registry knows its shape', (
      tester,
    ) async {
      expect(_layout(), isA<MentoraLayout>());
      expect(_layout(), isA<MentoraZonedLayout<MentoraPrincipalRegion>>());
      expect(_layout(), isA<MentoraPrincipalLayout>());
      expect(_layout().kind, MentoraLayoutKind.feed);

      await _pump(tester, _layout());
      expect(find.byKey(const Key('layout-feed')), findsOneWidget);
      expect(find.byType(MentoraWorkspace), findsOneWidget);
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
    });

    test('the flow is required by the TYPE: a feed about nothing never '
        'compiles, and the word is an alias of the one matter', () {
      final flow = _zone('principal');
      final layout = _layout(feed: flow);

      expect(layout.feed, same(flow));
      expect(layout.principal, same(flow));
      // The vocabulary it speaks is the shared one, and it declares
      // none of its own.
      expect(layout.vocabulary, MentoraPrincipalRegion.values);
      expect(layout.zones[MentoraPrincipalRegion.principal], same(flow));
    });

    testWidgets('it asks the assembly for the single disposition: it '
        'arranges nothing itself', (tester) async {
      await _pump(tester, _layout());

      expect(find.byKey(const Key('content-regions')), findsOneWidget);
      for (final region in MentoraPrincipalRegion.values) {
        expect(_regionOf(region), findsOneWidget, reason: region.name);
      }
    });

    testWidgets('the official order is the order read, and it is the '
        'vocabulary itself', (tester) async {
      await _pump(tester, _layout());

      var previous = tester
          .getRect(_regionOf(MentoraPrincipalRegion.header))
          .top;
      for (final region in MentoraPrincipalRegion.values.skip(1)) {
        final top = tester.getRect(_regionOf(region)).top;
        expect(top, greaterThan(previous), reason: region.name);
        previous = top;
      }
      expect(
        MentoraPrincipalRegion.values.map((region) => region.name).toList(),
        [
          'header',
          'introduction',
          'principal',
          'supportingContent',
          'actions',
          'footer',
        ],
      );
    });

    testWidgets('the flow is the only region a feed cannot do without', (
      tester,
    ) async {
      await _pump(tester, _layout(complete: false));

      expect(_regionOf(MentoraPrincipalRegion.principal), findsOneWidget);
      for (final region in MentoraPrincipalRegion.values) {
        if (region == MentoraPrincipalRegion.principal) continue;
        expect(_regionOf(region), findsNothing, reason: region.name);
      }
      // What was not given is not there at all, and what remains still
      // starts at the very edge of the page.
      expect(
        tester.getTopLeft(_regionOf(MentoraPrincipalRegion.principal)),
        tester.getTopLeft(find.byType(MentoraPageScaffold)),
      );
    });

    testWidgets('every other region is optional, one by one', (tester) async {
      for (final region in MentoraPrincipalRegion.values) {
        if (region == MentoraPrincipalRegion.principal) continue;
        await _pump(tester, _layout(without: {region}));

        expect(tester.takeException(), isNull, reason: region.name);
        expect(_regionOf(region), findsNothing, reason: region.name);
        for (final other in MentoraPrincipalRegion.values) {
          if (other == region) continue;
          expect(_regionOf(other), findsOneWidget, reason: other.name);
        }
      }
    });

    testWidgets('the identity of a region is the official region: a '
        'product never names one', (tester) async {
      await _pump(tester, _layout());

      expect(find.byKey(const Key('content-region-principal')), findsOneWidget);
      expect(find.byKey(const Key('content-region-feed')), findsNothing);
      expect(find.byKey(const Key('content-region-ailleurs')), findsNothing);
    });

    testWidgets('the content of every region is handed on strictly '
        'intact', (tester) async {
      await _pump(tester, _layout());

      for (final region in MentoraPrincipalRegion.values) {
        expect(
          tester.getTopLeft(find.byKey(Key('zone-${region.name}'))),
          tester.getTopLeft(_regionOf(region)),
          reason: region.name,
        );
      }
    });

    testWidgets('it adds no room between the regions of the page', (
      tester,
    ) async {
      await _pump(tester, _layout());

      var previous = tester.getRect(_regionOf(MentoraPrincipalRegion.header));
      for (final region in MentoraPrincipalRegion.values.skip(1)) {
        final rect = tester.getRect(_regionOf(region));
        expect(rect.top, previous.bottom, reason: region.name);
        previous = rect;
      }
      expect(layoutContentGap, 0);
    });

    testWidgets('it creates no scroll view and no padding of its own', (
      tester,
    ) async {
      await _pump(tester, _layout(complete: false));

      expect(find.byType(Scrollable), findsNothing);
      expect(find.byType(SingleChildScrollView), findsNothing);

      final page = tester.getRect(find.byType(MentoraPageScaffold));
      final flow = tester.getRect(_regionOf(MentoraPrincipalRegion.principal));
      expect(flow.left, page.left);
      expect(flow.width, page.width);
      expect(flow.top, page.top);
    });

    testWidgets('the flow is handed on whole: every element announced '
        'stands, in the announced order, and none is virtualized away', (
      tester,
    ) async {
      const elements = ['premier', 'second', 'troisieme'];
      await _pump(
        tester,
        _layout(
          complete: false,
          feed: _zone(
            'principal',
            content: const Column(
              key: Key('zone-principal'),
              mainAxisSize: MainAxisSize.min,
              children: [
                MentoraListTile(key: Key('element-premier'), headline: 'Un'),
                MentoraListTile(key: Key('element-second'), headline: 'Deux'),
                MentoraListTile(
                  key: Key('element-troisieme'),
                  headline: 'Trois',
                ),
              ],
            ),
          ),
        ),
      );

      for (final element in elements) {
        expect(
          find.byKey(Key('element-$element')),
          findsOneWidget,
          reason: element,
        );
      }
      var previous = tester.getRect(find.byKey(const Key('element-premier')));
      for (final element in elements.skip(1)) {
        final rect = tester.getRect(find.byKey(Key('element-$element')));
        expect(
          rect.top,
          greaterThanOrEqualTo(previous.bottom),
          reason: element,
        );
        previous = rect;
      }
    });

    testWidgets('nothing pages, nothing loads more, nothing refreshes: '
        'the layout made no way through anything', (tester) async {
      await _pump(
        tester,
        _layout(
          complete: false,
          feed: _zone(
            'principal',
            content: const Column(
              key: Key('zone-principal'),
              mainAxisSize: MainAxisSize.min,
              children: [
                MentoraListTile(key: Key('element-premier'), headline: 'Un'),
                MentoraListTile(key: Key('element-second'), headline: 'Deux'),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Scrollable), findsNothing);
      expect(find.byType(RefreshIndicator), findsNothing);
      expect(find.byType(PageView), findsNothing);
      expect(find.byType(AnimatedList), findsNothing);
      // Going down the page changes nothing: there is no way through
      // to trigger, because the layout never made one.
      await tester.drag(
        find.byKey(const Key('content-region-principal')),
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('element-second')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a feed is a whole screen: it never carries a second '
        'one — fail closed', (tester) async {
      // A refused screen brings down what was going to be measured
      // inside it, so every failure is collected rather than the first
      // one alone: the refusal must be THE cause, not a consequence.
      final refusals = <Object>[];
      final reporter = FlutterError.onError;
      FlutterError.onError = (details) => refusals.add(details.exception);
      await _pump(
        tester,
        _layout(
          complete: false,
          feed: _zone(
            'principal',
            content: const MentoraListLayout(
              key: Key('zone-principal'),
              frame: _frame,
              pageSemanticLabel: 'Page courante',
              listId: 'succession',
              listSemanticLabel: 'La succession',
              items: [
                MentoraIdentifiedContent(
                  id: 'premier',
                  content: SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      );
      FlutterError.onError = reporter;

      expect(refusals.whereType<StateError>(), isNotEmpty);
      expect(
        refusals.whereType<StateError>().first.message,
        contains('never placed inside another'),
      );
    });

    testWidgets('the components stay the owners of what is in the flow', (
      tester,
    ) async {
      await _pump(
        tester,
        _layout(
          complete: false,
          feed: _zone(
            'principal',
            content: const MentoraCard(
              key: Key('zone-principal'),
              variant: MentoraCardVariant.surface,
              child: MentoraListTile(
                headline: 'Awa Diallo',
                semanticLabel: 'Awa Diallo',
                leading: MentoraAvatar(
                  identity: MentoraAvatarIdentity.initials,
                  name: 'Awa Diallo',
                  initials: 'AD',
                ),
              ),
            ),
          ),
          actions: _zone(
            'actions',
            content: MentoraButton(
              key: const Key('zone-actions'),
              label: 'Continuer',
              onPressed: () {},
              size: MentoraButtonSize.small,
            ),
          ),
        ),
      );

      expect(find.byType(MentoraCard), findsOneWidget);
      expect(find.byType(MentoraListTile), findsOneWidget);
      expect(find.byType(MentoraAvatar), findsOneWidget);
      expect(find.byType(MentoraButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the same shape carries any succession: it represents no '
        'domain of the company', (tester) async {
      for (final subject in const ['premier flux', 'second flux']) {
        await _pump(
          tester,
          _layout(
            complete: false,
            feed: _zone(
              'principal',
              semanticLabel: subject,
              content: MentoraText(subject, role: MentoraTextRole.body),
            ),
          ),
        );

        expect(tester.takeException(), isNull, reason: subject);
        expect(find.text(subject), findsOneWidget);
      }
    });

    testWidgets('a feed layout without a contract refuses to build — '
        'fail closed', (tester) async {
      Future<void> refuses(Widget layout) async {
        await _pump(tester, layout);
        expect(tester.takeException(), isStateError);
      }

      // A region without a name, wherever it stands.
      await refuses(_layout(feed: _zone('principal', semanticLabel: '')));
      await refuses(_layout(header: _zone('header', semanticLabel: '')));
      await refuses(_layout(footer: _zone('footer', semanticLabel: '')));
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

    testWidgets('every region is a landmark, announced exactly once', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _layout());

      for (final region in MentoraPrincipalRegion.values) {
        expect(
          tester.getSemantics(_regionOf(region)).label,
          'Région ${region.name}',
          reason: region.name,
        );
        expect(
          find.bySemanticsLabel('Région ${region.name}'),
          findsOneWidget,
          reason: region.name,
        );
      }
      handle.dispose();
    });

    testWidgets('the components keep their own announcements', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        _layout(
          complete: false,
          feed: _zone(
            'principal',
            semanticLabel: 'Le flux',
            content: const MentoraListTile(
              key: Key('zone-principal'),
              headline: 'Awa Diallo',
              semanticLabel: 'Awa Diallo',
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Le flux'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Awa Diallo')), findsWidgets);
      handle.dispose();
    });

    testWidgets('every region travels as its own focus group', (tester) async {
      await _pump(tester, _layout());

      for (final region in MentoraPrincipalRegion.values) {
        expect(
          find.descendant(
            of: _regionOf(region),
            matching: find.byType(FocusTraversalGroup),
          ),
          findsOneWidget,
          reason: region.name,
        );
      }
    });

    testWidgets('the layout never takes the focus, and never gives it '
        'back to itself', (tester) async {
      final inside = FocusNode(debugLabel: 'inside');
      addTearDown(inside.dispose);

      await _pump(
        tester,
        _layout(
          complete: false,
          feed: _zone(
            'principal',
            content: Focus(focusNode: inside, child: _content('principal')),
          ),
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
          complete: false,
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

    testWidgets('it holds in the four themes', (tester) async {
      for (final variant in ThemeVariantId.values) {
        await _pump(tester, _layout(), variant: variant);
        expect(tester.takeException(), isNull, reason: variant.name);
        expect(_regionOf(MentoraPrincipalRegion.principal), findsOneWidget);
      }
    });

    testWidgets('it holds at every font scale', (tester) async {
      for (final scale in FontScalePreference.values) {
        await _pump(
          tester,
          _layout(complete: false),
          appearance: AppearanceState(fontScale: scale),
        );
        expect(tester.takeException(), isNull, reason: scale.name);
        expect(_regionOf(MentoraPrincipalRegion.principal), findsOneWidget);
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

    testWidgets('it holds in both reading directions, and a region still '
        'takes the whole width', (tester) async {
      for (final direction in TextDirection.values) {
        await _pump(tester, _layout(), direction: direction);
        expect(tester.takeException(), isNull, reason: direction.name);
        expect(
          tester.getRect(_regionOf(MentoraPrincipalRegion.principal)).width,
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

    /// The shape AND the foundations it is built on: the machinery
    /// lives there, so the scans follow it — a rule never stays behind
    /// the code it opposes.
    Iterable<File> feedFiles() => [
      ...dartFilesOf('lib/foundation/design_kit/layout/feed_layout'),
      File(
        'lib/foundation/design_kit/layout/foundation/'
        'mentora_principal_layout.dart',
      ),
      File(
        'lib/foundation/design_kit/layout/foundation/mentora_zoned_layout.dart',
      ),
    ];

    void refuse(Map<String, RegExp> forbidden, String because) {
      final files = feedFiles().toList();
      expect(files, isNotEmpty);
      for (final file in files) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason: '${file.path}: $because ${entry.key}',
          );
        }
      }
    }

    test('a feed layout knows no data of the flow', () {
      // Structural, never lexical: a type USED carries a constructor, a
      // member or a type argument behind it — the prose may name what
      // the code may not carry.
      refuse({
        'an element of a flow': RegExp(
          r'(?<![A-Za-z])(Post|Comment|Like|Notification|Message|Article|'
          r'FeedItem|Activity|History|Publication|Conversation|Reaction|'
          r'Story|Timeline)(?![a-z])',
        ),
        'a model': RegExp(
          r'(?<![A-Za-z])(User|Product|Wallet|Expert|Account|Profile|'
          r'Entity|Model)(?![a-z])',
        ),
        'a serialization': RegExp(r'(?<![A-Za-z])(fromJson|toJson)\s*[(<]'),
      }, 'it never carries');
    });

    test('a feed layout knows no logic: nothing is calculated, sorted, '
        'filtered, grouped, paged or transformed', () {
      refuse({
        'a selection or an order of its own': RegExp(
          r'\.(where|firstWhere|lastWhere|singleWhere|sort|sorted|reversed|'
          r'reduce|fold|skip|take|expand|groupBy)\s*[(.]',
        ),
        // Structural: a page is an official word of this layer, so a
        // paging is recognised by the way code USES one, never by a
        // word appearing in a sentence.
        'a paging': RegExp(
          r'(?<![A-Za-z])(pageSize|pageToken|offset|cursor|limit|hasMore|'
          r'loadMore|nextPage|paginat\w+)\s*[:.(=]',
        ),
        'a virtualization': RegExp(
          r'(?<![A-Za-z])(itemBuilder|itemCount|itemExtent|separatorBuilder|'
          r'prototypeItem|cacheExtent|addAutomaticKeepAlives)(?![A-Za-z])',
        ),
        'an arithmetic': RegExp(r'(~/|\.ceil\(|\.floor\(|\.round\()'),
      }, 'it never carries');
    });

    test('a feed layout knows no network and no source of data', () {
      refuse({
        'a network': RegExp(
          r'(?<![A-Za-z])(http|HttpClient|Firestore|Dio|WebSocket)'
          r'(?![A-Za-z])',
        ),
        'a source of data': RegExp(
          r'(?<![A-Za-z])(Repository|Provider|Bloc|Cubit|Riverpod|'
          r'ChangeNotifier|StreamBuilder|FutureBuilder)(?![A-Za-z])',
        ),
        'a promise': RegExp(
          r'(?<![A-Za-z])(Future|Stream|async|await)(?![A-Za-z])',
        ),
      }, 'it never carries');
    });

    test('a feed layout knows no state of the flow', () {
      refuse({
        'a state of the work': RegExp(
          r'(?<![A-Za-z])(loading|refreshing|offline|syncing|error|success|'
          r'processing|waiting|isEmpty\w|isLoaded)(?![A-Za-z])',
        ),
        'an untyped value': RegExp(
          r'(?<![A-Za-z])(dynamic|Object\?)(?![A-Za-z])',
        ),
        'an untyped zone': RegExp(r'final\s+Widget\?\s'),
      }, 'it never carries');
    });

    test('a feed layout builds no way through anything, measures '
        'nothing and navigates nowhere', () {
      refuse({
        'a scroll view or a collection': RegExp(
          r'(?<![A-Za-z])(Scrollable|ScrollView|SingleChildScrollView|'
          r'CustomScrollView|ListView|GridView|Sliver\w*|PageView|'
          r'AnimatedList|ReorderableListView|RefreshIndicator|Wrap|Flow)'
          r'\s*[(.<]',
        ),
        'a structure of the framework': RegExp(
          r'(?<![A-Za-z])(Scaffold|AppBar|Drawer|NavigationBar|'
          r'NavigationRail|TabBar|Form|FormField)\s*[(.<]',
        ),
        'a room of its own': RegExp(
          r'(?<![A-Za-z])(Padding|SafeArea|Expanded|Flexible|Spacer)'
          r'\s*[(.<]',
        ),
        'a decorative box': RegExp(
          r'(?<![A-Za-z])(Container|DecoratedBox|ColoredBox)\(',
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
        'an ambient theme': RegExp(r'Theme\.of\('),
        'a coded colour': RegExp(r'(Color\(0x|Colors\.)'),
        'a coded extent': RegExp(r'(width|height|spacing|runSpacing):\s*[0-9]'),
        'a coded duration': RegExp(r'Duration\((milliseconds|seconds)'),
      }, 'it never carries');
    });

    test('one feed layout exists in the whole product, it extends the '
        'principal foundation, and it declares nothing else', () {
      final declarations = <String>[];
      for (final file in dartFilesOf('lib')) {
        if (RegExp(
          r'class\s+MentoraFeedLayout(?![A-Za-z])',
        ).hasMatch(file.readAsStringSync())) {
          declarations.add(file.path.replaceAll(r'\', '/'));
        }
      }
      expect(declarations, hasLength(1));
      expect(declarations.single, contains('layout/feed_layout/'));

      final source = File(declarations.single).readAsStringSync();
      expect(
        RegExp(
          r'extends\s+MentoraPrincipalLayout(?![A-Za-z])',
        ).hasMatch(source),
        isTrue,
      );
      // It owns no region, no order, no identity, no surface and no
      // refusal: it owns its official kind, and the word it calls its
      // matter by — which is an alias, never a second field.
      for (final owned in const [
        r'Widget\s+build\(',
        r'surfaceOf\(',
        r'void\s+verify\(',
        r'get\s+zones(?![A-Za-z])',
        r'get\s+vocabulary(?![A-Za-z])',
        r'final\s+MentoraLayoutZone',
        r'enum\s+\w+',
      ]) {
        expect(RegExp(owned).hasMatch(source), isFalse, reason: owned);
      }
      for (final built in const [
        'MentoraWorkspace(',
        'MentoraPageScaffold(',
        'MentoraListLayout(',
        'MentoraCard(',
        'MentoraListTile(',
        'MentoraAvatar(',
        'MentoraBadge(',
        'MentoraButton(',
        'Column(',
        'Semantics(',
        'FocusTraversalGroup(',
      ]) {
        expect(source.contains(built), isFalse, reason: built);
      }
    });

    test('a shape built around one matter is its kind and one word: no '
        'second vocabulary, and no second holder of the matter', () {
      final shapes = <String>[];
      for (final file in dartFilesOf('lib')) {
        final source = file.readAsStringSync();
        if (!RegExp(
          r'extends\s+MentoraPrincipalLayout(?![A-Za-z])',
        ).hasMatch(source)) {
          continue;
        }
        shapes.add(file.path.replaceAll(r'\', '/'));
        // The alias is a getter over the one matter, never a field of
        // its own, and it is passed to the foundation as the matter.
        expect(RegExp(r'super\(principal:\s*\w+\)').hasMatch(source), isTrue);
        expect(
          RegExp(
            r'MentoraLayoutZone\s+get\s+\w+\s*=>\s*principal;',
          ).hasMatch(source),
          isTrue,
        );
      }
      // More than one shape is built around one matter, and every one
      // of them speaks the same six words.
      expect(shapes.length, greaterThan(1));

      final foundation = File(
        'lib/foundation/design_kit/layout/foundation/'
        'mentora_principal_layout.dart',
      ).readAsStringSync();
      expect(
        RegExp(r'final MentoraLayoutZone principal;').hasMatch(foundation),
        isTrue,
        reason:
            'the matter is not optional: the compiler refuses a page '
            'that is about nothing',
      );
    });
  });
}
