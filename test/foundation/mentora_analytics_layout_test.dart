import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_navigation_announcement.dart';
import 'package:mentora/foundation/bootstrap/design_kit_bootstrap.dart';
import 'package:mentora/foundation/core/di/foundation_services.dart';
import 'package:mentora/foundation/design_kit/accessibility/accessibility_engine.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/components/badge/mentora_badge.dart';
import 'package:mentora/foundation/design_kit/components/badge/mentora_badge_style.dart';
import 'package:mentora/foundation/design_kit/components/button/mentora_button.dart';
import 'package:mentora/foundation/design_kit/components/button/mentora_button_style.dart';
import 'package:mentora/foundation/design_kit/components/card/mentora_card.dart';
import 'package:mentora/foundation/design_kit/components/card/mentora_card_style.dart';
import 'package:mentora/foundation/design_kit/components/design_kit_scope.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text_role.dart';
import 'package:mentora/foundation/design_kit/layout/analytics_layout/mentora_analytics_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_context.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_kind.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_style.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_page_like_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_regioned_layout.dart';
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
/// interpreted by the layout that places it. The words carry numbers on
/// purpose: the layout must hand them on without understanding them.
Widget _observation(String id) => MentoraText(
  'Observation $id — 1 248',
  key: Key('view-$id'),
  role: MentoraTextRole.body,
);

MentoraContentRegion _view(
  String id, {
  String? semanticLabel,
  Widget? content,
}) => MentoraContentRegion(
  id: id,
  semanticLabel: semanticLabel ?? 'Vue $id',
  content: content ?? _observation(id),
);

const List<String> _identities = ['revenu', 'activite', 'qualite'];

const MentoraLayoutContext _frame = MentoraLayoutContext(
  semanticLabel: 'Contexte de travail',
  navigation: MentoraNavigationAnnouncement(destinationId: 'home'),
);

MentoraAnalyticsLayout _layout({
  MentoraLayoutContext frame = _frame,
  String pageSemanticLabel = 'Page courante',
  List<MentoraContentRegion>? views,
  MentoraAppBar? place,
  List<MentoraButton> acts = const [],
}) {
  return MentoraAnalyticsLayout(
    frame: frame,
    pageSemanticLabel: pageSemanticLabel,
    place: place,
    acts: acts,
    views: views ?? [for (final id in _identities) _view(id)],
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

Finder _viewOf(String id) => find.byKey(Key('content-region-$id'));

void main() {
  group('MentoraAnalyticsLayout — a space where a system is observed', () {
    testWidgets('it is a specialization of the one foundation, through '
        'the regioned foundation, and the registry knows its shape', (
      tester,
    ) async {
      expect(_layout(), isA<MentoraLayout>());
      expect(_layout(), isA<MentoraPageLikeLayout>());
      expect(_layout(), isA<MentoraRegionedLayout>());
      expect(_layout().kind, MentoraLayoutKind.analytics);

      await _pump(tester, _layout());
      expect(find.byKey(const Key('layout-analytics')), findsOneWidget);
      expect(find.byType(MentoraWorkspace), findsOneWidget);
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
    });

    test('the word of an observation is an alias over the one holder: '
        'there is no second field anywhere', () {
      final views = [for (final id in _identities) _view(id)];
      final layout = _layout(views: views);

      expect(layout.views, same(views));
      expect(layout.views, same(layout.regions));
    });

    testWidgets('it asks the assembly for the single disposition: it '
        'arranges nothing itself', (tester) async {
      await _pump(tester, _layout());

      expect(find.byKey(const Key('content-regions')), findsOneWidget);
      for (final id in _identities) {
        expect(_viewOf(id), findsOneWidget, reason: id);
      }
    });

    testWidgets('a view is an IDENTITY: the product refers to it by what '
        'it is, never by where it stands', (tester) async {
      await _pump(tester, _layout());

      expect(_viewOf('activite'), findsOneWidget);
      expect(find.byKey(const Key('content-region-0')), findsNothing);
      expect(find.byKey(const Key('content-region-ailleurs')), findsNothing);
    });

    testWidgets('a view is never a position: announced in another order '
        'it is still the same view, announced the same way', (tester) async {
      await _pump(tester, _layout());
      final spoken = tester.getSemantics(_viewOf('qualite')).label;

      await _pump(
        tester,
        _layout(views: [for (final id in _identities.reversed) _view(id)]),
      );

      expect(_viewOf('qualite'), findsOneWidget);
      expect(tester.getSemantics(_viewOf('qualite')).label, spoken);
    });

    testWidgets('the order announced is the order read — never sorted, '
        'never rearranged', (tester) async {
      await _pump(
        tester,
        _layout(views: [for (final id in _identities.reversed) _view(id)]),
      );

      // The reversed announcement is expressed reversed: nothing here
      // knows a better order than the one it was given.
      var previous = tester.getRect(_viewOf(_identities.last)).top;
      for (final id in _identities.reversed.skip(1)) {
        final top = tester.getRect(_viewOf(id)).top;
        expect(top, greaterThan(previous), reason: id);
        previous = top;
      }
    });

    testWidgets('every view announced is expressed: nothing is filtered '
        'away, nothing is kept back', (tester) async {
      await _pump(tester, _layout());

      for (final id in _identities) {
        expect(_viewOf(id), findsOneWidget, reason: id);
        expect(find.byKey(Key('view-$id')), findsOneWidget, reason: id);
      }
    });

    testWidgets('a view is handed on strictly intact: the words carry '
        'numbers, and the layout never reads them', (tester) async {
      await _pump(tester, _layout());

      // What was written is exactly what stands — no unit added, no
      // rounding, no interpretation of any kind.
      for (final id in _identities) {
        expect(find.text('Observation $id — 1 248'), findsOneWidget);
        expect(
          tester.getTopLeft(find.byKey(Key('view-$id'))),
          tester.getTopLeft(_viewOf(id)),
          reason: id,
        );
      }
    });

    testWidgets('it compares nothing: two views with the same content '
        'are two views, each whole', (tester) async {
      await _pump(
        tester,
        _layout(
          views: [
            _view('revenu', content: _observation('revenu')),
            _view('activite', content: _observation('activite')),
          ],
        ),
      );

      expect(_viewOf('revenu'), findsOneWidget);
      expect(_viewOf('activite'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('it adds no room between the views', (tester) async {
      await _pump(tester, _layout());

      var previous = tester.getRect(_viewOf(_identities.first));
      for (final id in _identities.skip(1)) {
        final rect = tester.getRect(_viewOf(id));
        expect(rect.top, previous.bottom, reason: id);
        previous = rect;
      }
      expect(layoutContentGap, 0);
    });

    testWidgets('it creates no scroll view and no padding of its own', (
      tester,
    ) async {
      await _pump(tester, _layout(views: [_view('revenu')]));

      expect(find.byType(Scrollable), findsNothing);
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.byType(ListView), findsNothing);
      expect(find.byType(Table), findsNothing);

      final page = tester.getRect(find.byType(MentoraPageScaffold));
      final view = tester.getRect(_viewOf('revenu'));
      expect(view.left, page.left);
      expect(view.width, page.width);
      expect(view.top, page.top);
    });

    testWidgets('the components stay the owners of what an observation '
        'is made of', (tester) async {
      await _pump(
        tester,
        _layout(
          views: [
            _view(
              'revenu',
              content: const MentoraCard(
                key: Key('view-revenu'),
                variant: MentoraCardVariant.surface,
                child: MentoraBadge(
                  variant: MentoraBadgeVariant.information,
                  label: '1 248',
                  semanticLabel: '1 248',
                ),
              ),
            ),
          ],
        ),
      );

      expect(find.byType(MentoraCard), findsOneWidget);
      expect(find.byType(MentoraBadge), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the same shape carries any system: it represents no '
        'domain of the company', (tester) async {
      for (final subject in const ['premier système', 'second système']) {
        await _pump(
          tester,
          _layout(
            views: [
              _view(
                'revenu',
                semanticLabel: subject,
                content: MentoraText(subject, role: MentoraTextRole.body),
              ),
            ],
          ),
        );

        expect(tester.takeException(), isNull, reason: subject);
        expect(find.text(subject), findsOneWidget);
      }
    });

    testWidgets('every view is a landmark, announced exactly once', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _layout());

      for (final id in _identities) {
        expect(tester.getSemantics(_viewOf(id)).label, 'Vue $id', reason: id);
        expect(find.bySemanticsLabel('Vue $id'), findsOneWidget, reason: id);
      }
      handle.dispose();
    });

    testWidgets('the components keep their own announcements', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        _layout(
          views: [
            _view(
              'revenu',
              semanticLabel: 'Le revenu observé',
              content: const MentoraBadge(
                key: Key('view-revenu'),
                variant: MentoraBadgeVariant.information,
                label: '1 248',
                semanticLabel: 'Mille deux cent quarante-huit',
              ),
            ),
          ],
        ),
      );

      expect(find.bySemanticsLabel('Le revenu observé'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('Mille deux cent quarante-huit')),
        findsWidgets,
      );
      handle.dispose();
    });

    testWidgets('every view travels as its own focus group', (tester) async {
      await _pump(tester, _layout());

      for (final id in _identities) {
        expect(
          find.descendant(
            of: _viewOf(id),
            matching: find.byType(FocusTraversalGroup),
          ),
          findsOneWidget,
          reason: id,
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
          views: [
            _view(
              'revenu',
              content: Focus(focusNode: inside, child: _observation('revenu')),
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
          views: [_view('revenu')],
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

    testWidgets('an analytics layout without a contract refuses to '
        'build — fail closed, ten times over', (tester) async {
      Future<void> refuses(Widget layout) async {
        await _pump(tester, layout);
        expect(tester.takeException(), isStateError);
      }

      // 1. A space with no view observes nothing.
      await refuses(_layout(views: const []));
      // 2. A view without an identity is not a view.
      await refuses(_layout(views: [_view('')]));
      // 3. And it is refused wherever it stands: the whole list is
      //    walked, never its head alone.
      await refuses(_layout(views: [_view('revenu'), _view('')]));
      // 4. A view without a name is not a landmark.
      await refuses(_layout(views: [_view('revenu', semanticLabel: '')]));
      // 5. Two views never share one identity.
      await refuses(_layout(views: [_view('revenu'), _view('revenu')]));
      // 6. And identity is a set, not a comparison with the neighbour.
      await refuses(
        _layout(views: [_view('revenu'), _view('activite'), _view('revenu')]),
      );
      // 7. A page announces itself.
      await refuses(_layout(pageSemanticLabel: ''));
      // 8. The working context announces itself.
      await refuses(
        _layout(
          frame: const MentoraLayoutContext(
            semanticLabel: '',
            navigation: MentoraNavigationAnnouncement(destinationId: 'home'),
          ),
        ),
      );
      // 9. Outside the Design Kit nothing is resolved.
      await tester.pumpWidget(MaterialApp(home: _layout()));
      expect(tester.takeException(), isStateError);
    });

    testWidgets('an analytics layout is a whole screen: it never carries '
        'a second one — fail closed', (tester) async {
      final refusals = <Object>[];
      final reporter = FlutterError.onError;
      FlutterError.onError = (details) => refusals.add(details.exception);
      await _pump(
        tester,
        _layout(views: [_view('revenu', content: _layout())]),
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
        expect(_viewOf('revenu'), findsOneWidget);
      }
    });

    testWidgets('it holds at every font scale', (tester) async {
      for (final scale in FontScalePreference.values) {
        await _pump(
          tester,
          _layout(views: [_view('revenu')]),
          appearance: AppearanceState(fontScale: scale),
        );
        expect(tester.takeException(), isNull, reason: scale.name);
        expect(_viewOf('revenu'), findsOneWidget);
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

    testWidgets('it holds in both reading directions, and a view still '
        'takes the whole width', (tester) async {
      for (final direction in TextDirection.values) {
        await _pump(tester, _layout(), direction: direction);
        expect(tester.takeException(), isNull, reason: direction.name);
        expect(
          tester.getRect(_viewOf('revenu')).width,
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
    Iterable<File> analyticsFiles() => [
      ...dartFilesOf('lib/foundation/design_kit/layout/analytics_layout'),
      File(
        'lib/foundation/design_kit/layout/foundation/'
        'mentora_regioned_layout.dart',
      ),
    ];

    void refuse(Map<String, RegExp> forbidden, String because) {
      final files = analyticsFiles().toList();
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

    test('an analytics layout calculates nothing: no statistic, no '
        'aggregation, no comparison', () {
      refuse({
        'a statistic': RegExp(
          r'(?<![A-Za-z])(count|sum|avg|average|median|percent\w*|ratio|'
          r'growth|variation|delta|trend|projection)\s*[:.(=]',
        ),
        'an extremum': RegExp(r'(?<![A-Za-z])(min|max)\s*[:.(=]'),
        'a count of what it holds': RegExp(r'\.length'),
        'an arithmetic': RegExp(
          r'(~/|\s[+*/-]\s\d|\.ceil\(|\.floor\(|\.round\(|\.abs\()',
        ),
        'a comparison of views': RegExp(
          r'(?<![A-Za-z])(compare\w*|sortedBy|\bdiff)\s*[:.(=]',
        ),
      }, 'it never carries');
    });

    test('an analytics layout sorts nothing and filters nothing', () {
      refuse({
        'a selection or an order of its own': RegExp(
          r'\.(where|firstWhere|lastWhere|singleWhere|sort|sorted|reversed|'
          r'reduce|fold|skip|take|expand|removeWhere|retainWhere)\s*[(.]',
        ),
        'a filter': RegExp(r'(?<![A-Za-z])(filter\w*|Filter)\s*[:.(=<]'),
        'an aggregation': RegExp(
          r'(?<![A-Za-z])(aggregate\w*|Aggregate|groupBy)\s*[:.(=<]',
        ),
      }, 'it never carries');
    });

    test('an analytics layout draws no chart and builds no table', () {
      refuse({
        'a chart': RegExp(
          r'(?<![A-Za-z])(Chart|Graph|PieChart|BarChart|LineChart|'
          r'Sparkline|CustomPaint|CustomPainter)\s*[(.<]',
        ),
        'a table': RegExp(
          r'(?<![A-Za-z])(DataTable|Table|TableRow|DataGrid)\s*[(.<]',
        ),
      }, 'it never carries');
    });

    test('an analytics layout knows no data, no network and no time', () {
      refuse({
        'a model': RegExp(
          r'(?<![A-Za-z])(User|Product|Wallet|Expert|Consultation|Invoice|'
          r'Business|Account|Profile|Entity|Model|Metric|Statistic)'
          r'(?![a-z])',
        ),
        'a source of data': RegExp(
          r'(?<![A-Za-z])(Repository|Provider|Bloc|Cubit|Riverpod|'
          r'ChangeNotifier|StreamBuilder|FutureBuilder)(?![A-Za-z])',
        ),
        'a network or a promise': RegExp(
          r'(?<![A-Za-z])(http|HttpClient|Firestore|Future|Stream|async|'
          r'await)(?![A-Za-z])',
        ),
        'a period': RegExp(
          r'(?<![A-Za-z])(DateTime|DateRange|period|interval|since|until)'
          r'\s*[:.(=<]',
        ),
        'a memory of its own': RegExp(
          r'(?<![A-Za-z])(StatefulWidget|setState|initState|ValueNotifier)'
          r'(?![A-Za-z])',
        ),
        'an untyped value': RegExp(
          r'(?<![A-Za-z])(dynamic|Object\?)(?![A-Za-z])',
        ),
        'an untyped view': RegExp(r'final\s+Widget\?\s'),
      }, 'it never carries');
    });

    test('an analytics layout builds no framework widget, measures '
        'nothing and navigates nowhere', () {
      refuse({
        'a room of its own': RegExp(
          r'(?<![A-Za-z])(Padding|SafeArea|Expanded|Flexible|Spacer|Wrap|'
          r'Flow)\s*[(.<]',
        ),
        'a scroll view or a collection': RegExp(
          r'(?<![A-Za-z])(Scrollable|ScrollView|SingleChildScrollView|'
          r'ListView|GridView|Sliver\w*|Scrollbar)\s*[(.<]',
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

    test('one analytics layout exists in the whole product, it extends '
        'the regioned foundation, and it declares nothing else', () {
      final declarations = <String>[];
      for (final file in dartFilesOf('lib')) {
        if (RegExp(
          r'class\s+MentoraAnalyticsLayout(?![A-Za-z])',
        ).hasMatch(file.readAsStringSync())) {
          declarations.add(file.path.replaceAll(r'\', '/'));
        }
      }
      expect(declarations, hasLength(1));
      expect(declarations.single, contains('layout/analytics_layout/'));

      final source = codeOf(File(declarations.single));
      expect(
        RegExp(r'extends\s+MentoraRegionedLayout(?![A-Za-z])').hasMatch(source),
        isTrue,
      );
      // It owns no region, no order, no refusal and no surface: it owns
      // its official kind, and the word it calls its regions by — an
      // alias, never a second field.
      for (final owned in const [
        r'Widget\s+build\(',
        r'surfaceOf\(',
        r'void\s+verify\(',
        r'final\s+[\w<>?, ]+\s+\w+\s*;',
        r'enum\s+\w+',
      ]) {
        expect(RegExp(owned).hasMatch(source), isFalse, reason: owned);
      }
      expect(
        RegExp(
          r'List<MentoraContentRegion>\s+get\s+views\s*=>\s*regions;',
        ).hasMatch(source),
        isTrue,
      );
      for (final built in const [
        'MentoraWorkspace(',
        'MentoraPageScaffold(',
        'MentoraCard(',
        'MentoraBadge(',
        'MentoraButton(',
        'Column(',
        'Semantics(',
        'FocusTraversalGroup(',
        'KeyedSubtree(',
      ]) {
        expect(source.contains(built), isFalse, reason: built);
      }
    });

    test('no duplication was introduced: every shape whose regions the '
        'application names owns nothing of how they are expressed', () {
      final shapes = <String>[];
      for (final file in dartFilesOf('lib')) {
        final source = codeOf(file);
        if (!RegExp(
          r'extends\s+MentoraRegionedLayout(?![A-Za-z])',
        ).hasMatch(source)) {
          continue;
        }
        shapes.add(file.path.replaceAll(r'\', '/'));
        for (final owned in const [
          r'MentoraLayoutSurface\.',
          r'void\s+verify\(',
          r'final\s+List<MentoraContentRegion>',
        ]) {
          expect(
            RegExp(owned).hasMatch(source),
            isFalse,
            reason: '$file: the regioned foundation owns $owned',
          );
        }
      }
      // More than one shape speaks in regions, and the machinery
      // exists once — in the foundation they extend.
      expect(shapes.length, greaterThan(1));

      final foundation = codeOf(
        File(
          'lib/foundation/design_kit/layout/foundation/'
          'mentora_regioned_layout.dart',
        ),
      );
      expect(
        RegExp(
          r'final List<MentoraContentRegion> regions;',
        ).hasMatch(foundation),
        isTrue,
      );
    });
  });
}
