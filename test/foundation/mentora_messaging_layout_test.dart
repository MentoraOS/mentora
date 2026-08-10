import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_navigation_announcement.dart';
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
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_page_like_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_zoned_layout.dart';
import 'package:mentora/foundation/design_kit/layout/messaging_layout/mentora_messaging_layout.dart';
import 'package:mentora/foundation/design_kit/motion/motion_engine.dart';
import 'package:mentora/foundation/design_kit/registry/token_engines.dart';
import 'package:mentora/foundation/design_kit/structure/app_bar/mentora_app_bar.dart';
import 'package:mentora/foundation/design_kit/structure/page_scaffold/mentora_page_scaffold.dart';
import 'package:mentora/foundation/design_kit/structure/workspace/mentora_workspace.dart';
import 'package:mentora/foundation/design_kit/theme/theme_engine.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';
import 'package:mentora/foundation/design_kit/tokens/surface_elevation_tokens.dart';

/// What the application owns — recognisable, already built, and never
/// touched by the layout that organises the space. The words carry
/// spoken marks on purpose — a name, a seen-at, an online mark — so
/// the layout must hand them on without understanding any of them.
Widget _content(String id) => MentoraText(
  'Awa Diallo — vu à 14 h 05, en ligne — $id',
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

const List<MentoraMessagingRegion> _optional = [
  MentoraMessagingRegion.header,
  MentoraMessagingRegion.composition,
  MentoraMessagingRegion.supportingContent,
  MentoraMessagingRegion.footer,
];

/// A conversation space built the way a product builds one: the
/// dialogue is always there — the compiler requires it — and every
/// other region is removable on its own.
MentoraMessagingLayout _layout({
  MentoraLayoutContext frame = _frame,
  String pageSemanticLabel = 'Page courante',
  bool complete = true,
  Set<MentoraMessagingRegion> only = const {},
  Map<MentoraMessagingRegion, MentoraLayoutZone> replacing = const {},
  Set<MentoraMessagingRegion> without = const {},
  MentoraAppBar? place,
  List<MentoraButton> acts = const [],
}) {
  MentoraLayoutZone? zoneOf(MentoraMessagingRegion region) {
    if (replacing.containsKey(region)) return replacing[region];
    if (only.isNotEmpty) {
      return only.contains(region) ? _zone(region.name) : null;
    }
    if (without.contains(region)) return null;
    return complete ? _zone(region.name) : null;
  }

  return MentoraMessagingLayout(
    frame: frame,
    pageSemanticLabel: pageSemanticLabel,
    place: place,
    acts: acts,
    conversation:
        replacing[MentoraMessagingRegion.conversation] ??
        _zone(MentoraMessagingRegion.conversation.name),
    header: zoneOf(MentoraMessagingRegion.header),
    composition: zoneOf(MentoraMessagingRegion.composition),
    supportingContent: zoneOf(MentoraMessagingRegion.supportingContent),
    footer: zoneOf(MentoraMessagingRegion.footer),
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

Finder _regionOf(MentoraMessagingRegion region) =>
    find.byKey(Key('content-region-${region.name}'));

void main() {
  group('MentoraMessagingLayout — a person in a dialogue the product '
      'holds', () {
    testWidgets('it is a specialization of the one foundation, through '
        'the zoned foundation, and the registry knows its shape', (
      tester,
    ) async {
      expect(_layout(), isA<MentoraLayout>());
      expect(_layout(), isA<MentoraPageLikeLayout>());
      expect(_layout(), isA<MentoraZonedLayout<MentoraMessagingRegion>>());
      expect(_layout().kind, MentoraLayoutKind.messaging);

      await _pump(tester, _layout());
      expect(find.byKey(const Key('layout-messaging')), findsOneWidget);
      expect(find.byType(MentoraWorkspace), findsOneWidget);
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
    });

    testWidgets('it asks the assembly for the single disposition: it '
        'arranges nothing itself', (tester) async {
      await _pump(tester, _layout());

      expect(find.byKey(const Key('content-regions')), findsOneWidget);
      for (final region in MentoraMessagingRegion.values) {
        expect(_regionOf(region), findsOneWidget, reason: region.name);
      }
    });

    testWidgets('the official order is the order read, and it is the '
        'vocabulary itself', (tester) async {
      await _pump(tester, _layout());

      var previous = tester
          .getRect(_regionOf(MentoraMessagingRegion.header))
          .top;
      for (final region in MentoraMessagingRegion.values.skip(1)) {
        final top = tester.getRect(_regionOf(region)).top;
        expect(top, greaterThan(previous), reason: region.name);
        previous = top;
      }
      // The vocabulary is closed, and it is the order.
      expect(
        MentoraMessagingRegion.values.map((region) => region.name).toList(),
        [
          'header',
          'conversation',
          'composition',
          'supportingContent',
          'footer',
        ],
      );
    });

    testWidgets('the identity of a region is the official region: a '
        'product never names one', (tester) async {
      await _pump(tester, _layout());

      expect(
        find.byKey(const Key('content-region-conversation')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('content-region-ailleurs')), findsNothing);
    });

    testWidgets('the content of every region is handed on strictly '
        'intact — the spoken marks it carries are never read', (tester) async {
      await _pump(tester, _layout());

      // A name, a seen-at, an online mark: what was written is exactly
      // what stands — no one recognised, no moment understood, no
      // presence deduced.
      for (final region in MentoraMessagingRegion.values) {
        expect(
          find.text('Awa Diallo — vu à 14 h 05, en ligne — ${region.name}'),
          findsOneWidget,
          reason: region.name,
        );
        expect(
          tester.getTopLeft(find.byKey(Key('zone-${region.name}'))),
          tester.getTopLeft(_regionOf(region)),
          reason: region.name,
        );
      }
    });

    testWidgets('the dialogue is enough on its own: a space that is '
        'only read is a conversation space still', (tester) async {
      await _pump(tester, _layout(complete: false));

      expect(tester.takeException(), isNull);
      expect(_regionOf(MentoraMessagingRegion.conversation), findsOneWidget);
      for (final region in _optional) {
        expect(_regionOf(region), findsNothing, reason: region.name);
      }
      // And what remains starts at the very edge of the page.
      expect(
        tester.getTopLeft(_regionOf(MentoraMessagingRegion.conversation)),
        tester.getTopLeft(find.byType(MentoraPageScaffold)),
      );
    });

    testWidgets('every other region is optional: what was not given is '
        'not there at all', (tester) async {
      for (final absent in _optional) {
        await _pump(tester, _layout(without: {absent}));

        expect(tester.takeException(), isNull, reason: absent.name);
        expect(_regionOf(absent), findsNothing, reason: absent.name);
        for (final region in MentoraMessagingRegion.values) {
          if (region == absent) continue;
          expect(_regionOf(region), findsOneWidget, reason: region.name);
        }
      }
    });

    testWidgets('composing is optional and reading is not a lesser '
        'space: with and without it, the dialogue reads the same', (
      tester,
    ) async {
      await _pump(
        tester,
        _layout(without: {MentoraMessagingRegion.composition}),
      );
      final readOnly = tester.getTopLeft(
        _regionOf(MentoraMessagingRegion.conversation),
      );

      await _pump(tester, _layout());
      expect(
        tester.getTopLeft(_regionOf(MentoraMessagingRegion.conversation)),
        readOnly,
      );
    });

    testWidgets('the components stay the owners of what a region is '
        'made of', (tester) async {
      await _pump(
        tester,
        _layout(
          replacing: {
            MentoraMessagingRegion.conversation: _zone(
              'conversation',
              content: const MentoraCard(
                key: Key('zone-conversation'),
                variant: MentoraCardVariant.surface,
                child: MentoraText(
                  'Bonjour, comment allez-vous ?',
                  role: MentoraTextRole.body,
                ),
              ),
            ),
          },
        ),
      );

      expect(find.byType(MentoraCard), findsOneWidget);
      expect(find.text('Bonjour, comment allez-vous ?'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the same shape carries any dialogue: it represents no '
        'domain of the company', (tester) async {
      for (final subject in const ['premier dialogue', 'second dialogue']) {
        await _pump(
          tester,
          _layout(
            replacing: {
              MentoraMessagingRegion.conversation: _zone(
                'conversation',
                content: MentoraText(subject, role: MentoraTextRole.body),
              ),
            },
          ),
        );

        expect(tester.takeException(), isNull, reason: subject);
        expect(find.text(subject), findsOneWidget);
      }
    });

    testWidgets('each region is announced exactly once, and only the '
        'regions announce', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _layout());

      for (final region in MentoraMessagingRegion.values) {
        expect(
          find.bySemanticsLabel('Région ${region.name}'),
          findsOneWidget,
          reason: region.name,
        );
      }
      handle.dispose();
    });

    testWidgets('every region travels as its own focus group', (tester) async {
      await _pump(tester, _layout());

      for (final region in MentoraMessagingRegion.values) {
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

    testWidgets('a conversation space without a contract refuses to '
        'build — fail closed, ten times over', (tester) async {
      Future<void> refuses(Widget layout) async {
        await _pump(tester, layout);
        expect(tester.takeException(), isStateError);
      }

      // 1..5. A region without a name is not a landmark — each of the
      // five, through the one refusal the zoned foundation owns.
      for (final region in MentoraMessagingRegion.values) {
        await refuses(
          _layout(replacing: {region: _zone(region.name, semanticLabel: '')}),
        );
      }
      // 6. A page announces itself.
      await refuses(_layout(pageSemanticLabel: ''));
      // 7. The working context announces itself.
      await refuses(
        _layout(
          frame: const MentoraLayoutContext(
            semanticLabel: '',
            navigation: MentoraNavigationAnnouncement(destinationId: 'home'),
          ),
        ),
      );
      // 8. Outside the Design Kit nothing is resolved.
      await tester.pumpWidget(MaterialApp(home: _layout()));
      expect(tester.takeException(), isStateError);
      // 9. And 10. A layout is a whole screen: it never carries a
      // second one — wherever the second one stands.
      for (final region in const [
        MentoraMessagingRegion.conversation,
        MentoraMessagingRegion.composition,
      ]) {
        final refusals = <Object>[];
        final reporter = FlutterError.onError;
        FlutterError.onError = (details) => refusals.add(details.exception);
        await _pump(
          tester,
          _layout(replacing: {region: _zone(region.name, content: _layout())}),
        );
        FlutterError.onError = reporter;
        expect(
          refusals.whereType<StateError>(),
          isNotEmpty,
          reason: region.name,
        );
        expect(
          refusals.whereType<StateError>().first.message,
          contains('never placed inside another'),
          reason: region.name,
        );
      }
    });

    testWidgets('it holds in the four themes', (tester) async {
      for (final variant in ThemeVariantId.values) {
        await _pump(tester, _layout(), variant: variant);
        expect(tester.takeException(), isNull, reason: variant.name);
        expect(_regionOf(MentoraMessagingRegion.conversation), findsOneWidget);
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
        expect(_regionOf(MentoraMessagingRegion.conversation), findsOneWidget);
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

    testWidgets('it holds in both reading directions, and the dialogue '
        'still takes the whole width', (tester) async {
      for (final direction in TextDirection.values) {
        await _pump(tester, _layout(), direction: direction);
        expect(tester.takeException(), isNull, reason: direction.name);
        expect(
          tester.getRect(_regionOf(MentoraMessagingRegion.conversation)).width,
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
    Iterable<File> messagingFiles() => [
      ...dartFilesOf('lib/foundation/design_kit/layout/messaging_layout'),
      File(
        'lib/foundation/design_kit/layout/foundation/mentora_zoned_layout.dart',
      ),
    ];

    void refuse(Map<String, RegExp> forbidden, String because) {
      final files = messagingFiles().toList();
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

    test('a messaging layout knows no dialogue machinery: no one who '
        'speaks, nothing that travels', () {
      // Structural, never lexical: a concept USED carries a
      // constructor, a member or a named argument behind it — the
      // prose may name what the code may not carry.
      refuse({
        'a piece of a dialogue': RegExp(
          r'(?<![A-Za-z])(Message|Sender|Receiver|Recipient|Presence|'
          r'Online|Typing|ReadReceipt|Delivery|Thread|Channel|Chat|'
          r'Conversation)(?![a-z])',
        ),
        'an act of a dialogue': RegExp(
          r'(?<![A-Za-z])(send|receive|deliver|reply|compose|typing|'
          r'online|presence|unread|seen)\s*[:.(=]',
        ),
        'someone': RegExp(
          r'(?<![A-Za-z])(User|Author|Participant|Contact|Member)(?![a-z])',
        ),
        'a notification': RegExp(
          r'(?<![A-Za-z])(Notification|Push|Badge\w*Count)(?![A-Za-z])',
        ),
      }, 'it never carries');
    });

    test('a messaging layout knows no network, no realtime and no '
        'engine', () {
      refuse({
        'a network or a protocol': RegExp(
          r'(?<![A-Za-z])(http|HttpClient|Firestore|Firebase|Dio|'
          r'WebSocket|Socket|Sse|Grpc|Mqtt)(?![A-Za-z])',
        ),
        'a promise': RegExp(
          r'(?<![A-Za-z])(Future|Stream|async|await)(?![A-Za-z])',
        ),
        'a clock of its own': RegExp(
          r'(?<![A-Za-z])(Timer|Ticker|Stopwatch|DateTime|Duration)'
          r'(?![A-Za-z])',
        ),
        'a machinery of motion or of scroll': RegExp(
          r'(?<![A-Za-z])(ScrollController|AnimationController|'
          r'ConversationEngine)(?![A-Za-z])',
        ),
        'a synchronization': RegExp(
          r'(?<![A-Za-z])(sync\w*|Sync\w*|poll\w*|retry\w*)\s*[:.(=]',
        ),
      }, 'it never carries');
    });

    test('a messaging layout knows no logic, no data and no state', () {
      refuse({
        'a selection or an order of its own': RegExp(
          r'\.(where|firstWhere|lastWhere|singleWhere|sort|sorted|reversed|'
          r'reduce|fold|skip|take|expand)\s*[(.]',
        ),
        'an arithmetic': RegExp(r'(~/|\.ceil\(|\.floor\(|\.round\()'),
        'a model': RegExp(
          r'(?<![A-Za-z])(Wallet|Expert|Course|Invoice|Business|'
          r'Account|Profile|Entity|Model|Repository)(?![a-z])',
        ),
        'a source of data': RegExp(
          r'(?<![A-Za-z])(Provider|Bloc|Cubit|Riverpod|ChangeNotifier|'
          r'StreamBuilder|FutureBuilder)(?![A-Za-z])',
        ),
        'a state of the dialogue': RegExp(
          r'(?<![A-Za-z])(loading|error|success|offline|processing|'
          r'waiting|refreshing|connected|disconnected)(?![A-Za-z])',
        ),
        'a memory of its own': RegExp(
          r'(?<![A-Za-z])(StatefulWidget|setState|initState|ValueNotifier)'
          r'(?![A-Za-z])',
        ),
        'an untyped value': RegExp(
          r'(?<![A-Za-z])(dynamic|Object\?)(?![A-Za-z])',
        ),
        'an untyped zone': RegExp(r'final\s+Widget\?\s'),
        'a serialization': RegExp(r'(?<![A-Za-z])(fromJson|toJson)\s*[(<]'),
      }, 'it never carries');
    });

    test('a messaging layout builds no framework widget, measures '
        'nothing and navigates nowhere', () {
      refuse({
        'a structure of the framework': RegExp(
          r'(?<![A-Za-z])(Scaffold|AppBar|Drawer|NavigationBar|'
          r'NavigationRail|TabBar|Form|FormField|TextField|TextEditing\w*)'
          r'\s*[(.<]',
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

    test('one messaging layout exists in the whole product, it extends '
        'the zoned foundation, and it declares nothing else', () {
      final declarations = <String>[];
      for (final file in dartFilesOf('lib')) {
        if (RegExp(
          r'class\s+MentoraMessagingLayout(?![A-Za-z])',
        ).hasMatch(file.readAsStringSync())) {
          declarations.add(file.path.replaceAll(r'\', '/'));
        }
      }
      expect(declarations, hasLength(1));
      expect(declarations.single, contains('layout/messaging_layout/'));

      final source = codeOf(File(declarations.single));
      expect(
        RegExp(
          r'extends\s+MentoraZonedLayout<MentoraMessagingRegion>',
        ).hasMatch(source),
        isTrue,
      );
      // It declares no build, no surface and no refusal of any kind:
      // the order, the identities and the announcements are not its
      // own — and it refuses nothing as itself either.
      expect(RegExp(r'Widget\s+build\(').hasMatch(source), isFalse);
      expect(RegExp(r'surfaceOf\(').hasMatch(source), isFalse);
      expect(RegExp(r'void\s+verify\w*\(').hasMatch(source), isFalse);
      expect(RegExp(r'throw\s').hasMatch(source), isFalse);
      // The dialogue is required by the COMPILER, and composing is
      // optional by the same authority.
      expect(
        RegExp(r'final\s+MentoraLayoutZone\s+conversation;').hasMatch(source),
        isTrue,
      );
      expect(RegExp(r'required\s+this\.conversation').hasMatch(source), isTrue);
      expect(
        RegExp(r'final\s+MentoraLayoutZone\?\s+composition;').hasMatch(source),
        isTrue,
      );
      for (final built in const [
        'MentoraWorkspace(',
        'MentoraPageScaffold(',
        'MentoraCard(',
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
        "import '../foundation/mentora_layout_kind.dart';",
        "import '../foundation/mentora_layout_style.dart';",
        "import '../foundation/mentora_zoned_layout.dart';",
      ]);
    });

    test('the official regions are a closed vocabulary, declared once', () {
      // Structural, never lexical: the vocabulary is recognised by the
      // regions it speaks, so no second enumeration may open it again
      // under another name.
      final vocabularies = <String, String>{};
      for (final file in dartFilesOf('lib')) {
        final source = file.readAsStringSync();
        for (final match in RegExp(r'enum\s+(\w+)\s*\{').allMatches(source)) {
          final declaration = source.substring(match.start);
          final body = declaration.substring(0, declaration.indexOf('\n}') + 1);
          final speaksAll = MentoraMessagingRegion.values.every(
            (region) => RegExp(
              '(?<![A-Za-z])${region.name}(?![A-Za-z])',
            ).hasMatch(body),
          );
          if (speaksAll) {
            vocabularies[match.group(1)!] = file.path.replaceAll(r'\', '/');
          }
        }
      }
      expect(vocabularies.keys, ['MentoraMessagingRegion']);
      expect(
        vocabularies.values.single,
        endsWith('layout/foundation/mentora_layout_style.dart'),
      );
      expect(MentoraMessagingRegion.values, hasLength(5));
    });

    test('the zoned foundation has exactly three direct consumers — '
        'principal, detail and messaging — and every zoned shape is '
        'pure', () {
      final direct = <String>[];
      final zoned = <String>[];
      for (final file in dartFilesOf('lib')) {
        final source = codeOf(file);
        if (RegExp(r'extends\s+MentoraZonedLayout<').hasMatch(source)) {
          direct.add(file.path.replaceAll(r'\', '/'));
        }
        if (RegExp(
          r'extends\s+Mentora(ZonedLayout<|PrincipalLayout(?![A-Za-z]))',
        ).hasMatch(source)) {
          zoned.add(file.path.replaceAll(r'\', '/'));
          for (final owned in const [
            r'MentoraLayoutSurface\.',
            r'void\s+verify\(',
            r'id:\s*region\.name',
          ]) {
            expect(
              RegExp(owned).hasMatch(source),
              isFalse,
              reason: '$file: the zoned foundation owns $owned',
            );
          }
        }
      }
      expect(direct, hasLength(3));
      expect(direct.map((path) => path.split('/').last).toSet(), {
        'mentora_principal_layout.dart',
        'mentora_detail_layout.dart',
        'mentora_messaging_layout.dart',
      });
      expect(zoned.length, greaterThan(direct.length));

      // The machinery exists once — in the foundation they extend.
      final foundation = codeOf(
        File(
          'lib/foundation/design_kit/layout/foundation/'
          'mentora_zoned_layout.dart',
        ),
      );
      expect(
        RegExp(r'MentoraLayoutSurface\.regions\(').hasMatch(foundation),
        isTrue,
      );
      expect(RegExp(r'void\s+verify\(').hasMatch(foundation), isTrue);
    });

    test('no duplication of the detail was introduced: the two shapes '
        'share the foundation, never a vocabulary', () {
      // Two closed vocabularies may share a word — a footer is a
      // footer — but neither speaks the other whole: what makes each
      // shape itself stays its own.
      final detailWords = MentoraDetailRegion.values
          .map((region) => region.name)
          .toSet();
      final messagingWords = MentoraMessagingRegion.values
          .map((region) => region.name)
          .toSet();
      expect(detailWords.containsAll(messagingWords), isFalse);
      expect(messagingWords.containsAll(detailWords), isFalse);
      expect(messagingWords.difference(detailWords), {
        'header',
        'conversation',
        'composition',
      });

      final principalWords = MentoraPrincipalRegion.values
          .map((region) => region.name)
          .toSet();
      expect(principalWords.containsAll(messagingWords), isFalse);
      expect(messagingWords.difference(principalWords), {
        'conversation',
        'composition',
      });
    });
  });
}
