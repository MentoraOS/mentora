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
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_assembly.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_context.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_kind.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_style.dart';
import 'package:mentora/foundation/design_kit/layout/tabbed_content_layout/mentora_tabbed_content_layout.dart';
import 'package:mentora/foundation/design_kit/motion/motion_engine.dart';
import 'package:mentora/foundation/design_kit/registry/token_engines.dart';
import 'package:mentora/foundation/design_kit/structure/app_bar/mentora_app_bar.dart';
import 'package:mentora/foundation/design_kit/structure/page_scaffold/mentora_page_scaffold.dart';
import 'package:mentora/foundation/design_kit/structure/tabs/mentora_tabs.dart';
import 'package:mentora/foundation/design_kit/structure/tabs/mentora_tabs_style.dart';
import 'package:mentora/foundation/design_kit/structure/workspace/mentora_workspace.dart';
import 'package:mentora/foundation/design_kit/structure/workspace/mentora_workspace_style.dart';
import 'package:mentora/foundation/design_kit/theme/theme_engine.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';
import 'package:mentora/foundation/design_kit/tokens/surface_elevation_tokens.dart';

const String _context = 'Le portefeuille';

/// The contents the application owns — recognisable, already built,
/// and never touched by the context that holds them.
Widget _content(String id) => MentoraText(
  'Contenu $id',
  key: Key('content-$id'),
  role: MentoraTextRole.body,
);

MentoraIdentifiedContent _held(String id, {Widget? content}) =>
    MentoraIdentifiedContent(id: id, content: content ?? _content(id));

const List<MentoraTab> _facets = [
  MentoraTab(id: 'operations', label: 'Opérations'),
  MentoraTab(id: 'moyens', label: 'Moyens'),
  MentoraTab(id: 'documents', label: 'Documents'),
];

const MentoraLayoutContext _frame = MentoraLayoutContext(
  semanticLabel: 'Contexte de travail',
  navigation: MentoraWorkspaceNavigationState(destinationId: 'home'),
);

MentoraTabs _tabs(String selected) => MentoraTabs(
  controller: MentoraTabsController(selected),
  tabs: _facets,
  onTabSelected: (_) {},
);

MentoraTabbedContentLayout _layout({
  List<MentoraIdentifiedContent>? contents,
  MentoraLayoutContext frame = _frame,
  String pageSemanticLabel = 'Page courante',
  String contextId = 'portefeuille',
  String contextSemanticLabel = _context,
  String revealed = 'operations',
  MentoraTabs? facets,
  MentoraAppBar? place,
  List<MentoraButton> acts = const [],
}) {
  return MentoraTabbedContentLayout(
    frame: frame,
    facets: facets ?? _tabs('operations'),
    pageSemanticLabel: pageSemanticLabel,
    contextId: contextId,
    contextSemanticLabel: contextSemanticLabel,
    revealedContentId: revealed,
    place: place,
    acts: acts,
    contents:
        contents ?? [_held('operations'), _held('moyens'), _held('documents')],
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

Finder _contextOf(String id) => find.byKey(Key('tabbed-$id'));
Finder _revealedOf(String id) => find.byKey(Key('tabbed-content-$id'));

void main() {
  group('MentoraTabbedContentLayout — one context, one content revealed', () {
    testWidgets('it is a specialization of the one foundation, and the '
        'registry knows its shape', (tester) async {
      expect(_layout(), isA<MentoraLayout>());
      expect(_layout().kind, MentoraLayoutKind.tabbedContent);

      await _pump(tester, _layout());
      expect(find.byKey(const Key('layout-tabbedContent')), findsOneWidget);
      expect(find.byType(MentoraWorkspace), findsOneWidget);
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
    });

    testWidgets('exactly the content announced is revealed', (tester) async {
      await _pump(tester, _layout());

      expect(_contextOf('portefeuille'), findsOneWidget);
      expect(_revealedOf('operations'), findsOneWidget);
      expect(find.byKey(const Key('content-operations')), findsOneWidget);
    });

    testWidgets('what is not revealed does not exist: not in the tree, '
        'not for the focus, not for a screen reader', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _layout());

      for (final hidden in const ['moyens', 'documents']) {
        expect(_revealedOf(hidden), findsNothing, reason: hidden);
        expect(find.byKey(Key('content-$hidden')), findsNothing);
        expect(find.text('Contenu $hidden'), findsNothing);
        expect(
          find.bySemanticsLabel('Contenu $hidden'),
          findsNothing,
          reason: hidden,
        );
      }
      handle.dispose();
    });

    testWidgets('another content announced reveals another content, and '
        'the previous one stops existing', (tester) async {
      await _pump(
        tester,
        _layout(revealed: 'documents', facets: _tabs('documents')),
      );

      expect(_revealedOf('documents'), findsOneWidget);
      expect(_revealedOf('operations'), findsNothing);
      expect(find.byKey(const Key('content-operations')), findsNothing);
    });

    testWidgets('the content revealed is handed on strictly intact', (
      tester,
    ) async {
      await _pump(tester, _layout());

      expect(
        tester.getRect(find.byKey(const Key('content-operations'))),
        tester.getRect(_revealedOf('operations')),
        reason: 'the layout wraps what it reveals in nothing',
      );
    });

    testWidgets('the facets are composed, never recreated', (tester) async {
      await _pump(tester, _layout());

      expect(find.byType(MentoraTabs), findsOneWidget);
      expect(find.text('Opérations'), findsOneWidget);
      expect(find.text('Moyens'), findsOneWidget);
      // The framework tabs never appear anywhere: the facets are the
      // official ones, and nothing of the framework stands beside them.
      expect(find.byType(TabBar), findsNothing);
      expect(find.byType(TabBarView), findsNothing);
      expect(find.byType(PageView), findsNothing);
      expect(find.byType(IndexedStack), findsNothing);
    });

    testWidgets('the facets stand above what they reveal', (tester) async {
      await _pump(tester, _layout());

      expect(
        tester.getRect(find.byType(MentoraTabs)).bottom,
        lessThanOrEqualTo(tester.getRect(_contextOf('portefeuille')).top),
      );
    });

    testWidgets('the layout decides nothing: asking for another facet '
        'changes nothing on its own', (tester) async {
      var asked = 0;
      await _pump(
        tester,
        _layout(
          facets: MentoraTabs(
            controller: MentoraTabsController('operations'),
            tabs: _facets,
            onTabSelected: (_) => asked++,
          ),
        ),
      );

      await tester.tap(find.text('Moyens'));
      await tester.pumpAndSettle();

      // The intention was reported to the application, and the context
      // still reveals exactly what it was told to reveal.
      expect(asked, 1);
      expect(_revealedOf('operations'), findsOneWidget);
      expect(_revealedOf('moyens'), findsNothing);
    });

    testWidgets('it creates no scroll view and no way of hiding: what a '
        'composed component owns stays its own', (tester) async {
      await _pump(tester, _layout());

      // Scoped to what the layout itself places: the facets own their
      // own scrolling and their own hiding, and that stays theirs.
      final revealed = _contextOf('portefeuille');
      for (final owned in [
        find.byType(Scrollable),
        find.byType(SingleChildScrollView),
        find.byType(PageView),
        find.byType(Offstage),
        find.byType(IndexedStack),
      ]) {
        expect(find.descendant(of: revealed, matching: owned), findsNothing);
      }
    });

    testWidgets('it creates no padding of its own: what is revealed '
        'begins at the very edge of the room it was given', (tester) async {
      await _pump(tester, _layout());

      final page = tester.getRect(find.byType(MentoraPageScaffold));
      final revealed = tester.getRect(_contextOf('portefeuille'));
      expect(revealed.left, page.left);
      expect(revealed.width, page.width);
      expect(
        tester.getTopLeft(_revealedOf('operations')),
        tester.getTopLeft(_contextOf('portefeuille')),
      );
    });

    testWidgets('only the context is announced: the content revealed '
        'keeps its own voice', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _layout());

      expect(find.bySemanticsLabel(_context), findsOneWidget);
      expect(tester.getSemantics(_contextOf('portefeuille')).label, _context);
      expect(find.bySemanticsLabel('Contenu operations'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('a context is one landmark and one focus group', (
      tester,
    ) async {
      await _pump(tester, _layout());

      expect(
        find.descendant(
          of: _contextOf('portefeuille'),
          matching: find.byType(FocusTraversalGroup),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the focus stays where the person left it: the layout '
        'never takes it', (tester) async {
      final inside = FocusNode(debugLabel: 'content');
      addTearDown(inside.dispose);

      await _pump(
        tester,
        _layout(
          contents: [
            _held(
              'operations',
              content: Focus(focusNode: inside, child: _content('operations')),
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

    testWidgets('a content is an identity: it is found by what it is, '
        'never by where it stands', (tester) async {
      await _pump(tester, _layout(revealed: 'moyens', facets: _tabs('moyens')));

      expect(_revealedOf('moyens'), findsOneWidget);
      expect(_revealedOf('ailleurs'), findsNothing);
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
      expect(find.byType(MentoraTabs), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a tabbed context without a contract refuses to build — '
        'fail closed', (tester) async {
      Future<void> refuses(Widget layout) async {
        await _pump(tester, layout);
        expect(tester.takeException(), isStateError);
      }

      // A context without an identity, and without a name.
      await refuses(_layout(contextId: ''));
      await refuses(_layout(contextSemanticLabel: ''));
      // A context that holds nothing.
      await refuses(_layout(contents: const []));
      // A content without an identity.
      await refuses(_layout(contents: [_held('')]));
      // Two contents sharing one identity.
      await refuses(
        _layout(contents: [_held('operations'), _held('operations')]),
      );
      // Nothing announced as revealed, and something unknown.
      await refuses(_layout(revealed: ''));
      await refuses(_layout(revealed: 'ailleurs'));
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

    testWidgets('the assembly itself refuses to reveal what it was not '
        'given — fail closed', (tester) async {
      await _pump(
        tester,
        MentoraLayoutAssembly(
          kind: MentoraLayoutKind.tabbedContent,
          frame: _frame,
          surface: MentoraLayoutSurface.revealed(
            semanticLabel: 'Page courante',
            contextId: 'portefeuille',
            contextSemanticLabel: _context,
            contents: [_held('operations')],
            revealedContentId: 'ailleurs',
          ),
        ),
      );

      expect(tester.takeException(), isStateError);
    });

    testWidgets('it holds in the four themes', (tester) async {
      for (final variant in ThemeVariantId.values) {
        await _pump(tester, _layout(), variant: variant);
        expect(tester.takeException(), isNull, reason: variant.name);
        expect(_contextOf('portefeuille'), findsOneWidget);
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
        expect(_revealedOf('operations'), findsOneWidget);
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

    testWidgets('it holds in both reading directions, and what is '
        'revealed still takes the whole width', (tester) async {
      for (final direction in TextDirection.values) {
        await _pump(tester, _layout(), direction: direction);
        expect(tester.takeException(), isNull, reason: direction.name);
        expect(
          tester.getRect(_contextOf('portefeuille')).width,
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

    Iterable<File> contextFiles() =>
        dartFilesOf('lib/foundation/design_kit/layout/tabbed_content_layout');

    test('a context carries no framework tab, no page view and no way '
        'of hiding', () {
      // Structural, never lexical: a type USED carries a constructor,
      // a member or a type argument behind it — the prose may name
      // what the code may not carry.
      final forbidden = <String, RegExp>{
        'a framework tab': RegExp(
          r'(?<![A-Za-z])(TabBar|TabBarView|TabController|'
          r'DefaultTabController|TabPageSelector)\s*[(.<]',
        ),
        'a page view': RegExp(
          r'(?<![A-Za-z])(PageView|PageController)\s*[(.<]',
        ),
        'a way of hiding': RegExp(
          r'(?<![A-Za-z])(IndexedStack|Offstage|Visibility|ExcludeFocus|'
          r'ExcludeSemantics)\s*[(.<]',
        ),
        'a scroll view': RegExp(
          r'(?<![A-Za-z])(Scrollable|ScrollView|SingleChildScrollView|'
          r'ListView|CustomScrollView|ScrollController)\s*[(.<]',
        ),
      };
      final files = contextFiles();
      expect(files, isNotEmpty);
      for (final file in files) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: what is not revealed is not built — it '
                'never carries ${entry.key}',
          );
        }
      }
    });

    test('a context builds no framework widget and no room of its own', () {
      final forbidden = <String, RegExp>{
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
      for (final file in contextFiles()) {
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

    test('a context navigates nowhere, measures nothing and knows no '
        'business', () {
      final forbidden = <String, RegExp>{
        'an address': RegExp(
          r'(?<![A-Za-z])(Navigator|GoRouter|routeName|pushNamed|'
          r'MaterialPageRoute)(?![A-Za-z])',
        ),
        'a route type': RegExp(r'(?<![A-Za-z])Route<'),
        'a measure of the screen': RegExp(
          r'(?<![A-Za-z])(MediaQuery|LayoutBuilder|ResponsiveEngine|'
          r'Breakpoint\w*|OrientationBuilder)\s*[(.<]',
        ),
        'a platform': RegExp(
          r'(?<![A-Za-z])(Platform|TargetPlatform|defaultTargetPlatform|'
          r'kIsWeb|isAndroid|isIOS)(?![A-Za-z])',
        ),
        'a business domain': RegExp(
          r'(?<![A-Za-z])(Wallet|Orders?|Marketplace|Business|Inventory|'
          r'Payments?|Messages?|Consultation|Profile|Analytics|Settings|'
          r'Reports?|Invoice|Facture|Product|Chat|Dashboard)(?![a-z])',
        ),
        'a model or a collection of data': RegExp(
          r'(?<![A-Za-z])(fromJson|toJson|Model|Repository|Entity|'
          r'HttpClient|Firestore)(?![A-Za-z])',
        ),
        'a decision of its own': RegExp(
          r'\.(sort|reversed|where|firstWhere|lastWhere|singleWhere|'
          r'reduce|fold|skip|take)\b',
        ),
        'an untyped value': RegExp(
          r'(?<![A-Za-z])(dynamic|Object\?)(?![A-Za-z])',
        ),
        'an untyped zone': RegExp(r'final\s+Widget\?\s'),
      };
      for (final file in contextFiles()) {
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

    test('a context reads no ambient theme and codes no value', () {
      final forbidden = <String, RegExp>{
        'an ambient theme': RegExp(r'Theme\.of\('),
        'a coded colour': RegExp(r'(Color\(0x|Colors\.)'),
        'a coded padding': RegExp(r'EdgeInsets\.\w+\(\s*[0-9]'),
        'a coded radius': RegExp(r'BorderRadius\.\w+\(\s*[0-9]'),
        'a coded extent': RegExp(r'(width|height|spacing|runSpacing):\s*[0-9]'),
        'a coded duration': RegExp(r'Duration\((milliseconds|seconds)'),
        'a coded voice': RegExp(r'(fontSize:|FontWeight\.)'),
      };
      for (final file in contextFiles()) {
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

    test('one tabbed context exists in the whole product, it extends '
        'the foundation, and it builds nothing at all', () {
      final declarations = <String>[];
      for (final file in dartFilesOf('lib')) {
        if (RegExp(
          r'class\s+MentoraTabbedContentLayout(?![A-Za-z])',
        ).hasMatch(file.readAsStringSync())) {
          declarations.add(file.path.replaceAll(r'\', '/'));
        }
      }
      expect(declarations, hasLength(1));
      expect(declarations.single, contains('layout/tabbed_content_layout/'));

      final source = File(declarations.single).readAsStringSync();
      expect(
        RegExp(r'extends\s+MentoraLayout(?![A-Za-z])').hasMatch(source),
        isTrue,
      );
      expect(RegExp(r'Widget\s+build\(').hasMatch(source), isFalse);
      for (final built in const [
        'MentoraWorkspace(',
        'MentoraPageScaffold(',
        'MentoraTabs(',
        'Column(',
        'Row(',
        'Semantics(',
        'FocusTraversalGroup(',
        'KeyedSubtree(',
      ]) {
        expect(source.contains(built), isFalse, reason: built);
      }
    });

    test('one unit designates content across the whole layer: there is '
        'no second twin of it', () {
      final twins = <String>[];
      for (final file in dartFilesOf('lib/foundation/design_kit/layout')) {
        final source = file.readAsStringSync();
        for (final match in RegExp(
          r'final class (Mentora\w+) \{',
        ).allMatches(source)) {
          final declaration = source.substring(match.start);
          final body = declaration.substring(0, declaration.indexOf('\n}') + 1);
          // A unit that designates content carries an identity, what
          // it is, and NOTHING else: a cell also carries the room it
          // takes, a region its own name, a section its title — those
          // are other concepts, and they are allowed to exist.
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
