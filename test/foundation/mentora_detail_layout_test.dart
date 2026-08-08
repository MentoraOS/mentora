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
import 'package:mentora/foundation/design_kit/layout/detail_layout/mentora_detail_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_context.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_kind.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_style.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_zoned_layout.dart';
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
/// touched by the layout that organises the consultation.
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
  navigation: MentoraWorkspaceNavigationState(destinationId: 'home'),
);

/// A detail built the way a product builds one: every region is
/// optional, so the fixture makes each of them removable on its own.
MentoraDetailLayout _layout({
  MentoraLayoutContext frame = _frame,
  String pageSemanticLabel = 'Page courante',
  bool complete = true,
  Set<MentoraDetailRegion> only = const {},
  Map<MentoraDetailRegion, MentoraLayoutZone> replacing = const {},
  Set<MentoraDetailRegion> without = const {},
  MentoraAppBar? place,
  List<MentoraButton> acts = const [],
}) {
  MentoraLayoutZone? zoneOf(MentoraDetailRegion region) {
    if (replacing.containsKey(region)) return replacing[region];
    if (only.isNotEmpty) {
      return only.contains(region) ? _zone(region.name) : null;
    }
    if (without.contains(region)) return null;
    return complete ? _zone(region.name) : null;
  }

  return MentoraDetailLayout(
    frame: frame,
    pageSemanticLabel: pageSemanticLabel,
    place: place,
    acts: acts,
    hero: zoneOf(MentoraDetailRegion.hero),
    identity: zoneOf(MentoraDetailRegion.identity),
    summary: zoneOf(MentoraDetailRegion.summary),
    details: zoneOf(MentoraDetailRegion.details),
    supportingContent: zoneOf(MentoraDetailRegion.supportingContent),
    actions: zoneOf(MentoraDetailRegion.actions),
    footer: zoneOf(MentoraDetailRegion.footer),
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

Finder _regionOf(MentoraDetailRegion region) =>
    find.byKey(Key('content-region-${region.name}'));

void main() {
  group('MentoraDetailLayout — a person consulting one thing', () {
    testWidgets('it is a specialization of the one foundation, through '
        'the zoned foundation, and the registry knows its shape', (
      tester,
    ) async {
      expect(_layout(), isA<MentoraLayout>());
      expect(_layout(), isA<MentoraZonedLayout<MentoraDetailRegion>>());
      expect(_layout().kind, MentoraLayoutKind.detail);

      await _pump(tester, _layout());
      expect(find.byKey(const Key('layout-detail')), findsOneWidget);
      expect(find.byType(MentoraWorkspace), findsOneWidget);
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
    });

    testWidgets('it asks the assembly for the single disposition: it '
        'arranges nothing itself', (tester) async {
      await _pump(tester, _layout());

      expect(find.byKey(const Key('content-regions')), findsOneWidget);
      for (final region in MentoraDetailRegion.values) {
        expect(_regionOf(region), findsOneWidget, reason: region.name);
      }
    });

    testWidgets('the official order is the order read, and it is the '
        'vocabulary itself', (tester) async {
      await _pump(tester, _layout());

      var previous = tester.getRect(_regionOf(MentoraDetailRegion.hero)).top;
      for (final region in MentoraDetailRegion.values.skip(1)) {
        final top = tester.getRect(_regionOf(region)).top;
        expect(top, greaterThan(previous), reason: region.name);
        previous = top;
      }
      // The vocabulary is closed, and it is the order.
      expect(MentoraDetailRegion.values.map((region) => region.name).toList(), [
        'hero',
        'identity',
        'summary',
        'details',
        'supportingContent',
        'actions',
        'footer',
      ]);
    });

    testWidgets('the identity of a region is the official region: a '
        'product never names one', (tester) async {
      await _pump(tester, _layout());

      expect(find.byKey(const Key('content-region-identity')), findsOneWidget);
      expect(find.byKey(const Key('content-region-ailleurs')), findsNothing);
    });

    testWidgets('the content of every region is handed on strictly '
        'intact', (tester) async {
      await _pump(tester, _layout());

      for (final region in MentoraDetailRegion.values) {
        expect(
          tester.getTopLeft(find.byKey(Key('zone-${region.name}'))),
          tester.getTopLeft(_regionOf(region)),
          reason: region.name,
        );
      }
    });

    testWidgets('every region is optional: what was not given is not '
        'there at all', (tester) async {
      for (final absent in MentoraDetailRegion.values) {
        // The three regions that inform are never all removed at once:
        // one of them always remains, which is the shape’s own rule.
        final layout = absent.carriesInformation
            ? _layout(without: {absent, MentoraDetailRegion.hero})
            : _layout(without: {absent});
        await _pump(tester, layout);

        expect(tester.takeException(), isNull, reason: absent.name);
        expect(_regionOf(absent), findsNothing, reason: absent.name);
        for (final region in MentoraDetailRegion.values) {
          if (region == absent || region == MentoraDetailRegion.hero) continue;
          expect(_regionOf(region), findsOneWidget, reason: region.name);
        }
      }
    });

    testWidgets('what one sees first is optional, and what remains still '
        'starts at the very edge of the page', (tester) async {
      await _pump(tester, _layout(only: {MentoraDetailRegion.identity}));

      expect(_regionOf(MentoraDetailRegion.hero), findsNothing);
      expect(
        tester.getTopLeft(_regionOf(MentoraDetailRegion.identity)),
        tester.getTopLeft(find.byType(MentoraPageScaffold)),
      );
    });

    testWidgets('each region that informs is enough on its own', (
      tester,
    ) async {
      for (final region in MentoraDetailRegion.values) {
        if (!region.carriesInformation) continue;
        await _pump(tester, _layout(only: {region}));

        expect(tester.takeException(), isNull, reason: region.name);
        expect(_regionOf(region), findsOneWidget, reason: region.name);
      }
    });

    test('the vocabulary itself says which regions inform', () {
      final informing = <String>[];
      for (final region in MentoraDetailRegion.values) {
        if (region.carriesInformation) informing.add(region.name);
      }
      expect(informing, ['identity', 'summary', 'details']);
    });

    testWidgets('a detail that informs about nothing refuses to build — '
        'fail closed', (tester) async {
      Future<void> refuses(Widget layout) async {
        await _pump(tester, layout);
        expect(tester.takeException(), isStateError);
      }

      // Nothing at all.
      await refuses(_layout(complete: false));
      // What one sees first is not what one learns.
      await refuses(_layout(only: {MentoraDetailRegion.hero}));
      // Neither is what helps beside, what can be done, or what is
      // said underneath.
      await refuses(
        _layout(
          only: {
            MentoraDetailRegion.hero,
            MentoraDetailRegion.supportingContent,
            MentoraDetailRegion.actions,
            MentoraDetailRegion.footer,
          },
        ),
      );
    });

    testWidgets('a detail layout without a contract refuses to build — '
        'fail closed', (tester) async {
      Future<void> refuses(Widget layout) async {
        await _pump(tester, layout);
        expect(tester.takeException(), isStateError);
      }

      // A region without a name, wherever it stands.
      for (final region in const [
        MentoraDetailRegion.hero,
        MentoraDetailRegion.identity,
        MentoraDetailRegion.footer,
      ]) {
        await refuses(
          _layout(replacing: {region: _zone(region.name, semanticLabel: '')}),
        );
      }
      // A page that announces nothing, and a context that does not
      // announce itself.
      await refuses(_layout(pageSemanticLabel: ''));
      await refuses(
        _layout(
          frame: const MentoraLayoutContext(
            semanticLabel: '',
            navigation: MentoraWorkspaceNavigationState(destinationId: 'home'),
          ),
        ),
      );
    });

    testWidgets('it adds no room between the regions of the detail', (
      tester,
    ) async {
      await _pump(tester, _layout());

      var previous = tester.getRect(_regionOf(MentoraDetailRegion.hero));
      for (final region in MentoraDetailRegion.values.skip(1)) {
        final rect = tester.getRect(_regionOf(region));
        expect(rect.top, previous.bottom, reason: region.name);
        previous = rect;
      }
      expect(layoutContentGap, 0);
    });

    testWidgets('it creates no scroll view and no padding of its own', (
      tester,
    ) async {
      await _pump(tester, _layout(only: {MentoraDetailRegion.identity}));

      expect(find.byType(Scrollable), findsNothing);
      expect(find.byType(SingleChildScrollView), findsNothing);

      final page = tester.getRect(find.byType(MentoraPageScaffold));
      final region = tester.getRect(_regionOf(MentoraDetailRegion.identity));
      expect(region.left, page.left);
      expect(region.width, page.width);
      expect(region.top, page.top);
    });

    testWidgets('the components stay the owners: the avatar owns the '
        'face, the badge the mention, the button the act', (tester) async {
      await _pump(
        tester,
        _layout(
          replacing: {
            MentoraDetailRegion.hero: _zone(
              'hero',
              content: const MentoraAvatar(
                key: Key('zone-hero'),
                identity: MentoraAvatarIdentity.initials,
                name: 'Awa Diallo',
                initials: 'AD',
              ),
            ),
            MentoraDetailRegion.identity: _zone(
              'identity',
              content: const MentoraBadge(
                key: Key('zone-identity'),
                variant: MentoraBadgeVariant.verified,
                label: 'Vérifié',
                semanticLabel: 'Vérifié',
              ),
            ),
            MentoraDetailRegion.summary: _zone(
              'summary',
              content: const MentoraCard(
                key: Key('zone-summary'),
                variant: MentoraCardVariant.surface,
                child: SizedBox.shrink(),
              ),
            ),
            MentoraDetailRegion.actions: _zone(
              'actions',
              content: MentoraButton(
                key: const Key('zone-actions'),
                label: 'Continuer',
                onPressed: () {},
                size: MentoraButtonSize.small,
              ),
            ),
          },
        ),
      );

      expect(find.byType(MentoraAvatar), findsOneWidget);
      expect(find.byType(MentoraBadge), findsOneWidget);
      expect(find.byType(MentoraCard), findsOneWidget);
      expect(find.byType(MentoraButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the same shape carries anything: it represents no '
        'domain of the company', (tester) async {
      // Two entirely different things, consulted through the very same
      // regions — the shape is about the act, never about the subject.
      for (final subject in const ['premier sujet', 'second sujet']) {
        await _pump(
          tester,
          _layout(
            only: {MentoraDetailRegion.identity},
            replacing: {
              MentoraDetailRegion.identity: _zone(
                'identity',
                semanticLabel: subject,
                content: MentoraText(subject, role: MentoraTextRole.body),
              ),
            },
          ),
        );

        expect(tester.takeException(), isNull, reason: subject);
        expect(_regionOf(MentoraDetailRegion.identity), findsOneWidget);
        expect(find.text(subject), findsOneWidget);
      }
    });

    testWidgets('every region is a landmark, announced exactly once', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _layout());

      for (final region in MentoraDetailRegion.values) {
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
          only: {MentoraDetailRegion.identity},
          replacing: {
            MentoraDetailRegion.identity: _zone(
              'identity',
              semanticLabel: 'Ce que c’est',
              content: const MentoraBadge(
                variant: MentoraBadgeVariant.verified,
                label: 'Vérifié',
                semanticLabel: 'Vérifié',
              ),
            ),
          },
        ),
      );

      expect(find.bySemanticsLabel('Ce que c’est'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Vérifié')), findsWidgets);
      handle.dispose();
    });

    testWidgets('every region travels as its own focus group', (tester) async {
      await _pump(tester, _layout());

      for (final region in MentoraDetailRegion.values) {
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
          only: {MentoraDetailRegion.details},
          replacing: {
            MentoraDetailRegion.details: _zone(
              'details',
              content: Focus(focusNode: inside, child: _content('details')),
            ),
          },
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
          only: {MentoraDetailRegion.summary},
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
        expect(_regionOf(MentoraDetailRegion.identity), findsOneWidget);
      }
    });

    testWidgets('it holds at every font scale', (tester) async {
      for (final scale in FontScalePreference.values) {
        await _pump(
          tester,
          _layout(only: {MentoraDetailRegion.identity}),
          appearance: AppearanceState(fontScale: scale),
        );
        expect(tester.takeException(), isNull, reason: scale.name);
        expect(_regionOf(MentoraDetailRegion.identity), findsOneWidget);
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
          tester.getRect(_regionOf(MentoraDetailRegion.identity)).width,
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

    /// The shape AND the foundation it is built on: the machinery moved
    /// there, so the scans follow it — a rule never stays behind the
    /// code it opposes.
    Iterable<File> detailFiles() => [
      ...dartFilesOf('lib/foundation/design_kit/layout/detail_layout'),
      File(
        'lib/foundation/design_kit/layout/foundation/mentora_zoned_layout.dart',
      ),
    ];

    void refuse(Map<String, RegExp> forbidden, String because) {
      final files = detailFiles().toList();
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

    test('a detail layout knows no data and no model', () {
      // Structural, never lexical: a type USED carries a constructor, a
      // member or a type argument behind it — the prose may name what
      // the code may not carry.
      refuse({
        'a model of the company': RegExp(
          r'(?<![A-Za-z])(User|Product|Wallet|Expert|Course|Consultation|'
          r'Invoice|Business|Organization|Transaction|Document|Account|'
          r'Profile|Entity|Model)(?![a-z])',
        ),
        'a serialization': RegExp(r'(?<![A-Za-z])(fromJson|toJson)\s*[(<]'),
      }, 'it never carries');
    });

    test('a detail layout knows no logic: nothing is calculated, sorted, '
        'filtered or transformed', () {
      refuse({
        'a selection or an order of its own': RegExp(
          r'\.(where|firstWhere|lastWhere|singleWhere|sort|sorted|reversed|'
          r'reduce|fold|skip|take|expand)\s*[(.]',
        ),
        'an arithmetic': RegExp(r'(~/|\.ceil\(|\.floor\(|\.round\()'),
      }, 'it never carries');
    });

    test('a detail layout knows no network and no source of data', () {
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
          r'(?<![A-Za-z])(Future|Stream|async|await)'
          r'(?![A-Za-z])',
        ),
      }, 'it never carries');
    });

    test('a detail layout knows no state of what is consulted', () {
      refuse({
        'a state of the work': RegExp(
          r'(?<![A-Za-z])(loading|error|success|offline|processing|'
          r'waiting|refreshing|isEmpty\w|isLoaded)(?![A-Za-z])',
        ),
        'an untyped value': RegExp(
          r'(?<![A-Za-z])(dynamic|Object\?)(?![A-Za-z])',
        ),
        'an untyped zone': RegExp(r'final\s+Widget\?\s'),
      }, 'it never carries');
    });

    test('a detail layout builds no framework widget, measures nothing '
        'and navigates nowhere', () {
      refuse({
        'a structure of the framework': RegExp(
          r'(?<![A-Za-z])(Scaffold|AppBar|Drawer|NavigationBar|'
          r'NavigationRail|TabBar|Form|FormField)\s*[(.<]',
        ),
        'a scroll view or a collection': RegExp(
          r'(?<![A-Za-z])(Scrollable|ScrollView|SingleChildScrollView|'
          r'CustomScrollView|ListView|GridView|Sliver\w*|Wrap|Flow)'
          r'\s*[(.<]',
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

    test('one detail layout exists in the whole product, it extends the '
        'zoned foundation, and it builds nothing at all', () {
      final declarations = <String>[];
      for (final file in dartFilesOf('lib')) {
        if (RegExp(
          r'class\s+MentoraDetailLayout(?![A-Za-z])',
        ).hasMatch(file.readAsStringSync())) {
          declarations.add(file.path.replaceAll(r'\', '/'));
        }
      }
      expect(declarations, hasLength(1));
      expect(declarations.single, contains('layout/detail_layout/'));

      final source = File(declarations.single).readAsStringSync();
      expect(RegExp(r'extends\s+MentoraZonedLayout<').hasMatch(source), isTrue);
      // It declares no build, no surface and no shared refusal: the
      // order, the identities and the announcements are not its own.
      expect(RegExp(r'Widget\s+build\(').hasMatch(source), isFalse);
      expect(RegExp(r'surfaceOf\(').hasMatch(source), isFalse);
      expect(RegExp(r'void\s+verify\(').hasMatch(source), isFalse);
      for (final built in const [
        'MentoraWorkspace(',
        'MentoraPageScaffold(',
        'MentoraAvatar(',
        'MentoraCard(',
        'MentoraBadge(',
        'MentoraButton(',
        'MentoraSection(',
        'Column(',
        'Semantics(',
        'FocusTraversalGroup(',
      ]) {
        expect(source.contains(built), isFalse, reason: built);
      }
    });

    test('the official regions are a closed vocabulary, declared once', () {
      // Structural, never lexical: the vocabulary is recognised by the
      // regions it speaks, so no second enumeration may open it again
      // under another name — and an older, different concept that
      // merely reads alike is never mistaken for it.
      final vocabularies = <String, String>{};
      for (final file in dartFilesOf('lib')) {
        final source = file.readAsStringSync();
        for (final match in RegExp(r'enum\s+(\w+)\s*\{').allMatches(source)) {
          final declaration = source.substring(match.start);
          final body = declaration.substring(0, declaration.indexOf('\n}') + 1);
          final speaksAll = MentoraDetailRegion.values.every(
            (region) => RegExp(
              '(?<![A-Za-z])${region.name}(?![A-Za-z])',
            ).hasMatch(body),
          );
          if (speaksAll) {
            vocabularies[match.group(1)!] = file.path.replaceAll(r'\', '/');
          }
        }
      }
      expect(vocabularies.keys, ['MentoraDetailRegion']);
      expect(
        vocabularies.values.single,
        endsWith('layout/foundation/mentora_layout_style.dart'),
      );
      expect(MentoraDetailRegion.values, hasLength(7));
    });

    test('one type names a region across the whole layer: there is no '
        'second twin of it', () {
      final twins = <String>[];
      for (final file in dartFilesOf('lib/foundation/design_kit/layout')) {
        final source = file.readAsStringSync();
        for (final match in RegExp(
          r'final class (Mentora\w+) \{',
        ).allMatches(source)) {
          final declaration = source.substring(match.start);
          final body = declaration.substring(0, declaration.indexOf('\n}') + 1);
          // A named part carries its announcement, what it holds, and
          // NOTHING else: a region of an open vocabulary also carries
          // the identity the application gave it — another concept.
          final fields = RegExp(
            r'final \w+\??\s+(\w+);',
          ).allMatches(body).map((field) => field.group(1)).toSet();
          if (fields.length == 2 &&
              fields.contains('semanticLabel') &&
              fields.contains('content')) {
            twins.add(match.group(1)!);
          }
        }
      }
      expect(twins, ['MentoraLayoutZone']);
    });

    test('a zoned shape owns no shared machinery: the order, the '
        'identities and the refusals live in exactly one place', () {
      final zoned = <String>[];
      for (final file in dartFilesOf('lib')) {
        // Zoned directly, or through the foundation built on it: what
        // is proved here follows the chain, never a single name.
        if (RegExp(
          r'extends\s+Mentora(ZonedLayout<|PrincipalLayout(?![A-Za-z]))',
        ).hasMatch(file.readAsStringSync())) {
          zoned.add(file.path.replaceAll(r'\', '/'));
        }
      }
      // Every zoned shape, and there is more than one.
      expect(zoned.length, greaterThan(1));
      for (final path in zoned) {
        final source = File(path).readAsStringSync();
        expect(
          RegExp(r'MentoraLayoutSurface\.').hasMatch(source),
          isFalse,
          reason: '$path: a zoned shape never asks for a surface itself',
        );
        expect(
          RegExp(r'void\s+verify\(').hasMatch(source),
          isFalse,
          reason: '$path: the shared refusals can never be skipped',
        );
        expect(
          source.contains('id: region.name'),
          isFalse,
          reason: '$path: the identity of a region is given once, above',
        );
      }
    });
  });
}
