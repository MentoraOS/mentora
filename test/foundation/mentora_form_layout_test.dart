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
import 'package:mentora/foundation/design_kit/components/input/mentora_input.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text_role.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_context.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_kind.dart';
import 'package:mentora/foundation/design_kit/layout/foundation/mentora_layout_style.dart';
import 'package:mentora/foundation/design_kit/layout/form_layout/mentora_form_layout.dart';
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
/// touched by the layout that organises the work.
Widget _content(String id) => MentoraText(
  'Contenu $id',
  key: Key('zone-$id'),
  role: MentoraTextRole.body,
);

MentoraFormZone _zone(String id, {String? semanticLabel, Widget? content}) =>
    MentoraFormZone(
      semanticLabel: semanticLabel ?? 'Région $id',
      content: content ?? _content(id),
    );

const MentoraLayoutContext _frame = MentoraLayoutContext(
  semanticLabel: 'Contexte de travail',
  navigation: MentoraWorkspaceNavigationState(destinationId: 'home'),
);

MentoraFormLayout _layout({
  MentoraLayoutContext frame = _frame,
  String pageSemanticLabel = 'Page courante',
  MentoraFormZone? form,
  bool complete = true,
  MentoraFormZone? header,
  MentoraFormZone? introduction,
  MentoraFormZone? supportingContent,
  MentoraFormZone? actions,
  MentoraFormZone? footer,
  MentoraAppBar? place,
  List<MentoraButton> acts = const [],
}) {
  return MentoraFormLayout(
    frame: frame,
    pageSemanticLabel: pageSemanticLabel,
    place: place,
    acts: acts,
    header: header ?? (complete ? _zone('header') : null),
    introduction: introduction ?? (complete ? _zone('introduction') : null),
    form: form ?? _zone('form'),
    supportingContent:
        supportingContent ?? (complete ? _zone('supportingContent') : null),
    actions: actions ?? (complete ? _zone('actions') : null),
    footer: footer ?? (complete ? _zone('footer') : null),
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

Finder _regionOf(MentoraFormRegion region) =>
    find.byKey(Key('content-region-${region.name}'));

void main() {
  group('MentoraFormLayout — the context of the work of filling in', () {
    testWidgets('it is a specialization of the one foundation, and the '
        'registry knows its shape', (tester) async {
      expect(_layout(), isA<MentoraLayout>());
      expect(_layout().kind, MentoraLayoutKind.form);

      await _pump(tester, _layout());
      expect(find.byKey(const Key('layout-form')), findsOneWidget);
      expect(find.byType(MentoraWorkspace), findsOneWidget);
      expect(find.byType(MentoraPageScaffold), findsOneWidget);
    });

    testWidgets('it asks the assembly for the single disposition: it '
        'arranges nothing itself', (tester) async {
      await _pump(tester, _layout());

      expect(find.byKey(const Key('content-regions')), findsOneWidget);
      for (final region in MentoraFormRegion.values) {
        expect(_regionOf(region), findsOneWidget, reason: region.name);
      }
    });

    testWidgets('the official order is the order read, and it is the '
        'vocabulary itself', (tester) async {
      await _pump(tester, _layout());

      var previous = tester.getRect(_regionOf(MentoraFormRegion.header)).top;
      for (final region in MentoraFormRegion.values.skip(1)) {
        final top = tester.getRect(_regionOf(region)).top;
        expect(top, greaterThan(previous), reason: region.name);
        previous = top;
      }
      // The vocabulary is closed, and it is the order.
      expect(MentoraFormRegion.values.map((region) => region.name).toList(), [
        'header',
        'introduction',
        'form',
        'supportingContent',
        'actions',
        'footer',
      ]);
    });

    testWidgets('a form is the only region the work cannot do without', (
      tester,
    ) async {
      await _pump(tester, _layout(complete: false));

      expect(_regionOf(MentoraFormRegion.form), findsOneWidget);
      for (final region in MentoraFormRegion.values) {
        if (region == MentoraFormRegion.form) continue;
        expect(_regionOf(region), findsNothing, reason: region.name);
      }
      // What was not given is not there at all, and what remains still
      // starts at the very edge of the page.
      expect(
        tester.getTopLeft(_regionOf(MentoraFormRegion.form)),
        tester.getTopLeft(find.byType(MentoraPageScaffold)),
      );
    });

    testWidgets('the identity of a region is the official region: a '
        'product never names one', (tester) async {
      await _pump(tester, _layout());

      expect(find.byKey(const Key('content-region-form')), findsOneWidget);
      expect(find.byKey(const Key('content-region-ailleurs')), findsNothing);
    });

    testWidgets('the content of every region is handed on strictly '
        'intact', (tester) async {
      await _pump(tester, _layout());

      for (final region in MentoraFormRegion.values) {
        expect(
          tester.getTopLeft(find.byKey(Key('zone-${region.name}'))),
          tester.getTopLeft(_regionOf(region)),
          reason: region.name,
        );
      }
    });

    testWidgets('it adds no room between the regions of the work', (
      tester,
    ) async {
      await _pump(tester, _layout());

      var previous = tester.getRect(_regionOf(MentoraFormRegion.header));
      for (final region in MentoraFormRegion.values.skip(1)) {
        final rect = tester.getRect(_regionOf(region));
        expect(rect.top, previous.bottom, reason: region.name);
        previous = rect;
      }
      expect(layoutContentGap, 0);
    });

    testWidgets('the components stay the owners: the input owns what is '
        'typed, the button owns the act', (tester) async {
      await _pump(
        tester,
        _layout(
          form: _zone(
            'form',
            content: const MentoraInput(
              key: Key('zone-form'),
              label: 'Adresse électronique',
              semanticLabel: 'Adresse électronique',
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

      expect(find.byType(MentoraInput), findsOneWidget);
      expect(find.byType(MentoraButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('what is typed reaches the component alone: the layout '
        'never sees a value', (tester) async {
      final typed = <String>[];
      await _pump(
        tester,
        _layout(
          form: _zone(
            'form',
            content: MentoraInput(
              key: const Key('zone-form'),
              label: 'Adresse électronique',
              semanticLabel: 'Adresse électronique',
              onChanged: typed.add,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(MentoraInput), 'awa@mentora.app');
      await tester.pumpAndSettle();

      expect(typed, ['awa@mentora.app']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('it validates nothing and submits nothing: no framework '
        'form exists anywhere in the tree', (tester) async {
      await _pump(tester, _layout());

      expect(find.byType(Form), findsNothing);
      expect(find.byType(TextFormField), findsNothing);
    });

    testWidgets('it creates no scroll view and no padding of its own', (
      tester,
    ) async {
      await _pump(tester, _layout());

      expect(find.byType(Scrollable), findsNothing);
      expect(find.byType(SingleChildScrollView), findsNothing);

      final page = tester.getRect(find.byType(MentoraPageScaffold));
      final header = tester.getRect(_regionOf(MentoraFormRegion.header));
      expect(header.left, page.left);
      expect(header.width, page.width);
      expect(header.top, page.top);
    });

    testWidgets('every region is a landmark, announced exactly once', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _layout());

      for (final region in MentoraFormRegion.values) {
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
          form: _zone(
            'form',
            semanticLabel: 'Vos informations',
            content: const MentoraInput(
              key: Key('zone-form'),
              label: 'Adresse électronique',
              semanticLabel: 'Adresse électronique',
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Vos informations'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('Adresse électronique')),
        findsWidgets,
      );
      handle.dispose();
    });

    testWidgets('every region travels as its own focus group', (tester) async {
      await _pump(tester, _layout());

      for (final region in MentoraFormRegion.values) {
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
      final inside = FocusNode(debugLabel: 'field');
      addTearDown(inside.dispose);

      await _pump(
        tester,
        _layout(
          form: _zone(
            'form',
            content: Focus(focusNode: inside, child: _content('form')),
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

    testWidgets('a form layout without a contract refuses to build — '
        'fail closed', (tester) async {
      Future<void> refuses(Widget layout) async {
        await _pump(tester, layout);
        expect(tester.takeException(), isStateError);
      }

      // A region without a name, wherever it stands.
      await refuses(_layout(form: _zone('form', semanticLabel: '')));
      await refuses(_layout(header: _zone('header', semanticLabel: '')));
      await refuses(_layout(footer: _zone('footer', semanticLabel: '')));
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

    testWidgets('it holds in the four themes', (tester) async {
      for (final variant in ThemeVariantId.values) {
        await _pump(tester, _layout(), variant: variant);
        expect(tester.takeException(), isNull, reason: variant.name);
        expect(_regionOf(MentoraFormRegion.form), findsOneWidget);
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
        expect(_regionOf(MentoraFormRegion.form), findsOneWidget);
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
          tester.getRect(_regionOf(MentoraFormRegion.form)).width,
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

    Iterable<File> formFiles() =>
        dartFilesOf('lib/foundation/design_kit/layout/form_layout');

    test('a form layout validates nothing and submits nothing', () {
      // Structural, never lexical: a type USED carries a constructor,
      // a member or a type argument behind it, and a parameter carries
      // its colon — the prose may name what the code may not carry.
      final forbidden = <String, RegExp>{
        'a framework form': RegExp(
          r'(?<![A-Za-z])(Form|FormField|TextFormField|FormState|'
          r'AutovalidateMode|InputDecoration)\s*[(.<>]',
        ),
        'a validation': RegExp(
          r'(validator:|autovalidate|\.validate\(|\.save\(|'
          r'GlobalKey<)',
        ),
        'a submission': RegExp(
          r'(?<![A-Za-z])(submit|onSubmit|login|register|payment|'
          r'authenticate)(?![a-z])',
        ),
        'a network': RegExp(
          r'(?<![A-Za-z])(http|HttpClient|Firestore|Dio|WebSocket)'
          r'(?![A-Za-z])',
        ),
      };
      final files = formFiles();
      expect(files, isNotEmpty);
      for (final file in files) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: the form belongs to the components — a '
                'layout never carries ${entry.key}',
          );
        }
      }
    });

    test('a form layout knows no model, no business and no state of the '
        'work', () {
      final forbidden = <String, RegExp>{
        'a model': RegExp(
          r'(?<![A-Za-z])(User|Wallet|Product|Expert|Consultation|'
          r'Business|Invoice|Payment|Account|Profile|Model|Repository|'
          r'Entity|fromJson|toJson)(?![a-z])',
        ),
        'a state of the work': RegExp(
          r'(?<![A-Za-z])(loading|error|success|offline|processing|'
          r'waiting|isValid|isDirty|isSubmitting)(?![A-Za-z])',
        ),
        'an untyped value': RegExp(
          r'(?<![A-Za-z])(dynamic|Object\?)(?![A-Za-z])',
        ),
        'an untyped zone': RegExp(r'final\s+Widget\?\s'),
      };
      for (final file in formFiles()) {
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

    test('a form layout builds no framework widget, measures nothing '
        'and navigates nowhere', () {
      final forbidden = <String, RegExp>{
        'a padding': RegExp(r'(?<![A-Za-z])Padding\('),
        'a safe area': RegExp(r'(?<![A-Za-z])SafeArea\('),
        'a decorative box': RegExp(
          r'(?<![A-Za-z])(Container|DecoratedBox|ColoredBox)\(',
        ),
        'a flexible space': RegExp(
          r'(?<![A-Za-z])(Expanded|Flexible|Spacer)\s*[(.<]',
        ),
        'a scroll view or a collection': RegExp(
          r'(?<![A-Za-z])(Scrollable|ScrollView|SingleChildScrollView|'
          r'ListView|GridView|Wrap|Flow)\s*[(.<]',
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
      };
      for (final file in formFiles()) {
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

    test('one form layout exists in the whole product, it extends the '
        'foundation, and it builds nothing at all', () {
      final declarations = <String>[];
      for (final file in dartFilesOf('lib')) {
        if (RegExp(
          r'class\s+MentoraFormLayout(?![A-Za-z])',
        ).hasMatch(file.readAsStringSync())) {
          declarations.add(file.path.replaceAll(r'\', '/'));
        }
      }
      expect(declarations, hasLength(1));
      expect(declarations.single, contains('layout/form_layout/'));

      final source = File(declarations.single).readAsStringSync();
      expect(
        RegExp(r'extends\s+MentoraLayout(?![A-Za-z])').hasMatch(source),
        isTrue,
      );
      expect(RegExp(r'Widget\s+build\(').hasMatch(source), isFalse);
      for (final built in const [
        'MentoraWorkspace(',
        'MentoraPageScaffold(',
        'MentoraInput(',
        'MentoraButton(',
        'Column(',
        'Semantics(',
        'FocusTraversalGroup(',
      ]) {
        expect(source.contains(built), isFalse, reason: built);
      }
    });

    test('the official regions are a closed vocabulary, declared once', () {
      final registries = <String>[];
      for (final file in dartFilesOf('lib')) {
        if (RegExp(
          r'enum\s+\w*FormRegion(?![A-Za-z])',
        ).hasMatch(file.readAsStringSync())) {
          registries.add(file.path.replaceAll(r'\', '/'));
        }
      }
      expect(registries, hasLength(1));
      expect(
        registries.single,
        endsWith('layout/foundation/mentora_layout_style.dart'),
      );
      expect(MentoraFormRegion.values, hasLength(6));
    });
  });
}
