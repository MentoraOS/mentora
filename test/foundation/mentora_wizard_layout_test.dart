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
import 'package:mentora/foundation/design_kit/components/input/mentora_input.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text_role.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_context.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_kind.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_style.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_page_like_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_revealed_layout.dart';
import 'package:mentora/foundation/design_kit/layout/wizard_layout/mentora_wizard_layout.dart';
import 'package:mentora/foundation/design_kit/motion/motion_engine.dart';
import 'package:mentora/foundation/design_kit/registry/token_engines.dart';
import 'package:mentora/foundation/design_kit/structure/app_bar/mentora_app_bar.dart';
import 'package:mentora/foundation/design_kit/structure/page_scaffold/mentora_page_scaffold.dart';
import 'package:mentora/foundation/design_kit/structure/workspace/mentora_workspace.dart';
import 'package:mentora/foundation/design_kit/theme/theme_engine.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';
import 'package:mentora/foundation/design_kit/tokens/surface_elevation_tokens.dart';

/// What the application owns — recognisable, already built, and never
/// touched by the layout that organises the work.
Widget _content(String id) => MentoraText(
  'Contenu $id',
  key: Key('step-$id'),
  role: MentoraTextRole.body,
);

MentoraIdentifiedContent _step(String id, {Widget? content}) =>
    MentoraIdentifiedContent(id: id, content: content ?? _content(id));

const List<String> _identities = ['identite', 'coordonnees', 'confirmation'];

const MentoraLayoutContext _frame = MentoraLayoutContext(
  semanticLabel: 'Contexte de travail',
  navigation: MentoraNavigationAnnouncement(destinationId: 'home'),
);

MentoraWizardLayout _layout({
  MentoraLayoutContext frame = _frame,
  String pageSemanticLabel = 'Page courante',
  String wizardId = 'inscription',
  String wizardSemanticLabel = 'Le travail à faire',
  String revealedStepId = 'identite',
  List<MentoraIdentifiedContent>? steps,
  MentoraAppBar? place,
  List<MentoraButton> acts = const [],
}) {
  return MentoraWizardLayout(
    frame: frame,
    pageSemanticLabel: pageSemanticLabel,
    wizardId: wizardId,
    wizardSemanticLabel: wizardSemanticLabel,
    revealedStepId: revealedStepId,
    steps: steps ?? [for (final id in _identities) _step(id)],
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

Finder _work() => find.byKey(const Key('tabbed-inscription'));

void main() {
  group('MentoraWizardLayout — a work cut into steps', () {
    testWidgets('it is a specialization of the one foundation, through '
        'the revealing foundation, and the registry knows its shape', (
      tester,
    ) async {
      expect(_layout(), isA<MentoraLayout>());
      expect(_layout(), isA<MentoraPageLikeLayout>());
      expect(_layout(), isA<MentoraRevealedLayout>());
      expect(_layout().kind, MentoraLayoutKind.wizard);

      await _pump(tester, _layout());
      expect(find.byKey(const Key('layout-wizard')), findsOneWidget);
      expect(find.byType(MentoraWorkspace), findsOneWidget);
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
    });

    test('the words of a work are aliases over the one holder: there is '
        'no second field anywhere', () {
      final steps = [for (final id in _identities) _step(id)];
      final layout = _layout(steps: steps, revealedStepId: 'coordonnees');

      expect(layout.wizardId, 'inscription');
      expect(layout.wizardId, layout.contextId);
      expect(layout.wizardSemanticLabel, layout.contextSemanticLabel);
      expect(layout.steps, same(steps));
      expect(layout.steps, same(layout.contents));
      expect(layout.revealedStepId, 'coordonnees');
      expect(layout.revealedStepId, layout.revealedContentId);
    });

    testWidgets('a step is an IDENTITY: the work reveals the one that '
        'was announced, whatever its rank', (tester) async {
      for (final id in _identities) {
        await _pump(tester, _layout(revealedStepId: id));

        expect(tester.takeException(), isNull, reason: id);
        expect(find.byKey(Key('step-$id')), findsOneWidget, reason: id);
      }
    });

    testWidgets('a step is never a position: announcing the same '
        'identity in another order reveals the very same step', (tester) async {
      await _pump(tester, _layout(revealedStepId: 'confirmation'));
      final placed = tester.getRect(find.byKey(const Key('step-confirmation')));

      await _pump(
        tester,
        _layout(
          revealedStepId: 'confirmation',
          steps: [for (final id in _identities.reversed) _step(id)],
        ),
      );

      expect(find.byKey(const Key('step-confirmation')), findsOneWidget);
      expect(
        tester.getRect(find.byKey(const Key('step-confirmation'))),
        placed,
      );
    });

    testWidgets('exactly one step is revealed, and the others are not '
        'hidden — they are absent', (tester) async {
      await _pump(tester, _layout(revealedStepId: 'coordonnees'));

      expect(find.byKey(const Key('step-coordonnees')), findsOneWidget);
      expect(find.byKey(const Key('step-identite')), findsNothing);
      expect(find.byKey(const Key('step-confirmation')), findsNothing);
      // Nothing hides anything: what is not revealed was never built.
      // Scoped to what the LAYOUT places — a composed structure owns
      // its own internals, and they are none of this shape's business.
      for (final hiding in <Type>[
        Offstage,
        Visibility,
        Opacity,
        IndexedStack,
        AnimatedSwitcher,
        AnimatedCrossFade,
        PageView,
      ]) {
        expect(
          find.descendant(of: _work(), matching: find.byType(hiding)),
          findsNothing,
          reason: '$hiding',
        );
      }
    });

    testWidgets('a step that is not revealed exists for no one: not for '
        'the focus, not for a screen reader', (tester) async {
      final handle = tester.ensureSemantics();
      final absent = FocusNode(debugLabel: 'absent');
      addTearDown(absent.dispose);

      await _pump(
        tester,
        _layout(
          revealedStepId: 'identite',
          steps: [
            _step('identite'),
            _step(
              'coordonnees',
              content: Focus(
                focusNode: absent,
                child: const MentoraText(
                  'Étape absente',
                  role: MentoraTextRole.body,
                ),
              ),
            ),
          ],
        ),
      );

      // A focus node only reaches the tree when what carries it was
      // built: this one never was, so it stands nowhere at all.
      expect(absent.context, isNull);
      expect(find.bySemanticsLabel('Étape absente'), findsNothing);
      expect(find.text('Étape absente'), findsNothing);
      handle.dispose();
    });

    testWidgets('the content of the revealed step is handed on strictly '
        'intact', (tester) async {
      await _pump(tester, _layout());

      expect(
        tester.getTopLeft(find.byKey(const Key('step-identite'))),
        tester.getTopLeft(_work()),
      );
    });

    testWidgets('the work reports an intention, and decides nothing: '
        'what is revealed does not move on its own', (tester) async {
      final asked = <String>[];
      await _pump(
        tester,
        _layout(
          revealedStepId: 'identite',
          acts: [
            MentoraButton(
              key: const Key('act-continuer'),
              label: 'Continuer',
              // The act belongs to the Button, and the answer to the
              // application: the layout is never in between.
              onPressed: () => asked.add('coordonnees'),
              size: MentoraButtonSize.small,
            ),
          ],
        ),
      );

      await tester.tap(find.byKey(const Key('act-continuer')));
      await tester.pumpAndSettle();

      expect(asked, ['coordonnees']);
      // The intention was reported; nothing moved, because nothing here
      // decides. Only a new announcement changes what is revealed.
      expect(find.byKey(const Key('step-identite')), findsOneWidget);
      expect(find.byKey(const Key('step-coordonnees')), findsNothing);

      await _pump(tester, _layout(revealedStepId: 'coordonnees'));
      expect(find.byKey(const Key('step-coordonnees')), findsOneWidget);
    });

    testWidgets('it announces no progression: the work is a landmark and '
        'says nothing of a total, a rank or a remainder', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _layout(revealedStepId: 'coordonnees'));

      final spoken = tester.getSemantics(_work()).label;
      expect(spoken, 'Le travail à faire');
      for (final counted in const ['2', '3', '/', '%', 'sur']) {
        expect(spoken.contains(counted), isFalse, reason: counted);
      }
      handle.dispose();
    });

    testWidgets('it creates no scroll view and no room of its own', (
      tester,
    ) async {
      await _pump(tester, _layout());

      expect(find.byType(Scrollable), findsNothing);
      expect(find.byType(SingleChildScrollView), findsNothing);

      final page = tester.getRect(find.byType(MentoraPageScaffold));
      final work = tester.getRect(_work());
      expect(work.left, page.left);
      expect(work.width, page.width);
      expect(work.top, page.top);
    });

    testWidgets('the components stay the owners of what a step holds', (
      tester,
    ) async {
      await _pump(
        tester,
        _layout(
          steps: [
            _step(
              'identite',
              content: const MentoraCard(
                key: Key('step-identite'),
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

      expect(find.byType(MentoraCard), findsOneWidget);
      expect(find.byType(MentoraInput), findsOneWidget);
      expect(find.byType(Form), findsNothing);
      expect(find.byType(TextFormField), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('what is typed in a step reaches the component alone', (
      tester,
    ) async {
      final typed = <String>[];
      await _pump(
        tester,
        _layout(
          steps: [
            _step(
              'identite',
              content: MentoraInput(
                key: const Key('step-identite'),
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

    testWidgets('the same shape carries any work: it represents no '
        'domain of the company', (tester) async {
      for (final subject in const ['premier travail', 'second travail']) {
        await _pump(
          tester,
          _layout(
            wizardSemanticLabel: subject,
            steps: [
              _step(
                'identite',
                content: MentoraText(subject, role: MentoraTextRole.body),
              ),
            ],
          ),
        );

        expect(tester.takeException(), isNull, reason: subject);
        expect(find.text(subject), findsOneWidget);
      }
    });

    testWidgets('the work is a landmark, announced exactly once', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _layout());

      expect(tester.getSemantics(_work()).label, 'Le travail à faire');
      expect(find.bySemanticsLabel('Le travail à faire'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('the revealed step travels as its own focus group', (
      tester,
    ) async {
      await _pump(tester, _layout());

      expect(
        find.descendant(
          of: _work(),
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
          steps: [
            _step(
              'identite',
              content: Focus(focusNode: inside, child: _content('identite')),
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

    testWidgets('a wizard layout without a contract refuses to build — '
        'fail closed, ten times over', (tester) async {
      Future<void> refuses(Widget layout) async {
        await _pump(tester, layout);
        expect(tester.takeException(), isStateError);
      }

      // 1. A work without an identity is not one.
      await refuses(_layout(wizardId: ''));
      // 2. A work without a name is not a landmark.
      await refuses(_layout(wizardSemanticLabel: ''));
      // 3. A work cut into no step is not cut into steps.
      await refuses(_layout(steps: const []));
      // 4. A work is told which step it is on.
      await refuses(_layout(revealedStepId: ''));
      // 5. A step without an identity is not a step.
      await refuses(_layout(steps: [_step('')]));
      // 6. Two steps never share one identity.
      await refuses(_layout(steps: [_step('identite'), _step('identite')]));
      // 7. A work never guesses which step to show.
      await refuses(_layout(revealedStepId: 'ailleurs'));
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

    testWidgets('a wizard is a whole screen: it never carries a second '
        'one — fail closed', (tester) async {
      final refusals = <Object>[];
      final reporter = FlutterError.onError;
      FlutterError.onError = (details) => refusals.add(details.exception);
      await _pump(
        tester,
        _layout(steps: [_step('identite', content: _layout())]),
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
        expect(_work(), findsOneWidget);
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
        expect(_work(), findsOneWidget);
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

    testWidgets('it holds in both reading directions, and the work still '
        'takes the whole width', (tester) async {
      for (final direction in TextDirection.values) {
        await _pump(tester, _layout(), direction: direction);
        expect(tester.takeException(), isNull, reason: direction.name);
        expect(
          tester.getRect(_work()).width,
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

    /// The shape AND the foundations it is built on: the machinery
    /// lives there, so the scans follow it.
    Iterable<File> wizardFiles() => [
      ...dartFilesOf('lib/foundation/design_kit/layout/wizard_layout'),
      File(
        'lib/foundation/design_kit/layout/foundation/'
        'mentora_revealed_layout.dart',
      ),
      File(
        'lib/foundation/design_kit/layout/foundation/'
        'mentora_page_like_layout.dart',
      ),
    ];

    /// What a file COMMITS.
    ///
    /// A scan opposes code, and a comment is not code: documenting a
    /// prohibition has never been committing it. Stripping the prose
    /// once is the general form of that principle — it lets every rule
    /// below stay as tight as it needs to be, without a sentence ever
    /// being able to trip one.
    String codeOf(File file) => file
        .readAsLinesSync()
        .map((line) {
          final comment = line.indexOf('//');
          return comment == -1 ? line : line.substring(0, comment);
        })
        .join('\n');

    void refuse(Map<String, RegExp> forbidden, String because) {
      final files = wizardFiles().toList();
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

    test('a wizard counts nothing: no progression, and no calculation', () {
      // Structural, never lexical: a progression is recognised by the
      // way code USES one — the prose may name what code may not carry.
      refuse({
        'a progression': RegExp(
          r'(?<![A-Za-z])(progress\w*|percent\w*|ratio|total|remaining|'
          r'completed|currentStep|stepCount|selectedIndex|activeIndex)'
          r'\s*[:.(=]',
        ),
        'a rank': RegExp(
          r'(?<![A-Za-z])(index|indexOf|elementAt|first|last)\s*[:.(=]',
        ),
        'a count of what it holds': RegExp(r'\.length'),
        'an arithmetic': RegExp(r'(~/|\s/\s|\.ceil\(|\.floor\(|\.round\()'),
      }, 'it never carries');
    });

    test('a wizard validates nothing and holds no form', () {
      refuse({
        'a framework step': RegExp(
          r'(?<![A-Za-z])(Stepper|Step|StepState|Workflow)\s*[(.<]',
        ),
        'a framework form': RegExp(
          r'(?<![A-Za-z])(Form|FormField|TextFormField|FormState|'
          r'AutovalidateMode|InputDecoration)\s*[(.<>]',
        ),
        'a validation': RegExp(
          r'(validator:|autovalidate|\.validate\(|\.save\(|GlobalKey<)',
        ),
      }, 'it never carries');
    });

    test('a wizard hides nothing: what is not revealed is not built', () {
      refuse({
        'a way of hiding': RegExp(
          r'(?<![A-Za-z])(Offstage|Visibility|Opacity|IndexedStack|Stack|'
          r'AnimatedSwitcher|AnimatedCrossFade|Hero)\s*[(.<]',
        ),
        'a way through': RegExp(
          r'(?<![A-Za-z])(PageView|PageController|TabController|'
          r'ScrollController)\s*[(.<]',
        ),
      }, 'it never carries');
    });

    test('a wizard knows no data, no network and no state of the work', () {
      refuse({
        'a model': RegExp(
          r'(?<![A-Za-z])(User|Product|Wallet|Expert|Consultation|Invoice|'
          r'Business|Account|Profile|Entity|Model)(?![a-z])',
        ),
        'a source of data': RegExp(
          r'(?<![A-Za-z])(Repository|Provider|Bloc|Cubit|Riverpod|Redux|'
          r'GetX|MobX|ChangeNotifier|StreamBuilder|FutureBuilder)'
          r'(?![A-Za-z])',
        ),
        'a network or a promise': RegExp(
          r'(?<![A-Za-z])(http|HttpClient|Firestore|Future|Stream|async|'
          r'await)(?![A-Za-z])',
        ),
        'a state of the work': RegExp(
          r'(?<![A-Za-z])(loading|error|success|offline|processing|'
          r'waiting|isValid|isDirty|isSubmitting)(?![A-Za-z])',
        ),
        'an untyped value': RegExp(
          r'(?<![A-Za-z])(dynamic|Object\?)(?![A-Za-z])',
        ),
        'an untyped step': RegExp(r'final\s+Widget\?\s'),
      }, 'it never carries');
    });

    test('a wizard builds no framework widget, measures nothing and '
        'navigates nowhere', () {
      refuse({
        'a room of its own': RegExp(
          r'(?<![A-Za-z])(Padding|SafeArea|Expanded|Flexible|Spacer|Wrap|'
          r'Flow)\s*[(.<]',
        ),
        'a scroll view or a collection': RegExp(
          r'(?<![A-Za-z])(Scrollable|ScrollView|SingleChildScrollView|'
          r'ListView|GridView|Sliver\w*)\s*[(.<]',
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

    test('one wizard layout exists in the whole product, it extends the '
        'revealing foundation, and it declares nothing else', () {
      final declarations = <String>[];
      for (final file in dartFilesOf('lib')) {
        if (RegExp(
          r'class\s+MentoraWizardLayout(?![A-Za-z])',
        ).hasMatch(file.readAsStringSync())) {
          declarations.add(file.path.replaceAll(r'\', '/'));
        }
      }
      expect(declarations, hasLength(1));
      expect(declarations.single, contains('layout/wizard_layout/'));

      final source = codeOf(File(declarations.single));
      expect(
        RegExp(r'extends\s+MentoraRevealedLayout(?![A-Za-z])').hasMatch(source),
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
      for (final built in const [
        'MentoraWorkspace(',
        'MentoraPageScaffold(',
        'MentoraCard(',
        'MentoraButton(',
        'MentoraInput(',
        'Column(',
        'Semantics(',
        'FocusTraversalGroup(',
        'KeyedSubtree(',
      ]) {
        expect(source.contains(built), isFalse, reason: built);
      }
    });

    test('no duplication was introduced: every shape that reveals one '
        'thing among several owns nothing of how it is revealed', () {
      final shapes = <String>[];
      for (final file in dartFilesOf('lib')) {
        final source = codeOf(file);
        if (!RegExp(
          r'extends\s+MentoraRevealedLayout(?![A-Za-z])',
        ).hasMatch(source)) {
          continue;
        }
        shapes.add(file.path.replaceAll(r'\', '/'));
        for (final owned in const [
          r'MentoraLayoutSurface\.',
          r'void\s+verify\(',
          r'final\s+List<MentoraIdentifiedContent>',
          r'final\s+String\s+context',
        ]) {
          expect(
            RegExp(owned).hasMatch(source),
            isFalse,
            reason: '$file: the revealing foundation owns $owned',
          );
        }
      }
      // More than one shape reveals, and the machinery exists once.
      expect(shapes.length, greaterThan(1));
    });

    test('the page a shape is handed is declared in exactly one place', () {
      // The five parts of a page belonged to every page-shaped
      // specialization; they belong to the page-like foundation now,
      // and no shape may declare one of them again.
      final parts = RegExp(
        r'final\s+(MentoraAppBar\?\s+place|MentoraTabs\??\s+facets|'
        r'MentoraSearchBar\?\s+intention|List<MentoraButton>\s+acts|'
        r'String\s+pageSemanticLabel)\s*;',
      );
      final holders = <String>[];
      for (final file in dartFilesOf('lib/foundation/design_kit/layout')) {
        final source = codeOf(file);
        // Only LAYOUTS are opposed here. What the assembly holds, it
        // holds in order to BUILD it; what the style file holds — the
        // acts offered on one panel, for instance — is another concept
        // entirely, and neither of them is a layout.
        if (!RegExp(r'class\s+\w*Layout(?![A-Za-z])').hasMatch(source)) {
          continue;
        }
        if (parts.hasMatch(source)) {
          holders.add(file.path.replaceAll(r'\', '/'));
        }
      }
      expect(holders, hasLength(1));
      expect(
        holders.single,
        endsWith('layout/foundation/mentora_page_like_layout.dart'),
      );
    });
  });
}
