import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/bootstrap/design_kit_bootstrap.dart';
import 'package:mentora/foundation/core/di/foundation_services.dart';
import 'package:mentora/foundation/design_kit/accessibility/accessibility_engine.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/components/button/mentora_button.dart';
import 'package:mentora/foundation/design_kit/components/button/mentora_button_style.dart';
import 'package:mentora/foundation/design_kit/components/card/mentora_card.dart';
import 'package:mentora/foundation/design_kit/components/card/mentora_card_style.dart';
import 'package:mentora/foundation/design_kit/components/design_kit_scope.dart';
import 'package:mentora/foundation/design_kit/components/input/mentora_input.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text_role.dart';
import 'package:mentora/foundation/design_kit/composition/list_tile/mentora_list_tile.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_context.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_kind.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_style.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_page_like_layout.dart';
import 'package:mentora/foundation/design_kit/layout/settings_layout/mentora_settings_layout.dart';
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
/// touched by the layout that organises the space.
Widget _summaryOf(String id) => MentoraText(
  'Résumé $id',
  key: Key('summary-$id'),
  role: MentoraTextRole.body,
);

Widget _optionsOf(String id) => MentoraText(
  'Options $id',
  key: Key('options-$id'),
  role: MentoraTextRole.body,
);

MentoraSettingsCategory _category(
  String id, {
  String? semanticLabel,
  bool unfolded = false,
  Widget? summary,
  Widget? options,
}) => MentoraSettingsCategory(
  id: id,
  semanticLabel: semanticLabel ?? 'Catégorie $id',
  summary: summary ?? _summaryOf(id),
  options: options ?? _optionsOf(id),
  unfolded: unfolded,
);

const List<String> _identities = ['compte', 'securite', 'notifications'];

const MentoraLayoutContext _frame = MentoraLayoutContext(
  semanticLabel: 'Contexte de travail',
  navigation: MentoraWorkspaceNavigationState(destinationId: 'home'),
);

MentoraSettingsLayout _layout({
  MentoraLayoutContext frame = _frame,
  String pageSemanticLabel = 'Page courante',
  List<MentoraSettingsCategory>? categories,
  Set<String> open = const {},
  MentoraAppBar? place,
  List<MentoraButton> acts = const [],
}) {
  return MentoraSettingsLayout(
    frame: frame,
    pageSemanticLabel: pageSemanticLabel,
    place: place,
    acts: acts,
    categories:
        categories ??
        [
          for (final id in _identities)
            _category(id, unfolded: open.contains(id)),
        ],
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

Finder _categoryOf(String id) => find.byKey(Key('settings-category-$id'));

void main() {
  group('MentoraSettingsLayout — a space where a system is configured', () {
    testWidgets('it is a specialization of the one foundation, through '
        'the page-like foundation, and the registry knows its shape', (
      tester,
    ) async {
      expect(_layout(), isA<MentoraLayout>());
      expect(_layout(), isA<MentoraPageLikeLayout>());
      expect(_layout().kind, MentoraLayoutKind.settings);

      await _pump(tester, _layout());
      expect(find.byKey(const Key('layout-settings')), findsOneWidget);
      expect(find.byType(MentoraWorkspace), findsOneWidget);
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
    });

    testWidgets('it asks the assembly for the disposition: it arranges '
        'nothing itself', (tester) async {
      await _pump(tester, _layout());

      expect(find.byKey(const Key('settings-categories')), findsOneWidget);
      for (final id in _identities) {
        expect(_categoryOf(id), findsOneWidget, reason: id);
      }
    });

    testWidgets('a category is an IDENTITY: the product refers to it by '
        'what it is, never by where it stands', (tester) async {
      await _pump(tester, _layout());

      expect(_categoryOf('securite'), findsOneWidget);
      expect(find.byKey(const Key('settings-category-0')), findsNothing);
      expect(find.byKey(const Key('settings-category-ailleurs')), findsNothing);
    });

    testWidgets('a category is never a position: announced in another '
        'order it is still the same category, open the same way', (
      tester,
    ) async {
      await _pump(tester, _layout(open: const {'securite'}));
      final spoken = tester.getSemantics(_categoryOf('securite')).label;

      await _pump(
        tester,
        _layout(
          categories: [
            for (final id in _identities.reversed)
              _category(id, unfolded: id == 'securite'),
          ],
        ),
      );

      expect(_categoryOf('securite'), findsOneWidget);
      expect(tester.getSemantics(_categoryOf('securite')).label, spoken);
      expect(find.byKey(const Key('options-securite')), findsOneWidget);
    });

    testWidgets('the order announced is the order read', (tester) async {
      await _pump(tester, _layout());

      var previous = tester.getRect(_categoryOf(_identities.first)).top;
      for (final id in _identities.skip(1)) {
        final top = tester.getRect(_categoryOf(id)).top;
        expect(top, greaterThan(previous), reason: id);
        previous = top;
      }
    });

    testWidgets('every category is announced, open or closed', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _layout(open: const {'compte'}));

      for (final id in _identities) {
        expect(_categoryOf(id), findsOneWidget, reason: id);
        expect(
          tester.getSemantics(_categoryOf(id)).label,
          'Catégorie $id',
          reason: id,
        );
        expect(
          find.bySemanticsLabel('Catégorie $id'),
          findsOneWidget,
          reason: id,
        );
      }
      handle.dispose();
    });

    testWidgets('what a closed category holds is not hidden — it is not '
        'there at all', (tester) async {
      await _pump(tester, _layout(open: const {'compte'}));

      // What is always there stands for every category.
      for (final id in _identities) {
        expect(find.byKey(Key('summary-$id')), findsOneWidget, reason: id);
      }
      // What a category holds exists only while it is open.
      expect(find.byKey(const Key('options-compte')), findsOneWidget);
      expect(find.byKey(const Key('options-securite')), findsNothing);
      expect(find.byKey(const Key('options-notifications')), findsNothing);
      // Nothing hides anything: nothing was built to be hidden.
      for (final hiding in <Type>[
        Offstage,
        Visibility,
        Opacity,
        IndexedStack,
      ]) {
        expect(
          find.descendant(
            of: find.byKey(const Key('settings-categories')),
            matching: find.byType(hiding),
          ),
          findsNothing,
          reason: '$hiding',
        );
      }
    });

    testWidgets('what a closed category holds exists for no one: not for '
        'the focus, not for a screen reader', (tester) async {
      final handle = tester.ensureSemantics();
      final closed = FocusNode(debugLabel: 'closed');
      addTearDown(closed.dispose);

      await _pump(
        tester,
        _layout(
          categories: [
            _category(
              'securite',
              unfolded: false,
              options: Focus(
                focusNode: closed,
                child: const MentoraText(
                  'Option fermée',
                  role: MentoraTextRole.body,
                ),
              ),
            ),
          ],
        ),
      );

      // A focus node reaches the tree only when what carries it was
      // built: this one never was.
      expect(closed.context, isNull);
      expect(find.bySemanticsLabel('Option fermée'), findsNothing);
      expect(find.text('Option fermée'), findsNothing);
      handle.dispose();
    });

    testWidgets('the layout opens nothing and closes nothing: only a new '
        'announcement changes what is open', (tester) async {
      final asked = <String>[];
      await _pump(
        tester,
        _layout(
          categories: [
            _category(
              'compte',
              unfolded: false,
              summary: MentoraButton(
                key: const Key('summary-compte'),
                label: 'Compte',
                // The act belongs to the Button, and the answer to the
                // application: the layout is never in between.
                onPressed: () => asked.add('compte'),
                size: MentoraButtonSize.small,
              ),
            ),
          ],
        ),
      );

      await tester.tap(find.byKey(const Key('summary-compte')));
      await tester.pumpAndSettle();

      expect(asked, ['compte']);
      // The intention was reported; nothing opened, because nothing
      // here decides — and nothing here remembers.
      expect(find.byKey(const Key('options-compte')), findsNothing);

      await _pump(tester, _layout(open: const {'compte'}));
      expect(find.byKey(const Key('options-compte')), findsOneWidget);
    });

    testWidgets('it remembers nothing: rebuilt with the same categories '
        'closed, what was open is closed again', (tester) async {
      await _pump(tester, _layout(open: const {'securite'}));
      expect(find.byKey(const Key('options-securite')), findsOneWidget);

      await _pump(tester, _layout());
      expect(find.byKey(const Key('options-securite')), findsNothing);
    });

    testWidgets('both parts of a category are handed on strictly intact', (
      tester,
    ) async {
      await _pump(tester, _layout(open: const {'compte'}));

      expect(
        tester.getTopLeft(find.byKey(const Key('summary-compte'))),
        tester.getTopLeft(_categoryOf('compte')),
      );
      // What it holds follows what is always there, with nothing
      // inserted between them.
      expect(
        tester.getRect(find.byKey(const Key('options-compte'))).top,
        tester.getRect(find.byKey(const Key('summary-compte'))).bottom,
      );
      expect(layoutContentGap, 0);
    });

    testWidgets('it adds no room between the categories', (tester) async {
      await _pump(tester, _layout());

      var previous = tester.getRect(_categoryOf(_identities.first));
      for (final id in _identities.skip(1)) {
        final rect = tester.getRect(_categoryOf(id));
        expect(rect.top, previous.bottom, reason: id);
        previous = rect;
      }
    });

    testWidgets('it creates no scroll view and no padding of its own', (
      tester,
    ) async {
      await _pump(tester, _layout(categories: [_category('compte')]));

      expect(find.byType(Scrollable), findsNothing);
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.byType(ListView), findsNothing);
      expect(find.byType(Scrollbar), findsNothing);
      expect(find.byType(ExpansionTile), findsNothing);
      expect(find.byType(ExpansionPanelList), findsNothing);

      final page = tester.getRect(find.byType(MentoraPageScaffold));
      final category = tester.getRect(_categoryOf('compte'));
      expect(category.left, page.left);
      expect(category.width, page.width);
      expect(category.top, page.top);
    });

    testWidgets('the components stay the owners: an option is handed, '
        'never read and never judged', (tester) async {
      await _pump(
        tester,
        _layout(
          categories: [
            _category(
              'compte',
              unfolded: true,
              summary: const MentoraListTile(
                key: Key('summary-compte'),
                headline: 'Compte',
                semanticLabel: 'Compte',
              ),
              options: const MentoraCard(
                key: Key('options-compte'),
                variant: MentoraCardVariant.surface,
                child: MentoraInput(
                  label: 'Adresse électronique',
                  semanticLabel: 'Adresse électronique',
                ),
              ),
            ),
          ],
        ),
      );

      expect(find.byType(MentoraListTile), findsOneWidget);
      expect(find.byType(MentoraCard), findsOneWidget);
      expect(find.byType(MentoraInput), findsOneWidget);
      expect(find.byType(Form), findsNothing);
      expect(find.byType(TextFormField), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('what is set reaches the component alone: the layout '
        'never sees a value', (tester) async {
      final typed = <String>[];
      await _pump(
        tester,
        _layout(
          categories: [
            _category(
              'compte',
              unfolded: true,
              options: MentoraInput(
                key: const Key('options-compte'),
                label: 'Adresse électronique',
                semanticLabel: 'Adresse électronique',
                onChanged: typed.add,
              ),
            ),
          ],
        ),
      );

      await tester.enterText(find.byType(MentoraInput), 'awa@mentora.app');
      await tester.pumpAndSettle();

      expect(typed, ['awa@mentora.app']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the components keep their own announcements', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        _layout(
          categories: [
            _category(
              'compte',
              semanticLabel: 'Votre compte',
              unfolded: true,
              options: const MentoraInput(
                key: Key('options-compte'),
                label: 'Adresse électronique',
                semanticLabel: 'Adresse électronique',
              ),
            ),
          ],
        ),
      );

      expect(find.bySemanticsLabel('Votre compte'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('Adresse électronique')),
        findsWidgets,
      );
      handle.dispose();
    });

    testWidgets('every category travels as its own focus group', (
      tester,
    ) async {
      await _pump(tester, _layout(open: const {'compte'}));

      for (final id in _identities) {
        expect(
          find.descendant(
            of: _categoryOf(id),
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
          categories: [
            _category(
              'compte',
              unfolded: true,
              options: Focus(focusNode: inside, child: _optionsOf('compte')),
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

    testWidgets('the same shape carries any system: it represents no '
        'domain of the company', (tester) async {
      for (final subject in const ['premier système', 'second système']) {
        await _pump(
          tester,
          _layout(
            categories: [
              _category(
                'compte',
                semanticLabel: subject,
                summary: MentoraText(subject, role: MentoraTextRole.body),
              ),
            ],
          ),
        );

        expect(tester.takeException(), isNull, reason: subject);
        expect(find.text(subject), findsOneWidget);
      }
    });

    testWidgets('the zones of the page it asks for stay the zones of '
        'the components that own them', (tester) async {
      await _pump(
        tester,
        _layout(
          categories: [_category('compte')],
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

    testWidgets('a settings layout without a contract refuses to build — '
        'fail closed, ten times over', (tester) async {
      Future<void> refuses(Widget layout) async {
        await _pump(tester, layout);
        expect(tester.takeException(), isStateError);
      }

      // 1. A space made of no category configures nothing.
      await refuses(_layout(categories: const []));
      // 2. A category without an identity is not a category.
      await refuses(_layout(categories: [_category('')]));
      // 3. And it is refused wherever it stands: the whole list is
      //    walked, never its head alone.
      await refuses(_layout(categories: [_category('compte'), _category('')]));
      // 4. A category without a name is not a landmark.
      await refuses(
        _layout(categories: [_category('compte', semanticLabel: '')]),
      );
      // 5. Two categories never share one identity.
      await refuses(
        _layout(categories: [_category('compte'), _category('compte')]),
      );
      // 6. And identity is a set, not a comparison with the neighbour.
      await refuses(
        _layout(
          categories: [
            _category('compte'),
            _category('securite'),
            _category('compte'),
          ],
        ),
      );
      // 7. A page announces itself.
      await refuses(_layout(pageSemanticLabel: ''));
      // 8. The working context announces itself.
      await refuses(
        _layout(
          frame: const MentoraLayoutContext(
            semanticLabel: '',
            navigation: MentoraWorkspaceNavigationState(destinationId: 'home'),
          ),
        ),
      );
      // 9. Outside the Design Kit nothing is resolved.
      await tester.pumpWidget(MaterialApp(home: _layout()));
      expect(tester.takeException(), isStateError);
    });

    testWidgets('a settings layout is a whole screen: it never carries a '
        'second one — fail closed', (tester) async {
      final refusals = <Object>[];
      final reporter = FlutterError.onError;
      FlutterError.onError = (details) => refusals.add(details.exception);
      await _pump(
        tester,
        _layout(
          categories: [_category('compte', unfolded: true, options: _layout())],
        ),
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
        await _pump(tester, _layout(open: const {'compte'}), variant: variant);
        expect(tester.takeException(), isNull, reason: variant.name);
        expect(_categoryOf('compte'), findsOneWidget);
      }
    });

    testWidgets('it holds at every font scale', (tester) async {
      for (final scale in FontScalePreference.values) {
        await _pump(
          tester,
          _layout(categories: [_category('compte', unfolded: true)]),
          appearance: AppearanceState(fontScale: scale),
        );
        expect(tester.takeException(), isNull, reason: scale.name);
        expect(_categoryOf('compte'), findsOneWidget);
      }
    });

    testWidgets('it holds at every reading comfort', (tester) async {
      for (final comfort in ReadingComfortPreference.values) {
        await _pump(
          tester,
          _layout(open: const {'compte'}),
          appearance: AppearanceState(readingComfort: comfort),
        );
        expect(tester.takeException(), isNull, reason: comfort.name);
      }
    });

    testWidgets('it holds in both reading directions, and a category '
        'still takes the whole width', (tester) async {
      for (final direction in TextDirection.values) {
        await _pump(tester, _layout(), direction: direction);
        expect(tester.takeException(), isNull, reason: direction.name);
        expect(
          tester.getRect(_categoryOf('compte')).width,
          tester.getRect(find.byType(MentoraPageScaffold)).width,
          reason: direction.name,
        );
      }
    });

    testWidgets('every transition still comes from the Motion Engine: '
        'None silences it', (tester) async {
      await _pump(
        tester,
        _layout(open: const {'compte'}),
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

    Iterable<File> settingsFiles() =>
        dartFilesOf('lib/foundation/design_kit/layout/settings_layout');

    void refuse(Map<String, RegExp> forbidden, String because) {
      final files = settingsFiles().toList();
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

    test('a settings layout stores nothing and remembers nothing', () {
      refuse({
        'a storage': RegExp(
          r'(?<![A-Za-z])(SharedPreferences|Hive|SecureStorage|localStorage|'
          r'Firestore|HttpClient|http|Cache|Box)\s*[(.<]',
        ),
        'a persistence': RegExp(
          r'(?<![A-Za-z])(save|persist|write|store|load|fetch|read|sync)'
          r'\s*[(<]',
        ),
        'a state of its own': RegExp(
          r'(?<![A-Za-z])(StatefulWidget|setState|initState|ValueNotifier|'
          r'ChangeNotifier|StreamBuilder|FutureBuilder)(?![A-Za-z])',
        ),
        'a promise': RegExp(
          r'(?<![A-Za-z])(Future|Stream|async|await)(?![A-Za-z])',
        ),
      }, 'it never carries');
    });

    test('a settings layout validates nothing and judges nothing', () {
      refuse({
        'a framework form': RegExp(
          r'(?<![A-Za-z])(Form|FormField|TextFormField|FormState|'
          r'AutovalidateMode|InputDecoration)\s*[(.<>]',
        ),
        'a validation': RegExp(
          r'(validator:|autovalidate|\.validate\(|\.save\(|GlobalKey<)',
        ),
        'a judgement of a value': RegExp(
          r'(?<![A-Za-z])(isValid|isAllowed|permission|granted|denied|'
          r'defaultValue|preference|setting)\s*[:.(=]',
        ),
      }, 'it never carries');
    });

    test('a settings layout unfolds nothing by itself, and calculates '
        'nothing', () {
      refuse({
        'a disclosure of the framework': RegExp(
          r'(?<![A-Za-z])(ExpansionTile|ExpansionPanel|ExpansionPanelList|'
          r'Accordion|Stepper|AnimatedSize|AnimatedContainer|'
          r'AnimatedCrossFade)\s*[(.<]',
        ),
        'a scroll view or a collection': RegExp(
          r'(?<![A-Za-z])(Scrollable|ScrollView|SingleChildScrollView|'
          r'CustomScrollView|ListView|GridView|Scrollbar|Sliver\w*)'
          r'\s*[(.<]',
        ),
        'a rank': RegExp(
          r'(?<![A-Za-z])(index|indexOf|elementAt|selectedIndex)\s*[:.(=]',
        ),
        'a count or an arithmetic': RegExp(
          r'(\.length|~/|\.ceil\(|\.floor\(|\.round\()',
        ),
      }, 'it never carries');
    });

    test('a settings layout knows no business, no measure, no platform '
        'and codes no value', () {
      refuse({
        'a model': RegExp(
          r'(?<![A-Za-z])(User|Product|Wallet|Expert|Consultation|Invoice|'
          r'Business|Account|Profile|Entity|Model|Repository)(?![a-z])',
        ),
        'a room of its own': RegExp(
          r'(?<![A-Za-z])(Padding|SafeArea|Expanded|Flexible|Spacer|Wrap|'
          r'Flow)\s*[(.<]',
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
        'an untyped value': RegExp(
          r'(?<![A-Za-z])(dynamic|Object\?)(?![A-Za-z])',
        ),
        'an untyped part': RegExp(r'final\s+Widget\?\s'),
      }, 'it never carries');
    });

    test('one settings layout exists in the whole product, it extends '
        'the page-like foundation, and it builds nothing at all', () {
      final declarations = <String>[];
      for (final file in dartFilesOf('lib')) {
        if (RegExp(
          r'class\s+MentoraSettingsLayout(?![A-Za-z])',
        ).hasMatch(file.readAsStringSync())) {
          declarations.add(file.path.replaceAll(r'\', '/'));
        }
      }
      expect(declarations, hasLength(1));
      expect(declarations.single, contains('layout/settings_layout/'));

      final source = codeOf(File(declarations.single));
      expect(
        RegExp(r'extends\s+MentoraPageLikeLayout(?![A-Za-z])').hasMatch(source),
        isTrue,
      );
      expect(RegExp(r'Widget\s+build\(').hasMatch(source), isFalse);
      for (final built in const [
        'MentoraWorkspace(',
        'MentoraPageScaffold(',
        'MentoraCard(',
        'MentoraInput(',
        'MentoraButton(',
        'MentoraListTile(',
        'Column(',
        'Semantics(',
        'FocusTraversalGroup(',
        'KeyedSubtree(',
      ]) {
        expect(source.contains(built), isFalse, reason: built);
      }
    });

    test('the category of a configuration space is declared once, and '
        'no shape holds a second one', () {
      final declarations = <String>[];
      for (final file in dartFilesOf('lib')) {
        if (RegExp(
          r'class\s+\w*SettingsCategory(?![A-Za-z])',
        ).hasMatch(file.readAsStringSync())) {
          declarations.add(file.path.replaceAll(r'\', '/'));
        }
      }
      expect(declarations, hasLength(1));
      expect(
        declarations.single,
        endsWith('layout/foundation/mentora_layout_style.dart'),
      );
    });

    test('every landmark of the layer is announced the same way, in one '
        'place: no disposition announces on its own', () {
      // The announcement — a container, its explicit children and its
      // name — and the absence of room between what is placed both
      // belong to the assembly, and to one method of it each.
      final assembly = codeOf(
        File(
          'lib/foundation/design_kit/layout/foundation/'
          'mentora_layout_assembly.dart',
        ),
      );
      expect(
        RegExp(r'explicitChildNodes:\s*true').allMatches(assembly),
        hasLength(1),
      );
      expect(
        RegExp(r'FocusTraversalGroup\(').allMatches(assembly),
        hasLength(1),
      );
      // Every room the layer leaves comes from the Token, wherever it
      // is applied: the vertical disposition applies it once for all,
      // and the one row of a grid is the only other place it appears.
      expect(
        RegExp(r'spacing:\s*').allMatches(assembly).length,
        RegExp(r'spacing:\s*theme\.contentGap').allMatches(assembly).length,
      );
    });
  });
}
