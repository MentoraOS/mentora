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
import 'package:mentora/foundation/design_kit/components/design_kit_scope.dart';
import 'package:mentora/foundation/design_kit/composition/list_tile/mentora_list_tile.dart';
import 'package:mentora/foundation/design_kit/composition/list_tile/mentora_list_tile_arrangement.dart';
import 'package:mentora/foundation/design_kit/motion/motion_engine.dart';
import 'package:mentora/foundation/design_kit/registry/token_engines.dart';
import 'package:mentora/foundation/design_kit/theme/theme_engine.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';
import 'package:mentora/foundation/design_kit/tokens/surface_elevation_tokens.dart';

/// The rooms the catalogue presents, from the narrowest upward.
const List<double> _rooms = [180, 220, 260, 300, 340, 370, 420, 480];

/// The rooms the ladder is measured over.
///
/// They reach beyond the catalogue on purpose: a richly composed
/// entity — two states and an act — keeps everything it carries only
/// in a room that wide, and the ladder must be observed whole.
const List<double> _ladderRooms = [..._rooms, 560, 640, 800];

const String _name = 'Awa Mensah';
const String _supporting = 'Consultation de suivi';
const String _metadata = '11:00 — 45 min';
const String _primaryBadge = 'Confirmée';
const String _secondaryBadge = 'Nouveau';
const String _act = 'Ouvrir';

void _noop() {}

MentoraListTile _tile({bool composed = true}) => MentoraListTile(
  headline: _name,
  leading: composed
      ? const MentoraAvatar(
          identity: MentoraAvatarIdentity.initials,
          name: _name,
          initials: 'AM',
        )
      : null,
  supporting: composed ? _supporting : null,
  metadata: composed ? _metadata : null,
  badges: composed
      ? const [
          MentoraBadge(
            variant: MentoraBadgeVariant.success,
            shape: MentoraBadgeShape.compact,
            label: _primaryBadge,
          ),
          MentoraBadge(
            variant: MentoraBadgeVariant.information,
            shape: MentoraBadgeShape.compact,
            label: _secondaryBadge,
          ),
        ]
      : const [],
  trailing: composed
      ? MentoraButton(
          label: _act,
          onPressed: _noop,
          variant: MentoraButtonVariant.text,
          size: MentoraButtonSize.small,
        )
      : null,
  onTap: _noop,
);

Future<FoundationServices> _services() async {
  final services = FoundationServices();
  await const DesignKitBootstrapStep().run(services);
  return services;
}

Future<FoundationServices> _pump(
  WidgetTester tester,
  Widget tile, {
  double room = 480,
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
        child: Directionality(
          textDirection: direction,
          // The parent imposes the room; the entity answers it.
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: room, child: tile),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return services;
}

/// Whether a part was given up.
///
/// An entity that gives up a part stops placing it: the part is no
/// longer painted, no longer touchable and no longer spoken. What is
/// left of it stands at the origin of what it belonged to — and only a
/// part that was given up ever stands there, because the identity
/// always opens the line.
bool _givenUp(WidgetTester tester, Finder part, Finder within) =>
    tester.getTopLeft(part) == tester.getTopLeft(within);

/// What the entity still says in the room it was given.
Set<String> _surviving(WidgetTester tester) {
  final line = find.byType(MentoraListTileArrangement);
  final words = find.byType(MentoraListTileWords);
  final surviving = <String>{};

  for (final state in const [_primaryBadge, _secondaryBadge]) {
    if (!_givenUp(tester, find.widgetWithText(MentoraBadge, state), line)) {
      surviving.add(state);
    }
  }
  if (!_givenUp(tester, find.widgetWithText(MentoraButton, _act), line)) {
    surviving.add(_act);
  }
  for (final part in const [_supporting, _metadata]) {
    if (!_givenUp(tester, find.text(part), words)) surviving.add(part);
  }
  // The name opens the words, and the identity opens the line: both
  // are always there, and both are read where they stand.
  surviving.add(_name);
  if (tester.any(find.byType(MentoraAvatar))) surviving.add('identity');
  return surviving;
}

/// The narrowest room in which a part still survives.
Future<double> _survivesDownTo(WidgetTester tester, String part) async {
  var narrowest = double.infinity;
  for (final room in _ladderRooms) {
    await _pump(tester, _tile(), room: room);
    if (_surviving(tester).contains(part)) {
      narrowest = room < narrowest ? room : narrowest;
    }
  }
  return narrowest;
}

void main() {
  group('MentoraListTile — an entity that stays dignified when the room '
      'grows short', () {
    testWidgets('no room ever produces an overflow: from 180 dp upward, '
        'nothing is ever cut', (tester) async {
      for (final room in _rooms) {
        await _pump(tester, _tile(), room: room);
        expect(
          tester.takeException(),
          isNull,
          reason: 'the entity overflowed the $room dp it was given',
        );
        expect(
          tester.getSize(find.byType(MentoraListTile)).width,
          room,
          reason: 'the entity took more than the room it was given',
        );
      }
    });

    testWidgets('the name and the identity survive every room', (tester) async {
      for (final room in _rooms) {
        await _pump(tester, _tile(), room: room);
        final surviving = _surviving(tester);
        expect(surviving, contains(_name), reason: 'at $room dp');
        expect(surviving, contains('identity'), reason: 'at $room dp');
        // The name is never cut brutally: it is elided, officially.
        expect(tester.getSize(find.text(_name)).width, lessThanOrEqualTo(room));
      }
    });

    testWidgets('an entity only ever gives up: what it surrendered in a '
        'wider room never comes back in a narrower one', (tester) async {
      var wider = <String>{};
      for (final room in _rooms.reversed) {
        await _pump(tester, _tile(), room: room);
        final surviving = _surviving(tester);
        if (wider.isNotEmpty) {
          expect(
            surviving.difference(wider),
            isEmpty,
            reason:
                'at $room dp the entity showed something it had already '
                'given up in a wider room',
          );
        }
        wider = surviving;
      }
    });

    testWidgets('the official surrender ladder is respected: the space, '
        'then the states, then the words, then the act', (tester) async {
      final secondaryBadge = await _survivesDownTo(tester, _secondaryBadge);
      final primaryBadge = await _survivesDownTo(tester, _primaryBadge);
      final supporting = await _survivesDownTo(tester, _supporting);
      final act = await _survivesDownTo(tester, _act);

      // The last state announced is the first given up.
      expect(secondaryBadge, greaterThan(primaryBadge));
      // What completes the name outlives the states…
      expect(primaryBadge, greaterThan(supporting));
      // …and the act outlives what completes the name: an act is never
      // a decoration.
      expect(supporting, greaterThan(act));
      // Everything is given up before the name and the identity.
      expect(act, greaterThan(_rooms.first - 1));
    });

    testWidgets('what completes the name goes together, and the name '
        'stays alone', (tester) async {
      await _pump(tester, _tile(), room: 220);
      final surviving = _surviving(tester);

      expect(surviving, contains(_name));
      expect(surviving, isNot(contains(_supporting)));
      expect(surviving, isNot(contains(_metadata)));
    });

    testWidgets('the act outlives the states it stands beside', (tester) async {
      await _pump(tester, _tile(), room: 300);
      final surviving = _surviving(tester);

      expect(surviving, contains(_act));
      expect(surviving, isNot(contains(_secondaryBadge)));
    });

    testWidgets('a part that was given up is no longer touchable, and no '
        'longer spoken', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _tile(), room: 220);

      // The act was given up: it is no longer spoken, and no longer
      // placed anywhere a person could reach it.
      expect(find.bySemanticsLabel(RegExp(_act)), findsNothing);
      expect(
        _givenUp(
          tester,
          find.byType(MentoraButton),
          find.byType(MentoraListTileArrangement),
        ),
        isTrue,
      );
      handle.dispose();
    });

    testWidgets('the composition is intact: what survives is still the '
        'official component, never a copy of it', (tester) async {
      await _pump(tester, _tile(), room: 480);

      expect(find.byType(MentoraAvatar), findsOneWidget);
      expect(find.byType(MentoraBadge), findsNWidgets(2));
      expect(find.byType(MentoraButton), findsOneWidget);
      expect(find.byType(MentoraListTile), findsOneWidget);
      // One entity, one arrangement: no alternative tile exists.
      expect(find.byType(MentoraListTileArrangement), findsOneWidget);
      expect(find.byType(MentoraListTileWords), findsOneWidget);
    });

    testWidgets('the geometry stays stable: the parts never leave the '
        'room, and never overlap the name', (tester) async {
      for (final room in _rooms) {
        await _pump(tester, _tile(), room: room);
        final tile = tester.getRect(find.byType(MentoraListTile));
        for (final part in [
          find.byType(MentoraAvatar),
          find.text(_name),
          if (tester.any(find.byType(MentoraButton)))
            find.byType(MentoraButton),
        ]) {
          final rect = tester.getRect(part);
          expect(rect.left, greaterThanOrEqualTo(tile.left - 0.01));
          expect(rect.right, lessThanOrEqualTo(tile.right + 0.01));
        }
      }
    });

    testWidgets('the entity stays an entity in both reading directions', (
      tester,
    ) async {
      for (final room in _rooms) {
        await _pump(tester, _tile(), room: room, direction: TextDirection.rtl);
        expect(tester.takeException(), isNull, reason: 'at $room dp');
        expect(_surviving(tester), contains(_name));
      }

      // The identity follows the reading direction, and the room it
      // takes never changes.
      await _pump(tester, _tile(), room: 480);
      final ltr = tester.getRect(find.byType(MentoraAvatar));
      await _pump(tester, _tile(), room: 480, direction: TextDirection.rtl);
      final rtl = tester.getRect(find.byType(MentoraAvatar));
      expect(rtl.width, ltr.width);
      expect(rtl.right, greaterThan(ltr.right));
    });

    testWidgets('the entity holds in the four themes, every reading '
        'comfort and every density', (tester) async {
      for (final variant in ThemeVariantId.values) {
        await _pump(tester, _tile(), room: 220, variant: variant);
        expect(tester.takeException(), isNull);
        expect(_surviving(tester), contains(_name));
      }

      for (final comfort in ReadingComfortPreference.values) {
        await _pump(
          tester,
          _tile(),
          room: 220,
          appearance: AppearanceState(readingComfort: comfort),
        );
        expect(tester.takeException(), isNull);
      }

      for (final scale in FontScalePreference.values) {
        await _pump(
          tester,
          _tile(),
          room: 180,
          appearance: AppearanceState(fontScale: scale),
        );
        expect(
          tester.takeException(),
          isNull,
          reason: 'the entity overflowed at the ${scale.name} scale',
        );
        expect(_surviving(tester), contains(_name));
      }
    });

    testWidgets('a bare entity is still an entity, at every room', (
      tester,
    ) async {
      for (final room in _rooms) {
        await _pump(tester, _tile(composed: false), room: room);
        expect(tester.takeException(), isNull);
        expect(find.text(_name), findsOneWidget);
      }
    });

    testWidgets('every transition still comes from the Motion Engine: '
        'None silences it', (tester) async {
      await _pump(
        tester,
        _tile(),
        room: 220,
        appearance: const AppearanceState(motion: MotionPreference.none),
      );
      expect(
        tester
            .widget<AnimatedContainer>(
              find.byKey(const Key('list-tile-surface')),
            )
            .duration,
        Duration.zero,
      );
    });

    testWidgets('outside the Design Kit the entity refuses to build — '
        'fail closed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: 220, child: _tile()),
          ),
        ),
      );
      expect(tester.takeException(), isStateError);
    });
  });

  group('Governance — the executable scans ship with the adaptation', () {
    Iterable<File> dartFilesOf(String path) => Directory(path)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    Iterable<File> entityFiles() =>
        dartFilesOf('lib/foundation/design_kit/composition/list_tile');

    test('an entity never hides what it cannot show: no overflow box, no '
        'fitted box, no intrinsic sizing of its own', () {
      final forbidden = <String, RegExp>{
        'an overflow box': RegExp(
          r'(?<![A-Za-z])(OverflowBox|SizedOverflowBox|UnconstrainedBox)'
          r'(?![A-Za-z])',
        ),
        'a fitted box': RegExp(r'(?<![A-Za-z])FittedBox(?![A-Za-z])'),
        'an intrinsic box': RegExp(
          r'(?<![A-Za-z])(IntrinsicWidth|IntrinsicHeight)(?![A-Za-z])',
        ),
        'a brutal cut': RegExp(r'(?<![A-Za-z])(ClipRect|ClipRRect)\('),
      };
      final files = entityFiles();
      expect(files, isNotEmpty);
      for (final file in files) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: an entity gives up in the official order '
                '— it never carries ${entry.key}',
          );
        }
      }
    });

    test('an entity measures no screen, knows no platform and reads no '
        'breakpoint', () {
      final forbidden = <String, RegExp>{
        'a measure of the screen': RegExp(
          r'(?<![A-Za-z])(MediaQuery|LayoutBuilder|ResponsiveEngine|'
          r'Breakpoint\w*|OrientationBuilder)(?![A-Za-z])',
        ),
        'a platform': RegExp(
          r'(?<![A-Za-z])(Platform|TargetPlatform|defaultTargetPlatform|'
          r'kIsWeb|isAndroid|isIOS)(?![A-Za-z])',
        ),
      };
      for (final file in entityFiles()) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason:
                '${file.path}: the parent imposes the constraint — an '
                'entity never carries ${entry.key}',
          );
        }
      }
    });

    test('one entity exists, and no narrow variant of it was ever '
        'created', () {
      final alternatives = RegExp(
        r'class\s+\w*(Compact|Mini|Narrow|Small|Responsive|Adaptive)\w*'
        r'(Tile|ListTile)',
      );
      for (final file in dartFilesOf('lib')) {
        expect(
          alternatives.hasMatch(file.readAsStringSync()),
          isFalse,
          reason:
              '${file.path}: an entity is a MentoraListTile — never a '
              'second tile for a narrower room',
        );
      }

      final declarations = <String>[];
      for (final file in dartFilesOf('lib')) {
        if (RegExp(
          r'class\s+MentoraListTile(?![A-Za-z])',
        ).hasMatch(file.readAsStringSync())) {
          declarations.add(file.path.replaceAll(r'\', '/'));
        }
      }
      expect(declarations, hasLength(1));
      expect(
        declarations.single,
        contains('design_kit/composition/list_tile/'),
      );
    });

    test('an entity rebuilds nothing it composes, reads no ambient theme '
        'and codes no value', () {
      final forbidden = <String, RegExp>{
        'its own words': RegExp(r'(?<![A-Za-z])Text\('),
        'its own style': RegExp(r'(?<![A-Za-z])TextStyle\('),
        'its own identity': RegExp(r'(?<![A-Za-z])CircleAvatar\('),
        'an ambient theme': RegExp(r'Theme\.of\('),
        'a coded colour': RegExp(r'(Color\(0x|Colors\.)'),
        'a coded padding': RegExp(r'EdgeInsets\.\w+\(\s*[0-9]'),
        'a coded radius': RegExp(r'BorderRadius\.\w+\(\s*[0-9]'),
        'a coded extent': RegExp(r'(width|height|gap|floor):\s*[1-9]'),
        'a coded duration': RegExp(r'Duration\((milliseconds|seconds)'),
      };
      for (final file in entityFiles()) {
        final source = file.readAsStringSync();
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason: '${file.path}: an entity never carries ${entry.key}',
          );
        }
      }
    });
  });
}
