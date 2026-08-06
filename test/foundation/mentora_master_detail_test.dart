import 'dart:io';
import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/bootstrap/design_kit_bootstrap.dart';
import 'package:mentora/foundation/core/di/foundation_services.dart';
import 'package:mentora/foundation/design_kit/accessibility/accessibility_engine.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/components/design_kit_scope.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text.dart';
import 'package:mentora/foundation/design_kit/components/text/mentora_text_role.dart';
import 'package:mentora/foundation/design_kit/motion/motion_engine.dart';
import 'package:mentora/foundation/design_kit/registry/semantic_roles.dart';
import 'package:mentora/foundation/design_kit/registry/token_engines.dart';
import 'package:mentora/foundation/design_kit/structure/master_detail/mentora_master_detail.dart';
import 'package:mentora/foundation/design_kit/structure/master_detail/mentora_master_detail_style.dart';
import 'package:mentora/foundation/design_kit/theme/theme_engine.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';
import 'package:mentora/foundation/design_kit/tokens/master_detail_tokens.dart';
import 'package:mentora/foundation/design_kit/tokens/surface_elevation_tokens.dart';

/// The two spaces the application owns — recognisable, and never
/// touched by the relation that holds them.
const Widget _master = MentoraText(
  'Les conversations',
  key: Key('master-content'),
  role: MentoraTextRole.body,
);

const Widget _detail = MentoraText(
  'La conversation ouverte',
  key: Key('detail-content'),
  role: MentoraTextRole.body,
);

const MentoraMasterDetailLayoutSpecification _layout =
    MentoraMasterDetailLayoutSpecification(masterExtent: 240);

Future<FoundationServices> _services() async {
  final services = FoundationServices();
  await const DesignKitBootstrapStep().run(services);
  return services;
}

MentoraMasterDetail _relation({
  MentoraMasterDetailPresentation presentation =
      MentoraMasterDetailPresentation.split,
  MentoraMasterPaneVisibility visibility = MentoraMasterPaneVisibility.shown,
  MentoraMasterDetailRegion activeRegion = MentoraMasterDetailRegion.detail,
  MentoraMasterDetailLayoutSpecification layout = _layout,
  Widget master = _master,
  Widget detail = _detail,
  String masterSemanticLabel = 'Liste des conversations',
  String detailSemanticLabel = 'Conversation ouverte',
  VoidCallback? onDismissRequested,
}) {
  return MentoraMasterDetail(
    master: master,
    detail: detail,
    layout: layout,
    presentation: presentation,
    visibility: visibility,
    activeRegion: activeRegion,
    masterSemanticLabel: masterSemanticLabel,
    detailSemanticLabel: detailSemanticLabel,
    onDismissRequested: onDismissRequested,
  );
}

Future<FoundationServices> _pump(
  WidgetTester tester,
  Widget relation, {
  ThemeVariantId variant = ThemeVariantId.light,
  AppearanceState appearance = const AppearanceState(),
  TextDirection direction = TextDirection.ltr,
  Size room = const Size(800, 600),
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
        child: Directionality(
          textDirection: direction,
          // The application decides the room; the relation expresses
          // what it is given.
          child: Center(
            child: SizedBox(
              width: room.width,
              height: room.height,
              child: relation,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return services;
}

Finder _region(MentoraMasterDetailRegion region) =>
    find.byKey(Key('master-detail-${region.name}'));

Color? _groundOf(WidgetTester tester, MentoraMasterDetailRegion region) {
  final container = tester.widget<AnimatedContainer>(_region(region));
  return (container.decoration as BoxDecoration?)?.color;
}

void main() {
  group('MentoraMasterDetail — the relation between two spaces', () {
    testWidgets('a relation carries two spaces, and changes nothing '
        'about either of them', (tester) async {
      await _pump(tester, _relation());

      // Each space starts exactly where the region it was given
      // starts: no padding, no wrapping, no order of its own.
      for (final entry in const {
        MentoraMasterDetailRegion.master: Key('master-content'),
        MentoraMasterDetailRegion.detail: Key('detail-content'),
      }.entries) {
        expect(
          tester.getTopLeft(find.byKey(entry.value)),
          tester.getTopLeft(_region(entry.key)),
          reason: 'a relation adds nothing around the spaces it holds',
        );
      }
    });

    testWidgets('the announced presentation is expressed: side by side, '
        'in front, or one space at a time', (tester) async {
      // Side by side: the presenting space takes the announced room,
      // the other takes exactly what is left — never a proportion.
      await _pump(tester, _relation());
      final master = tester.getRect(_region(MentoraMasterDetailRegion.master));
      final detail = tester.getRect(_region(MentoraMasterDetailRegion.detail));
      expect(master.width, _layout.masterExtent);
      expect(
        detail.width,
        800 - _layout.masterExtent - masterDetailDividerThickness,
      );
      expect(detail.left, master.right + masterDetailDividerThickness);
      expect(find.byKey(const Key('master-detail-divider')), findsOneWidget);
      expect(find.byKey(const Key('master-detail-scrim')), findsNothing);

      // In front: the space that deepens keeps the whole room, and the
      // presenting one takes none of it.
      await _pump(
        tester,
        _relation(
          presentation: MentoraMasterDetailPresentation.overlay,
          activeRegion: MentoraMasterDetailRegion.master,
        ),
      );
      expect(
        tester.getRect(_region(MentoraMasterDetailRegion.detail)).width,
        800,
      );
      expect(
        tester.getRect(_region(MentoraMasterDetailRegion.master)).width,
        _layout.masterExtent,
      );
      expect(find.byKey(const Key('master-detail-scrim')), findsOneWidget);
      expect(find.byKey(const Key('master-detail-divider')), findsNothing);

      // One space at a time: the other is not built at all.
      await _pump(
        tester,
        _relation(
          presentation: MentoraMasterDetailPresentation.stacked,
          activeRegion: MentoraMasterDetailRegion.master,
        ),
      );
      expect(
        tester.getRect(_region(MentoraMasterDetailRegion.master)).width,
        800,
      );
      expect(_region(MentoraMasterDetailRegion.detail), findsNothing);
      expect(find.byKey(const Key('detail-content')), findsNothing);
    });

    testWidgets('the announced visibility is expressed: a space that is '
        'put away is not built, and nothing of it is reachable', (
      tester,
    ) async {
      for (final presentation in MentoraMasterDetailPresentation.values) {
        await _pump(
          tester,
          _relation(
            presentation: presentation,
            visibility: MentoraMasterPaneVisibility.hidden,
          ),
        );

        expect(_region(MentoraMasterDetailRegion.master), findsNothing);
        expect(find.byKey(const Key('master-content')), findsNothing);
        // The space that deepens keeps the whole room for itself.
        expect(
          tester.getRect(_region(MentoraMasterDetailRegion.detail)).width,
          800,
        );
      }
    });

    testWidgets('the room is imposed by the specification: the relation '
        'computes nothing', (tester) async {
      for (final extent in const [
        masterDetailMinimumPaneExtent,
        320.0,
        480.0,
      ]) {
        await _pump(
          tester,
          _relation(
            layout: MentoraMasterDetailLayoutSpecification(
              masterExtent: extent,
            ),
          ),
        );
        expect(
          tester.getRect(_region(MentoraMasterDetailRegion.master)).width,
          extent,
        );
      }

      // The same specification, a different room: the announced extent
      // never moves, because it was never derived from the surface.
      await _pump(tester, _relation(), room: const Size(1400, 900));
      expect(
        tester.getRect(_region(MentoraMasterDetailRegion.master)).width,
        _layout.masterExtent,
      );
    });

    testWidgets('the two regions are landmarks, each named, and the one '
        'being worked in is announced', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        _relation(activeRegion: MentoraMasterDetailRegion.master),
      );

      final master = tester.getSemantics(
        _region(MentoraMasterDetailRegion.master),
      );
      expect(master.label, 'Liste des conversations');
      expect(master.flagsCollection.isSelected, Tristate.isTrue);

      final detail = tester.getSemantics(
        _region(MentoraMasterDetailRegion.detail),
      );
      expect(detail.label, 'Conversation ouverte');
      expect(detail.flagsCollection.isSelected, Tristate.isFalse);
      handle.dispose();
    });

    testWidgets('the space being worked in rests on its own ground, and '
        'the one that waits on another', (tester) async {
      final services = await _pump(
        tester,
        _relation(activeRegion: MentoraMasterDetailRegion.master),
      );
      final surfaces = services.get<SurfaceTokenEngine>();
      final primary = surfaces.surfaceOf(
        SurfaceRole.primarySurface,
        ThemeVariantId.light,
      );
      final secondary = surfaces.surfaceOf(
        SurfaceRole.secondarySurface,
        ThemeVariantId.light,
      );

      expect(_groundOf(tester, MentoraMasterDetailRegion.master), primary);
      expect(_groundOf(tester, MentoraMasterDetailRegion.detail), secondary);

      // The application announces the other region: only the ground
      // follows — the rooms and the contents do not move.
      final before = tester.getRect(_region(MentoraMasterDetailRegion.master));
      await _pump(tester, _relation());
      expect(_groundOf(tester, MentoraMasterDetailRegion.master), secondary);
      expect(_groundOf(tester, MentoraMasterDetailRegion.detail), primary);
      expect(tester.getRect(_region(MentoraMasterDetailRegion.master)), before);
    });

    testWidgets('each space travels as its own focus group, and the '
        'relation never takes the focus', (tester) async {
      final inside = FocusNode(debugLabel: 'detail');
      addTearDown(inside.dispose);

      await _pump(
        tester,
        _relation(
          detail: Focus(
            focusNode: inside,
            child: const MentoraText(
              'La conversation ouverte',
              key: Key('detail-content'),
              role: MentoraTextRole.body,
            ),
          ),
        ),
      );

      // One focus group per space, and not one more.
      expect(
        find.descendant(
          of: find.byType(MentoraMasterDetail),
          matching: find.byType(FocusTraversalGroup),
        ),
        findsNWidgets(2),
      );

      inside.requestFocus();
      await tester.pumpAndSettle();
      expect(inside.hasPrimaryFocus, isTrue);

      // The application announces the other region: the focus stays
      // exactly where the person left it.
      await tester.pumpAndSettle();
      expect(inside.hasPrimaryFocus, isTrue);
    });

    testWidgets('asking a space to step aside is reported, never '
        'performed', (tester) async {
      var asked = 0;
      await _pump(
        tester,
        _relation(
          presentation: MentoraMasterDetailPresentation.overlay,
          activeRegion: MentoraMasterDetailRegion.master,
          onDismissRequested: () => asked++,
        ),
      );

      await tester.tapAt(
        tester.getRect(_region(MentoraMasterDetailRegion.detail)).centerRight -
            const Offset(1, 0),
      );
      await tester.pumpAndSettle();

      expect(asked, 1);
      // Nothing was performed: the presenting space is still there.
      expect(_region(MentoraMasterDetailRegion.master), findsOneWidget);
    });

    testWidgets('a relation without a contract refuses to build — fail '
        'closed', (tester) async {
      Future<void> refuses(MentoraMasterDetail relation) async {
        await _pump(tester, relation);
        expect(tester.takeException(), isStateError);
      }

      // A region without a name is not a landmark.
      await refuses(_relation(masterSemanticLabel: ''));
      await refuses(_relation(detailSemanticLabel: ''));
      // A room below the opposable floor is not a space.
      await refuses(
        _relation(
          layout: const MentoraMasterDetailLayoutSpecification(
            masterExtent: masterDetailMinimumPaneExtent - 1,
          ),
        ),
      );
      await refuses(
        _relation(
          layout: const MentoraMasterDetailLayoutSpecification(
            masterExtent: double.infinity,
          ),
        ),
      );
      // A relation never guesses where the person works: the region
      // announced as active must be one it shows.
      await refuses(
        _relation(
          visibility: MentoraMasterPaneVisibility.hidden,
          activeRegion: MentoraMasterDetailRegion.master,
        ),
      );
      await refuses(
        _relation(
          presentation: MentoraMasterDetailPresentation.stacked,
          activeRegion: MentoraMasterDetailRegion.detail,
        ),
      );
      // Only a space that passes in front can be asked to step aside.
      await refuses(_relation(onDismissRequested: () {}));
    });

    testWidgets('the relation holds in the four themes, both reading '
        'directions and every reading comfort', (tester) async {
      for (final variant in ThemeVariantId.values) {
        await _pump(tester, _relation(), variant: variant);
        expect(tester.takeException(), isNull);
        expect(_groundOf(tester, MentoraMasterDetailRegion.detail), isNotNull);
      }

      for (final comfort in ReadingComfortPreference.values) {
        await _pump(
          tester,
          _relation(),
          appearance: AppearanceState(readingComfort: comfort),
        );
        expect(tester.takeException(), isNull);
      }

      // The presenting space follows the reading direction, and the
      // relation never mirrors anything by hand.
      await _pump(tester, _relation());
      final ltr = tester.getRect(_region(MentoraMasterDetailRegion.master));
      await _pump(tester, _relation(), direction: TextDirection.rtl);
      final rtl = tester.getRect(_region(MentoraMasterDetailRegion.master));
      expect(rtl.left, greaterThan(ltr.left));
      expect(rtl.width, ltr.width);
    });

    testWidgets('every transition comes from the Motion Engine: None '
        'silences it', (tester) async {
      const appearance = AppearanceState();
      final services = await _pump(tester, _relation());
      expect(
        tester
            .widget<AnimatedContainer>(
              _region(MentoraMasterDetailRegion.detail),
            )
            .duration,
        services.get<MotionEngine>().durationFor(
          MotionIntention.montrerLaContinuite,
          appearance,
        ),
      );

      await _pump(
        tester,
        _relation(),
        appearance: const AppearanceState(motion: MotionPreference.none),
      );
      expect(
        tester
            .widget<AnimatedContainer>(
              _region(MentoraMasterDetailRegion.detail),
            )
            .duration,
        Duration.zero,
      );
    });

    testWidgets('outside the Design Kit the relation refuses to build — '
        'fail closed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(width: 800, height: 600, child: _relation()),
          ),
        ),
      );
      expect(tester.takeException(), isStateError);
    });
  });

  group('Governance — the executable scans ship with the component', () {
    Iterable<File> dartFilesOf(String path) => Directory(path)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    Iterable<File> relationFiles() =>
        dartFilesOf('lib/foundation/design_kit/structure/master_detail');

    test('a relation measures nothing, knows no platform and takes no '
        'responsive decision', () {
      final forbidden = <String, RegExp>{
        'a measure of the screen': RegExp(
          r'(?<![A-Za-z])(MediaQuery|LayoutBuilder|ResponsiveEngine|'
          r'FractionallySizedBox|AspectRatio|IntrinsicWidth|'
          r'IntrinsicHeight)(?![A-Za-z])',
        ),
        'a platform': RegExp(
          r'(?<![A-Za-z])(Platform|TargetPlatform|defaultTargetPlatform|'
          r'kIsWeb|isAndroid|isIOS|mobile|tablet|desktop|foldable)'
          r'(?![A-Za-z])',
        ),
        'a framework scaffold': RegExp(r'(?<![A-Za-z])Scaffold\('),
      };
      final files = relationFiles();
      expect(files, isNotEmpty);
      for (final file in files) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: a relation never carries ${entry.key} — '
                'the application decides, the relation expresses',
          );
        }
      }
    });

    test('a relation decides no proportion: no flex, and no fraction of '
        'anything', () {
      final forbidden = <String, RegExp>{
        'a flexible space': RegExp(
          r'(?<![A-Za-z])(Expanded|Flexible|Spacer)(?![A-Za-z])',
        ),
        'a flex factor': RegExp(r'flex:'),
        // Structural, never lexical: these are identifiers of the code.
        'a computed share': RegExp(
          r'(?<![A-Za-z])(aspectRatio|widthFactor|heightFactor|flex|'
          r'percent)(?![A-Za-z])',
        ),
      };
      for (final file in relationFiles()) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: ${entry.key} — the room is announced, '
                'never computed',
          );
        }
      }
    });

    test('a relation knows no data, no selection and no business', () {
      final forbidden = <String, RegExp>{
        'a selection': RegExp(
          r'(?<![A-Za-z])(selectedItem|selectedIndex|currentItem|'
          r'currentConversation|selectedId|itemCount|items)(?![A-Za-z])',
        ),
        'an address': RegExp(
          r'(?<![A-Za-z])(Navigator|GoRouter|routeName|pushNamed|'
          r'MaterialPageRoute)(?![A-Za-z])',
        ),
        'a business domain': RegExp(
          r'(?<![A-Za-z])(Wallet|Consultation|Business|Chat|Invoice|'
          r'Facture|Product|Dashboard|Profile|Settings|Message|Email|'
          r'Inbox)(?![a-z])',
        ),
      };
      for (final file in relationFiles()) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason: '${file.path}: a relation never carries ${entry.key}',
          );
        }
      }
    });

    test('a relation rebuilds nothing it does not own, reads no ambient '
        'theme and codes no value', () {
      final forbidden = <String, RegExp>{
        'its own words': RegExp(r'(?<![A-Za-z])Text\('),
        'its own style': RegExp(r'(?<![A-Za-z])TextStyle\('),
        'an ambient theme': RegExp(r'Theme\.of\('),
        'a coded colour': RegExp(r'(Color\(0x|Colors\.)'),
        'a coded padding': RegExp(r'EdgeInsets\.\w+\(\s*[0-9]'),
        'a coded radius': RegExp(r'BorderRadius\.\w+\(\s*[0-9]'),
        'a coded extent': RegExp(r'(width|height):\s*[1-9]'),
        'a coded duration': RegExp(r'Duration\((milliseconds|seconds)'),
      };
      for (final file in relationFiles()) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason: '${file.path}: a relation never carries ${entry.key}',
          );
        }
      }
    });

    test('one master detail exists in the product, and it lives in the '
        'Design Kit', () {
      final declarations = <String>[];
      for (final file in dartFilesOf('lib/foundation')) {
        if (RegExp(
          r'class\s+MentoraMasterDetail(?![A-Za-z])',
        ).hasMatch(file.readAsStringSync())) {
          declarations.add(file.path.replaceAll(r'\', '/'));
        }
      }
      expect(declarations, hasLength(1));
      expect(
        declarations.single,
        contains('design_kit/structure/master_detail/'),
      );
    });
  });
}
