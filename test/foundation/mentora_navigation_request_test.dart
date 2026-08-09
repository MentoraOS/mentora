import 'dart:io';

import 'package:flutter/material.dart' show TextDirection;
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_navigation_request.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_route.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';

MentoraRoute _place(
  String id, {
  String? name,
  String? description,
  MentoraRouteNature nature = MentoraRouteNature.principal,
}) => MentoraRoute(
  id: id,
  name: name ?? 'Lieu $id',
  description: description,
  nature: nature,
);

MentoraRouteRegistry _registry({List<MentoraRoute>? routes}) =>
    MentoraRouteRegistry(
      routes:
          routes ??
          [
            _place('entree', nature: MentoraRouteNature.entry),
            _place('accueil'),
            _place('consultation'),
          ],
    );

MentoraNavigationRequest _request({MentoraRoute? route}) =>
    MentoraNavigationRequest(route: route ?? _place('accueil'));

void main() {
  group('MentoraNavigationRequest — the demand to go to a place', () {
    test('a request is the place asked for, and nothing else', () {
      final request = MentoraNavigationRequest(route: _place('accueil'));

      expect(request.route.id, 'accueil');
    });

    test('a demand cannot ask for nothing: the place is required by '
        'the TYPE, and no run-time check repeats the compiler', () {
      // The field is non-nullable: a request without a route does not
      // compile, so "no route" is a refusal the compiler owns.
      expect(_request().route, isA<MentoraRoute>());
    });

    test('the place is carried WHOLE: identity, name, completion and '
        'nature all travel with the demand', () {
      final request = MentoraNavigationRequest(
        route: _place(
          'consultation',
          name: 'La consultation',
          description: 'Là où une personne consulte un expert',
          nature: MentoraRouteNature.interior,
        ),
      );

      expect(request.route.id, 'consultation');
      expect(request.route.name, 'La consultation');
      expect(
        request.route.description,
        'Là où une personne consulte un expert',
      );
      expect(request.route.nature, MentoraRouteNature.interior);
    });

    test('the route travels strictly intact: the very object asked for '
        'is the object carried', () {
      final route = _place('accueil');
      final request = MentoraNavigationRequest(route: route);

      expect(identical(request.route, route), isTrue);
    });

    test('a request carries no reason: none exists in the foundation, '
        'and none was invented', () {
      // The whole surface of a request is its route — proven by the
      // scan below on the source, and here by the value: two requests
      // for the same place are indistinguishable, because there is
      // nothing else they could differ by.
      expect(
        MentoraNavigationRequest(route: _place('accueil')),
        MentoraNavigationRequest(route: _place('accueil')),
      );
    });

    test('two demands for the same place ARE the same demand', () {
      expect(_request(), _request());
      expect(_request().hashCode, _request().hashCode);
      expect({_request(), _request()}, hasLength(1));
    });

    test('a demand differs by the place asked for — by any of its '
        'words', () {
      expect(_request(), isNot(_request(route: _place('consultation'))));
      expect(
        _request(),
        isNot(_request(route: _place('accueil', name: 'Un autre nom'))),
      );
      expect(
        _request(),
        isNot(
          _request(
            route: _place('accueil', nature: MentoraRouteNature.interior),
          ),
        ),
      );
    });

    test('a demand is never equal to something that is not a demand', () {
      expect(_request(), isNot(equals(_place('accueil'))));
      expect(_request(), isNot(equals('accueil')));
    });

    test('a request is immutable: it is built const, and the same '
        'words are the same object', () {
      const first = MentoraNavigationRequest(
        route: MentoraRoute(
          id: 'accueil',
          name: 'L’accueil',
          nature: MentoraRouteNature.principal,
        ),
      );
      const second = MentoraNavigationRequest(
        route: MentoraRoute(
          id: 'accueil',
          name: 'L’accueil',
          nature: MentoraRouteNature.principal,
        ),
      );

      expect(identical(first, second), isTrue);
    });

    test('a whole demand passes whole, wherever the place stands in '
        'the product', () {
      final registry = _registry();

      for (final route in registry.routes) {
        MentoraNavigationRequest(route: route).verify(registry);
      }
    });

    test('the demand is not the movement: verifying it moves no one '
        'and changes nothing', () {
      final registry = _registry();
      final request = _request();

      request.verify(registry);
      request.verify(registry);
      // The demand is exactly what it was: nothing happened, because
      // a request describes and never performs.
      expect(request, _request());
      expect(identical(registry.routes, registry.routes), isTrue);
    });
  });

  group('Fail closed — a demand without a contract refuses', () {
    void refuses(
      MentoraNavigationRequest request,
      MentoraRouteRegistry registry,
      String fragment,
    ) {
      expect(
        () => request.verify(registry),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains(fragment),
          ),
        ),
      );
    }

    test('an invalid place is refused — with the route’s own voice', () {
      refuses(
        _request(route: _place('')),
        _registry(),
        'without an identity is not a place',
      );
      refuses(
        _request(route: _place('accueil', name: '')),
        _registry(),
        'without a name cannot be offered',
      );
    });

    test('a place the product never declared is refused', () {
      refuses(
        _request(route: _place('ailleurs')),
        _registry(),
        'only ask to go to a place the product declared',
      );
    });

    test('a forgery is refused: the same identity with other words is '
        'not the place the product declared', () {
      refuses(
        _request(route: _place('accueil', name: 'Un autre nom')),
        _registry(),
        'only ask to go to a place the product declared',
      );
      refuses(
        _request(route: _place('accueil', nature: MentoraRouteNature.interior)),
        _registry(),
        'only ask to go to a place the product declared',
      );
    });

    test('the demand is checked against the product it is made in: the '
        'same request stands in one and falls in another', () {
      final request = _request(route: _place('consultation'));

      request.verify(_registry());
      refuses(
        request,
        _registry(
          routes: [
            _place('entree', nature: MentoraRouteNature.entry),
            _place('accueil'),
          ],
        ),
        'only ask to go to a place the product declared',
      );
    });
  });

  group('A demand is indifferent to every presentation', () {
    test('it stays itself under every one of the four themes', () {
      for (final variant in ThemeVariantId.values) {
        expect(_request(), _request(), reason: variant.name);
      }
      expect(ThemeVariantId.values, hasLength(4));
    });

    test('it stays itself under every one of the four font scales', () {
      for (final scale in FontScalePreference.values) {
        expect(_request(), _request(), reason: scale.name);
      }
      expect(FontScalePreference.values, hasLength(4));
    });

    test('it stays itself under every reading comfort', () {
      for (final comfort in ReadingComfortPreference.values) {
        expect(_request(), _request(), reason: comfort.name);
      }
    });

    test('it has no side: the reading direction cannot reach it', () {
      for (final direction in TextDirection.values) {
        expect(_request(), _request(), reason: direction.name);
      }
    });

    test('nothing of it ever moves: Motion None changes nothing — a '
        'demand is not a movement', () {
      for (final motion in MotionPreference.values) {
        expect(_request(), _request(), reason: motion.name);
      }
    });
  });

  group('Governance — the executable scans ship with the request', () {
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

    final requestFile = File(
      'lib/foundation/design_kit/navigation/mentora_navigation_request.dart',
    );

    void refuse(Map<String, RegExp> forbidden, String because) {
      final source = codeOf(requestFile);
      for (final entry in forbidden.entries) {
        expect(
          entry.value.hasMatch(source),
          isFalse,
          reason: '${requestFile.path}: $because ${entry.key}',
        );
      }
    }

    test('a demand imports the places, and nothing else', () {
      final imports = RegExp(
        r'^import (.*);',
        multiLine: true,
      ).allMatches(codeOf(requestFile)).map((match) => match.group(1)).toList();

      expect(imports, ["'mentora_route.dart'"]);
    });

    test('a demand never navigates: no navigator, no framework route, '
        'no history, no back stack, no address', () {
      refuse({
        'a navigator': RegExp(
          r'(?<![A-Za-z])(Navigator|GoRouter|AutoRoute)(?![A-Za-z])',
        ),
        'a framework route': RegExp(
          r'(?<![A-Za-z])(Route<|PageRoute|MaterialPageRoute|'
          r'CupertinoPageRoute)(?![A-Za-z])',
        ),
        'a history or a stack': RegExp(
          r'(?<![A-Za-z])(History|BackStack|history|backStack|pop|push)'
          r'\s*[(.<=:]',
        ),
        'an address or a deep link': RegExp(
          r'(?<![A-Za-z])(Uri|url|Url|URL|DeepLink|deepLink|pushNamed|'
          r'routeName)\s*[:.(=<]',
        ),
        'a network': RegExp(
          r'(?<![A-Za-z])(http|HttpClient|WebSocket|Firestore)(?![A-Za-z])',
        ),
      }, 'it never carries');
    });

    test('a demand never builds and never moves: no widget, no '
        'context, no animation', () {
      refuse({
        'a widget': RegExp(r'(?<![A-Za-z])Widget(?![A-Za-z])'),
        'a build context': RegExp(r'(?<![A-Za-z])BuildContext(?![A-Za-z])'),
        'a page or a screen': RegExp(
          r'(?<![A-Za-z])(Page|Screen|Scaffold)\s*[(.<]',
        ),
        'an animation': RegExp(
          r'(?<![A-Za-z])(AnimationController|Animation<|FadeTransition|'
          r'SlideTransition|Curve|Duration)(?![A-Za-z])',
        ),
      }, 'it never carries');
    });

    test('a demand knows no platform and no presentation', () {
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

    test('a demand holds no state, no position-by-number and no '
        'mutation', () {
      final source = codeOf(requestFile);
      refuse({
        'a position by number': RegExp(
          r'(?<![A-Za-z])(currentIndex|selectedIndex|int\s+\w*[Ii]ndex|'
          r'\.indexOf\()',
        ),
        'a mutation': RegExp(r'(?<![A-Za-z])(late|var)\s'),
        'a setter': RegExp(r'(?<![A-Za-z])set\s+\w+\('),
        'an untyped value': RegExp(
          r'(?<![A-Za-z])(dynamic|Object\?)(?![A-Za-z])',
        ),
      }, 'it never carries');
      // Every field of every class in the file is final.
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

    test('a demand decides nothing: no business, no permission, no '
        'promise, no engine', () {
      refuse({
        'a business domain': RegExp(
          r'(?<![A-Za-z])(User|Wallet|Product|Expert|Invoice|Business|'
          r'Account|Profile|Model|Repository|Entity)(?![a-z])',
        ),
        'a permission': RegExp(
          r'(?<![A-Za-z])(permission|granted|denied|role|admin|guard)'
          r'\s*[:.(=]',
        ),
        'a promise': RegExp(
          r'(?<![A-Za-z])(Future|Stream|async|await)(?![A-Za-z])',
        ),
        'a flow or an engine': RegExp(
          r'(?<![A-Za-z])(Flow|Engine|Controller|Coordinator|Service)'
          r'(?![A-Za-z])',
        ),
      }, 'it never carries');
    });

    test('the boundary stands on every side: the demand answers none '
        'of the other four questions', () {
      final source = codeOf(requestFile);

      // Not WHERE the person is — that is the state.
      expect(
        RegExp(
          r'(?<![A-Za-z])(MentoraNavigationState|active\w*|current\w*)'
          r'(?![A-Za-z])',
        ).hasMatch(source),
        isFalse,
        reason: 'the request never knows where the person is',
      );
      // Not WHAT IS POSSIBLE — that is the graph.
      expect(
        RegExp(
          r'(?<![A-Za-z])(MentoraNavigationGraph|MentoraTransition|'
          r'transitions|reachableFrom|allows)(?![A-Za-z(])',
        ).hasMatch(source),
        isFalse,
        reason: 'the request never answers what is possible',
      );
      expect(source.contains('reachableFrom'), isFalse);
      expect(source.contains('allows('), isFalse);
      // Not WHAT A CONTEXT WAS TOLD — that is the announcement.
      expect(
        source.contains('MentoraNavigationAnnouncement'),
        isFalse,
        reason: 'the request never speaks to a working context',
      );
      // And the places it checks against keep their one owner.
      expect(
        RegExp(r'registry\.routes').hasMatch(source),
        isTrue,
        reason: 'the demand is checked against the one gathering',
      );
    });

    test('one navigation request exists, inside the Design Kit and '
        'nowhere else', () {
      final declarations = <String>[];
      for (final file in dartFilesOf('lib')) {
        for (final match in RegExp(
          r'class\s+([A-Z]\w*NavigationRequest)(?![A-Za-z])',
        ).allMatches(codeOf(file))) {
          declarations.add(
            '${match.group(1)} in ${file.path.replaceAll(r'\', '/')}',
          );
        }
      }
      expect(declarations, [
        'MentoraNavigationRequest in '
            'lib/foundation/design_kit/navigation/'
            'mentora_navigation_request.dart',
      ]);
    });
  });
}
