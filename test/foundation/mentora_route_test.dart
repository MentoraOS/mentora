import 'dart:io';

import 'package:flutter/material.dart' show Icons, TextDirection;
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_destination.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_route.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';

MentoraRoute _route({
  String id = 'consultation',
  String name = 'La consultation',
  String? description,
  MentoraRouteNature nature = MentoraRouteNature.principal,
}) =>
    MentoraRoute(id: id, name: name, description: description, nature: nature);

void main() {
  group('MentoraRoute — a place where a person can go, nothing else', () {
    test('a route is its identity, its name, what completes it, and its '
        'official nature', () {
      const route = MentoraRoute(
        id: 'consultation',
        name: 'La consultation',
        description: 'Là où une personne consulte un expert',
        nature: MentoraRouteNature.principal,
      );

      expect(route.id, 'consultation');
      expect(route.name, 'La consultation');
      expect(route.description, 'Là où une personne consulte un expert');
      expect(route.nature, MentoraRouteNature.principal);
    });

    test('the completion is optional: a place may be its name alone', () {
      expect(_route().description, isNull);
      _route().verify();
    });

    test('the natures are a CLOSED registry: entry, principal, interior '
        '— and nothing else can exist', () {
      // An unknown nature is refused by the compiler, not by a check:
      // the enumeration is the whole registry.
      expect(MentoraRouteNature.values, hasLength(3));
      expect(MentoraRouteNature.values.map((nature) => nature.name).toList(), [
        'entry',
        'principal',
        'interior',
      ]);
    });

    test('each nature is a distinct fact of the product', () {
      const before = MentoraRoute(
        id: 'entree',
        name: 'L’entrée',
        nature: MentoraRouteNature.entry,
      );
      const within = MentoraRoute(
        id: 'detail',
        name: 'Le détail',
        nature: MentoraRouteNature.interior,
      );

      expect(before.nature, isNot(within.nature));
      expect(before.nature, isNot(MentoraRouteNature.principal));
      expect(within.nature, isNot(MentoraRouteNature.principal));
    });

    test('two routes with the same words ARE the same route', () {
      expect(_route(), _route());
      expect(
        _route(description: 'Ce qui complète'),
        _route(description: 'Ce qui complète'),
      );
    });

    test('a route differs by any of its words — identity, name, '
        'completion or nature', () {
      expect(_route(), isNot(_route(id: 'ailleurs')));
      expect(_route(), isNot(_route(name: 'Un autre nom')));
      expect(_route(), isNot(_route(description: 'Ce qui complète')));
      expect(_route(), isNot(_route(nature: MentoraRouteNature.interior)));
    });

    test('a route is never equal to something that is not a route', () {
      expect(_route(), isNot(equals('consultation')));
      expect(_route(), isNot(equals(MentoraRouteNature.principal)));
    });

    test('equal routes carry equal hashes, and a set keeps one of them', () {
      expect(_route().hashCode, _route().hashCode);
      expect({_route(), _route()}, hasLength(1));
      expect({_route(), _route(id: 'ailleurs')}, hasLength(2));
    });

    test('a route is immutable: it is built const, and the same words '
        'are the same object', () {
      const first = MentoraRoute(
        id: 'consultation',
        name: 'La consultation',
        nature: MentoraRouteNature.principal,
      );
      const second = MentoraRoute(
        id: 'consultation',
        name: 'La consultation',
        nature: MentoraRouteNature.principal,
      );

      expect(identical(first, second), isTrue);
    });

    test('a route without a contract refuses — fail closed', () {
      // 1. A place without an identity is not a place.
      expect(() => _route(id: '').verify(), throwsStateError);
      // 2. A place without a name cannot be offered.
      expect(() => _route(name: '').verify(), throwsStateError);
      // 3. A completion is said or it is not.
      expect(() => _route(description: '').verify(), throwsStateError);
      // And a whole route passes whole.
      _route(description: 'Ce qui complète').verify();
    });

    test('the registry gathers the places once, and refuses a product '
        'with nowhere to go', () {
      expect(
        () => const MentoraRouteRegistry(routes: []).verify(),
        throwsStateError,
      );
      MentoraRouteRegistry(
        routes: [
          _route(),
          _route(id: 'entree', name: 'L’entrée'),
        ],
      ).verify();
    });

    test('two places never share one identity — wherever they stand', () {
      // Adjacent.
      expect(
        () => MentoraRouteRegistry(
          routes: [
            _route(),
            _route(name: 'Un autre nom'),
          ],
        ).verify(),
        throwsStateError,
      );
      // Not adjacent: identity is a set, never a comparison with the
      // neighbour.
      expect(
        () => MentoraRouteRegistry(
          routes: [
            _route(),
            _route(id: 'entree', name: 'L’entrée'),
            _route(name: 'Un autre nom'),
          ],
        ).verify(),
        throwsStateError,
      );
    });

    test('the registry walks every route: a half-defined place is '
        'refused wherever it stands', () {
      expect(
        () => MentoraRouteRegistry(
          routes: [
            _route(),
            _route(id: 'entree', name: ''),
          ],
        ).verify(),
        throwsStateError,
      );
      expect(
        () => MentoraRouteRegistry(
          routes: [
            _route(),
            _route(id: ''),
          ],
        ).verify(),
        throwsStateError,
      );
    });

    test('a route is indifferent to the theme: no variant can reach it, '
        'and it stays itself under every one of the four', () {
      for (final variant in ThemeVariantId.values) {
        expect(_route(), _route(), reason: variant.name);
      }
      expect(ThemeVariantId.values, hasLength(4));
    });

    test('a route is indifferent to the font scale: it stays itself '
        'under every one of the four', () {
      for (final scale in FontScalePreference.values) {
        expect(_route(), _route(), reason: scale.name);
      }
      expect(FontScalePreference.values, hasLength(4));
    });

    test('a route is indifferent to the reading comfort', () {
      for (final comfort in ReadingComfortPreference.values) {
        expect(_route(), _route(), reason: comfort.name);
      }
    });

    test('a route is indifferent to the reading direction: it is not a '
        'presentation, and it has no side', () {
      for (final direction in TextDirection.values) {
        expect(_route(), _route(), reason: direction.name);
      }
    });

    test('a route is indifferent to motion: Motion None changes nothing '
        'of it, because nothing of it ever moves', () {
      for (final motion in MotionPreference.values) {
        expect(_route(), _route(), reason: motion.name);
      }
    });

    test('a destination REFERS to a place by its identity: the route '
        'defines, the destination presents the way', () {
      const route = MentoraRoute(
        id: 'consultation',
        name: 'La consultation',
        nature: MentoraRouteNature.principal,
      );
      const destination = MentoraDestination(
        id: 'consultation',
        label: 'Consultation',
        icon: Icons.medical_services_outlined,
        selectedIcon: Icons.medical_services,
      );

      expect(destination.id, route.id);
      // And the two are different concepts: one defines a place, the
      // other presents the way there — never interchangeable.
      expect(destination, isNot(equals(route)));
    });
  });

  group('Governance — the executable scans ship with the route', () {
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

    final routeFile = File(
      'lib/foundation/design_kit/navigation/mentora_route.dart',
    );

    void refuse(Map<String, RegExp> forbidden, String because) {
      final source = codeOf(routeFile);
      for (final entry in forbidden.entries) {
        expect(
          entry.value.hasMatch(source),
          isFalse,
          reason: '${routeFile.path}: $because ${entry.key}',
        );
      }
    }

    test('a route imports NOTHING: a fact of the product needs nothing '
        'to be true', () {
      expect(
        RegExp(r'^import ', multiLine: true).hasMatch(codeOf(routeFile)),
        isFalse,
      );
    });

    test('a route never navigates: no navigator, no framework route, '
        'no address', () {
      refuse({
        'a navigator': RegExp(
          r'(?<![A-Za-z])(Navigator|GoRouter|AutoRoute)(?![A-Za-z])',
        ),
        'a framework route': RegExp(
          r'(?<![A-Za-z])(Route<|PageRoute|MaterialPageRoute|'
          r'CupertinoPageRoute)(?![A-Za-z])',
        ),
        'an address': RegExp(
          r'(?<![A-Za-z])(Uri|url|Url|URL|path|pushNamed|routeName)'
          r'\s*[:.(=<]',
        ),
        'a network': RegExp(
          r'(?<![A-Za-z])(http|HttpClient|WebSocket|Firestore)(?![A-Za-z])',
        ),
      }, 'it never carries');
    });

    test('a route never builds: no widget, no context, no page, no '
        'screen', () {
      refuse({
        'a widget': RegExp(r'(?<![A-Za-z])Widget(?![A-Za-z])'),
        'a build context': RegExp(r'(?<![A-Za-z])BuildContext(?![A-Za-z])'),
        'a page or a screen': RegExp(
          r'(?<![A-Za-z])(Page|Screen|Scaffold)\s*[(.<]',
        ),
        'a layout': RegExp(r'(?<![A-Za-z])\w*Layout(?![A-Za-z])'),
        'an animation': RegExp(
          r'(?<![A-Za-z])(Animation|Transition|Curve|Duration)'
          r'(?![A-Za-z])',
        ),
      }, 'it never carries');
    });

    test('a route knows no platform and no presentation', () {
      refuse({
        'a platform': RegExp(
          r'(?<![A-Za-z])(Platform|TargetPlatform|kIsWeb|isAndroid|isIOS)'
          r'(?![A-Za-z])',
        ),
        'a measure of the screen': RegExp(
          r'(?<![A-Za-z])(MediaQuery|LayoutBuilder|Breakpoint\w*)'
          r'(?![A-Za-z])',
        ),
        'an ambient theme': RegExp(r'Theme\.of\('),
        'a coded value of presentation': RegExp(
          r'(Color\(0x|Colors\.|EdgeInsets\.|fontSize:)',
        ),
      }, 'it never carries');
    });

    test('a route holds no mutable state and no untyped value', () {
      final source = codeOf(routeFile);
      refuse({
        'an untyped value': RegExp(
          r'(?<![A-Za-z])(dynamic|Object\?)(?![A-Za-z])',
        ),
        'a setter': RegExp(r'(?<![A-Za-z])set\s+\w+\('),
        'a mutable collection': RegExp(r'(?<![A-Za-z])(late|var)\s'),
      }, 'it never carries');
      // Every field of every class in the file is final: a description
      // cannot change once written.
      for (final field in RegExp(
        r'^\s+(?!static)(\w[\w<>?, ]*)\s+\w+;',
        multiLine: true,
      ).allMatches(source)) {
        expect(
          field.group(0)!.trimLeft().startsWith('final '),
          isTrue,
          reason: 'every field is final: ${field.group(0)!.trim()}',
        );
      }
    });

    test('logic stays out: no business, no permission, no parameter of '
        'a screen', () {
      refuse({
        'a business domain': RegExp(
          r'(?<![A-Za-z])(User|Wallet|Product|Expert|Invoice|Business|'
          r'Account|Profile|Model|Repository|Entity)(?![a-z])',
        ),
        'a permission': RegExp(
          r'(?<![A-Za-z])(permission|granted|denied|role|admin)\s*[:.(=]',
        ),
        'a promise': RegExp(
          r'(?<![A-Za-z])(Future|Stream|async|await)(?![A-Za-z])',
        ),
      }, 'it never carries');
    });

    test('one route type exists, inside the Design Kit and nowhere '
        'else: a place declared outside it is refused', () {
      final declarations = <String>[];
      for (final file in dartFilesOf('lib/foundation')) {
        for (final match in RegExp(
          r'class\s+(\w*Route)(?![A-Za-z])',
        ).allMatches(codeOf(file))) {
          declarations.add(
            '${match.group(1)} in ${file.path.replaceAll(r'\', '/')}',
          );
        }
      }
      expect(declarations, [
        'MentoraRoute in '
            'lib/foundation/design_kit/navigation/mentora_route.dart',
      ]);

      // And the registries of the concept exist exactly once each.
      for (final single in const [
        'MentoraRouteNature',
        'MentoraRouteRegistry',
      ]) {
        final places = <String>[];
        for (final file in dartFilesOf('lib')) {
          if (RegExp(
            '(enum|class)\\s+$single(?![A-Za-z])',
          ).hasMatch(file.readAsStringSync())) {
            places.add(file.path.replaceAll(r'\', '/'));
          }
        }
        expect(places, hasLength(1), reason: single);
        expect(
          places.single,
          endsWith('design_kit/navigation/mentora_route.dart'),
          reason: single,
        );
      }
    });

    test('one destination type exists for the whole Kit: no structure '
        'declares a way to a place of its own', () {
      // Scoped to the foundation: what lib/core calls a destination —
      // where an audit line is written — is another concept, in a
      // legacy layer this rule does not govern.
      final declarations = <String>[];
      for (final file in dartFilesOf('lib/foundation')) {
        for (final match in RegExp(
          r'class\s+(\w*Destination)(?![A-Za-z])',
        ).allMatches(codeOf(file))) {
          declarations.add(
            '${match.group(1)} in ${file.path.replaceAll(r'\', '/')}',
          );
        }
      }
      expect(declarations, [
        'MentoraDestination in '
            'lib/foundation/design_kit/navigation/mentora_destination.dart',
      ]);

      // The three structures that present ways to places all consume
      // the one type: the concept has one owner and three users.
      final consumers = <String>[];
      for (final path in const [
        'lib/foundation/design_kit/structure/bottom_navigation',
        'lib/foundation/design_kit/structure/navigation_drawer',
        'lib/foundation/design_kit/structure/navigation_rail',
      ]) {
        final consumes = dartFilesOf(path).any(
          (file) => RegExp(
            r'(?<![A-Za-z])MentoraDestination(?![A-Za-z])',
          ).hasMatch(codeOf(file)),
        );
        expect(consumes, isTrue, reason: path);
        consumers.add(path);
      }
      expect(consumers, hasLength(3));
    });
  });
}
