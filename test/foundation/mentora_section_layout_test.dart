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
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_context.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_kind.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_style.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_theme.dart';
import 'package:mentora/foundation/design_kit/layout/section_layout/mentora_section_layout.dart';
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

const String _title = 'Résumé du mois';
const String _description = 'Ce qui complète le nom';

/// The content the application owns — recognisable, and never touched
/// by the section that gathers it.
Widget _content(String id) => MentoraText(
  'Contenu $id',
  key: Key('content-$id'),
  role: MentoraTextRole.body,
);

MentoraSection _section(
  String id, {
  String title = _title,
  String? description,
  Widget? content,
}) => MentoraSection(
  id: id,
  title: title,
  description: description,
  content: content ?? _content(id),
);

const MentoraLayoutContext _frame = MentoraLayoutContext(
  semanticLabel: 'Contexte de travail',
  navigation: MentoraWorkspaceNavigationState(destinationId: 'home'),
);

MentoraSectionLayout _layout({
  List<MentoraSection>? sections,
  MentoraLayoutContext frame = _frame,
  String pageSemanticLabel = 'Page courante',
  MentoraAppBar? place,
  List<MentoraButton> acts = const [],
}) {
  return MentoraSectionLayout(
    frame: frame,
    pageSemanticLabel: pageSemanticLabel,
    place: place,
    acts: acts,
    sections: sections ?? [_section('resume', description: _description)],
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

Finder _sectionOf(String id) => find.byKey(Key('section-$id'));
Finder _titleOf(String id) => find.byKey(Key('section-title-$id'));
Finder _descriptionOf(String id) => find.byKey(Key('section-description-$id'));
Finder _regionOf(String id) => find.byKey(Key('content-region-$id'));

void main() {
  group('MentoraSectionLayout — the official unit of content', () {
    testWidgets('it is a specialization of the one foundation, and the '
        'registry knows its shape', (tester) async {
      expect(_layout(), isA<MentoraLayout>());
      expect(_layout().kind, MentoraLayoutKind.section);

      await _pump(tester, _layout());
      expect(find.byKey(const Key('layout-section')), findsOneWidget);
      expect(find.byType(MentoraWorkspace), findsOneWidget);
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
    });

    testWidgets('it asks the assembly for the single disposition: it '
        'arranges nothing itself', (tester) async {
      await _pump(
        tester,
        _layout(sections: [_section('resume'), _section('details')]),
      );

      // The regions are the layer's own disposition, built once, in
      // the assembly — a section never orders anything.
      expect(find.byKey(const Key('content-regions')), findsOneWidget);
      expect(_regionOf('resume'), findsOneWidget);
      expect(_regionOf('details'), findsOneWidget);
    });

    testWidgets('the content is handed on strictly intact: it starts '
        'exactly under what names it', (tester) async {
      await _pump(tester, _layout());

      final title = tester.getRect(_titleOf('resume'));
      final description = tester.getRect(_descriptionOf('resume'));
      final content = tester.getRect(find.byKey(const Key('content-resume')));

      // Geometric proof: nothing is added between the name, what
      // completes it, and what the section gathers.
      expect(description.top, title.bottom);
      expect(content.top, description.bottom);
      expect(content.left, title.left);
      expect(layoutContentGap, 0);
    });

    testWidgets('a section without a description gathers its content '
        'directly under its name', (tester) async {
      await _pump(tester, _layout(sections: [_section('resume')]));

      expect(_descriptionOf('resume'), findsNothing);
      expect(
        tester.getRect(find.byKey(const Key('content-resume'))).top,
        tester.getRect(_titleOf('resume')).bottom,
      );
    });

    testWidgets('the name is composed, never styled: it is an official '
        'word at the official voice', (tester) async {
      final services = await _pump(tester, _layout());
      final theme = MentoraLayoutTheme(
        spacing: services.get<SpacingTokenEngine>(),
      );

      final title = tester.widget<MentoraText>(_titleOf('resume'));
      expect(title.data, _title);
      expect(title.role, theme.sectionTitleRole);

      final description = tester.widget<MentoraText>(_descriptionOf('resume'));
      expect(description.data, _description);
      expect(description.role, theme.sectionDescriptionRole);
    });

    testWidgets('a section is announced ONCE: the name it is known by '
        'is never said twice', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _layout());

      expect(find.bySemanticsLabel(_title), findsOneWidget);
      expect(tester.getSemantics(_regionOf('resume')).label, _title);
      // What completes the name keeps its own voice.
      expect(find.bySemanticsLabel(_description), findsOneWidget);
      handle.dispose();
    });

    testWidgets('every section is a landmark of its own, and its own '
        'focus group', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        _layout(
          sections: [
            _section('resume'),
            _section('details', title: 'Le détail'),
          ],
        ),
      );

      expect(tester.getSemantics(_regionOf('resume')).label, _title);
      expect(tester.getSemantics(_regionOf('details')).label, 'Le détail');
      for (final id in const ['resume', 'details']) {
        expect(
          find.descendant(
            of: _regionOf(id),
            matching: find.byType(FocusTraversalGroup),
          ),
          findsOneWidget,
          reason: id,
        );
      }
      handle.dispose();
    });

    testWidgets('the sections are read in the order they were '
        'announced', (tester) async {
      await _pump(
        tester,
        _layout(
          sections: [
            _section('premier', title: 'Premier'),
            _section('second', title: 'Second'),
            _section('tiers', title: 'Tiers'),
          ],
        ),
      );

      final tops = [
        for (final id in const ['premier', 'second', 'tiers'])
          tester.getRect(_sectionOf(id)).top,
      ];
      expect(tops[1], greaterThan(tops[0]));
      expect(tops[2], greaterThan(tops[1]));
    });

    testWidgets('it adds no room between the sections it gathers', (
      tester,
    ) async {
      await _pump(
        tester,
        _layout(
          sections: [
            _section('resume'),
            _section('details', title: 'Le détail'),
          ],
        ),
      );

      expect(
        tester.getRect(_regionOf('details')).top,
        tester.getRect(_regionOf('resume')).bottom,
      );
    });

    testWidgets('it creates no scroll view of its own', (tester) async {
      await _pump(tester, _layout());

      expect(find.byType(Scrollable), findsNothing);
      expect(find.byType(SingleChildScrollView), findsNothing);
    });

    testWidgets('it creates no padding of its own: a section takes the '
        'whole room it was given, from its very edge', (tester) async {
      await _pump(tester, _layout());

      final page = tester.getRect(find.byType(MentoraPageScaffold));
      final section = tester.getRect(_sectionOf('resume'));
      expect(section.left, page.left);
      expect(section.width, page.width);
      expect(section.top, page.top);
    });

    testWidgets('the focus stays where the person left it: the layout '
        'never takes it', (tester) async {
      final inside = FocusNode(debugLabel: 'section');
      addTearDown(inside.dispose);

      await _pump(
        tester,
        _layout(
          sections: [
            _section(
              'resume',
              content: Focus(focusNode: inside, child: _content('resume')),
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

    testWidgets('a section layout without a contract refuses to build — '
        'fail closed', (tester) async {
      Future<void> refuses(Widget layout) async {
        await _pump(tester, layout);
        expect(tester.takeException(), isStateError);
      }

      // Content absent.
      await refuses(_layout(sections: const []));
      // A section without an identity.
      await refuses(_layout(sections: [_section('')]));
      // A section without a name.
      await refuses(_layout(sections: [_section('resume', title: '')]));
      // A completion that completes nothing — an ambiguity.
      await refuses(_layout(sections: [_section('resume', description: '')]));
      // Two sections sharing one identity.
      await refuses(
        _layout(sections: [_section('resume'), _section('resume')]),
      );
      // A page that announces nothing.
      await refuses(_layout(pageSemanticLabel: ''));
      // A working context that announces nothing.
      await refuses(
        _layout(
          frame: const MentoraLayoutContext(
            semanticLabel: '',
            navigation: MentoraWorkspaceNavigationState(destinationId: 'home'),
          ),
        ),
      );
    });

    testWidgets('it holds in the four themes', (tester) async {
      for (final variant in ThemeVariantId.values) {
        await _pump(tester, _layout(), variant: variant);
        expect(tester.takeException(), isNull, reason: variant.name);
        expect(_sectionOf('resume'), findsOneWidget);
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
        expect(_titleOf('resume'), findsOneWidget);
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

    testWidgets('it holds in both reading directions, and a section '
        'still takes the whole width', (tester) async {
      for (final direction in TextDirection.values) {
        await _pump(tester, _layout(), direction: direction);
        expect(tester.takeException(), isNull, reason: direction.name);
        expect(
          tester.getRect(_sectionOf('resume')).width,
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

    Iterable<File> sectionFiles() =>
        dartFilesOf('lib/foundation/design_kit/layout/section_layout');

    test('a section builds no framework widget, and no room of its own', () {
      final forbidden = <String, RegExp>{
        'a padding': RegExp(r'(?<![A-Za-z])Padding\('),
        'a safe area': RegExp(r'(?<![A-Za-z])SafeArea\('),
        'a decorative box': RegExp(
          r'(?<![A-Za-z])(Container|DecoratedBox|ColoredBox)\(',
        ),
        'a flexible space': RegExp(
          r'(?<![A-Za-z])(Expanded|Flexible|Spacer)(?![A-Za-z])',
        ),
        'a scroll view': RegExp(
          r'(?<![A-Za-z])(ListView|SingleChildScrollView|CustomScrollView|'
          r'GridView|ScrollController|NestedScrollView)(?![A-Za-z])',
        ),
        'a grid': RegExp(r'(?<![A-Za-z])(GridPaper|Table|Flow)\('),
        'its own words': RegExp(r'(?<![A-Za-z])Text\('),
        'its own style': RegExp(r'(?<![A-Za-z])TextStyle\('),
      };
      final files = sectionFiles();
      expect(files, isNotEmpty);
      for (final file in files) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: a section gathers content — it never '
                'builds ${entry.key}',
          );
        }
      }
    });

    test('a section measures no screen, knows no platform, no address, '
        'no business and no data', () {
      final forbidden = <String, RegExp>{
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
          r'Reports?|Invoice|Facture|Product|Chat|Dashboard)(?![a-z])',
        ),
        'a model or a collection': RegExp(
          r'(?<![A-Za-z])(fromJson|toJson|Model|Repository|Entity|'
          r'HttpClient|Firestore)(?![A-Za-z])',
        ),
        'a selection of data': RegExp(
          r'\.(where|firstWhere|lastWhere|singleWhere|sort|reduce|fold)\(',
        ),
        'an untyped value': RegExp(
          r'(?<![A-Za-z])(dynamic|Object\?)(?![A-Za-z])',
        ),
        'an untyped zone': RegExp(r'final\s+Widget\?\s'),
      };
      for (final file in sectionFiles()) {
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

    test('a section reads no ambient theme and codes no value', () {
      final forbidden = <String, RegExp>{
        'an ambient theme': RegExp(r'Theme\.of\('),
        'a coded colour': RegExp(r'(Color\(0x|Colors\.)'),
        'a coded padding': RegExp(r'EdgeInsets\.\w+\(\s*[0-9]'),
        'a coded radius': RegExp(r'BorderRadius\.\w+\(\s*[0-9]'),
        'a coded extent': RegExp(r'(width|height|spacing|runSpacing):\s*[0-9]'),
        'a coded duration': RegExp(r'Duration\((milliseconds|seconds)'),
        'a coded voice': RegExp(r'(fontSize:|FontWeight\.)'),
      };
      for (final file in sectionFiles()) {
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

    test('one section layout exists in the whole product, it extends the '
        'foundation, and it never builds or assembles', () {
      final declarations = <String>[];
      for (final file in dartFilesOf('lib')) {
        if (RegExp(
          r'class\s+MentoraSectionLayout(?![A-Za-z])',
        ).hasMatch(file.readAsStringSync())) {
          declarations.add(file.path.replaceAll(r'\', '/'));
        }
      }
      expect(declarations, hasLength(1));
      expect(declarations.single, contains('layout/section_layout/'));

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
      ]) {
        expect(source.contains(built), isFalse, reason: built);
      }
    });
  });
}
