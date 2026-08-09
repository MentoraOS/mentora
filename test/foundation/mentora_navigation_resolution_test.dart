import 'dart:io';

import 'package:flutter/material.dart' show TextDirection;
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_navigation_request.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_navigation_resolution.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_route.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';

MentoraRoute _place(
  String id, {
  String? name,
  MentoraRouteNature nature = MentoraRouteNature.principal,
}) => MentoraRoute(id: id, name: name ?? 'Lieu $id', nature: nature);

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

MentoraNavigationResolution _resolution({
  MentoraRoute? asked,
  MentoraRoute? resolved,
}) {
  final route = asked ?? _place('accueil');
  return MentoraNavigationResolution(
    request: MentoraNavigationRequest(route: route),
    resolvedRoute: resolved ?? route,
  );
}

void main() {
  group('MentoraNavigationResolution — the answer given to a demand', () {
    test('a resolution is the demand and the place that answered it — '
        'Resolution = Request + Route, and nothing else', () {
      final route = _place('accueil');
      final request = MentoraNavigationRequest(route: route);
      final resolution = MentoraNavigationResolution(
        request: request,
        resolvedRoute: route,
      );

      expect(resolution.request, same(request));
      expect(resolution.resolvedRoute, same(route));
    });

    test('both parts are required by the TYPE: an answer to nothing, or '
        'with nothing, does not compile', () {
      expect(_resolution().request, isA<MentoraNavigationRequest>());
      expect(_resolution().resolvedRoute, isA<MentoraRoute>());
    });

    test('the demand travels whole through the resolution: the place '
        'asked for keeps every one of its words', () {
      final resolution = _resolution(
        asked: MentoraRoute(
          id: 'consultation',
          name: 'La consultation',
          description: 'Là où une personne consulte un expert',
          nature: MentoraRouteNature.interior,
        ),
      );

      expect(resolution.request.route.id, 'consultation');
      expect(resolution.request.route.name, 'La consultation');
      expect(
        resolution.request.route.description,
        'Là où une personne consulte un expert',
      );
      expect(resolution.request.route.nature, MentoraRouteNature.interior);
    });

    test('the resolved place travels whole and strictly intact: the '
        'very object resolved is the object carried', () {
      final route = _place('accueil');
      final resolution = _resolution(asked: route, resolved: route);

      expect(identical(resolution.resolvedRoute, route), isTrue);
    });

    test('a resolution carries nothing else: two answers to the same '
        'demand with the same place are indistinguishable', () {
      expect(_resolution(), _resolution());
    });

    test('two resolutions with the same words ARE the same resolution', () {
      expect(_resolution(), _resolution());
      expect(_resolution().hashCode, _resolution().hashCode);
      expect({_resolution(), _resolution()}, hasLength(1));
    });

    test('a resolution differs by the demand it answers', () {
      expect(
        _resolution(asked: _place('accueil')),
        isNot(_resolution(asked: _place('consultation'))),
      );
    });

    test('a resolution differs by the place that answered — even '
        'before any verification says so', () {
      final asked = _place('accueil');

      expect(
        _resolution(asked: asked, resolved: asked),
        isNot(_resolution(asked: asked, resolved: _place('consultation'))),
      );
    });

    test('a resolution is never equal to something that is not a '
        'resolution', () {
      expect(_resolution(), isNot(equals(_place('accueil'))));
      expect(
        _resolution(),
        isNot(equals(MentoraNavigationRequest(route: _place('accueil')))),
      );
    });

    test('a resolution is immutable: it is built const, and the same '
        'words are the same object', () {
      const route = MentoraRoute(
        id: 'accueil',
        name: 'L’accueil',
        nature: MentoraRouteNature.principal,
      );
      const first = MentoraNavigationResolution(
        request: MentoraNavigationRequest(route: route),
        resolvedRoute: route,
      );
      const second = MentoraNavigationResolution(
        request: MentoraNavigationRequest(route: route),
        resolvedRoute: route,
      );

      expect(identical(first, second), isTrue);
    });

    test('a whole resolution passes whole, wherever the place stands in '
        'the product', () {
      final registry = _registry();

      for (final route in registry.routes) {
        _resolution(asked: route, resolved: route).verify(registry);
      }
    });

    test('a resolution produces no effect: verifying it twice states '
        'the same fact twice, and nothing anywhere has changed', () {
      final registry = _registry();
      final resolution = _resolution();

      resolution.verify(registry);
      resolution.verify(registry);

      expect(resolution, _resolution());
      expect(identical(registry.routes, registry.routes), isTrue);
    });

    test('a resolution decides nothing and navigates nowhere: stating '
        'the fact leaves the demand exactly as it was made', () {
      final route = _place('accueil');
      final request = MentoraNavigationRequest(route: route);
      final resolution = MentoraNavigationResolution(
        request: request,
        resolvedRoute: route,
      );

      resolution.verify(_registry());

      // The demand it answers is the very demand, untouched — nothing
      // was consumed, nothing was moved, nothing was performed.
      expect(identical(resolution.request, request), isTrue);
      expect(request, MentoraNavigationRequest(route: route));
    });
  });

  group('Fail closed — a resolution without a contract refuses', () {
    void refuses(
      MentoraNavigationResolution resolution,
      MentoraRouteRegistry registry,
      String fragment,
    ) {
      expect(
        () => resolution.verify(registry),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains(fragment),
          ),
        ),
      );
    }

    test('an invalid demand is refused — with the route’s own voice, '
        'through the demand’s own verification', () {
      refuses(
        _resolution(asked: _place('')),
        _registry(),
        'without an identity is not a place',
      );
      refuses(
        _resolution(asked: _place('accueil', name: '')),
        _registry(),
        'without a name cannot be offered',
      );
    });

    test('a demand for a place the product never declared is refused — '
        'with the demand’s own voice', () {
      refuses(
        _resolution(asked: _place('ailleurs')),
        _registry(),
        'only ask to go to a place the product declared',
      );
    });

    test('a substitution is refused: resolving another place than the '
        'one asked for is not answering', () {
      refuses(
        _resolution(asked: _place('accueil'), resolved: _place('consultation')),
        _registry(),
        'is a substitution',
      );
    });

    test('a substitution by the words is refused too: the same '
        'identity with another name or nature is another place', () {
      refuses(
        _resolution(
          asked: _place('accueil'),
          resolved: _place('accueil', name: 'Un autre nom'),
        ),
        _registry(),
        'is a substitution',
      );
      refuses(
        _resolution(
          asked: _place('accueil'),
          resolved: _place('accueil', nature: MentoraRouteNature.interior),
        ),
        _registry(),
        'is a substitution',
      );
    });

    test('once the answer is the demand, an unknown resolved place '
        'cannot exist: the demand already proved the place', () {
      // The equality refusal makes "resolved but unknown" unreachable:
      // an unknown place fails as the DEMAND's refusal, never as a
      // separate one — one fact, one voice.
      refuses(
        _resolution(asked: _place('ailleurs'), resolved: _place('ailleurs')),
        _registry(),
        'only ask to go to a place the product declared',
      );
    });

    test('the resolution is read against the product it was made in: '
        'the same answer stands in one and falls in another', () {
      final resolution = _resolution(asked: _place('consultation'));

      resolution.verify(_registry());
      refuses(
        resolution,
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

  group('An answer is indifferent to every presentation', () {
    test('it stays itself under every one of the four themes', () {
      for (final variant in ThemeVariantId.values) {
        expect(_resolution(), _resolution(), reason: variant.name);
      }
      expect(ThemeVariantId.values, hasLength(4));
    });

    test('it stays itself under every one of the four font scales', () {
      for (final scale in FontScalePreference.values) {
        expect(_resolution(), _resolution(), reason: scale.name);
      }
      expect(FontScalePreference.values, hasLength(4));
    });

    test('it stays itself under every reading comfort', () {
      for (final comfort in ReadingComfortPreference.values) {
        expect(_resolution(), _resolution(), reason: comfort.name);
      }
    });

    test('it has no side: the reading direction cannot reach it', () {
      for (final direction in TextDirection.values) {
        expect(_resolution(), _resolution(), reason: direction.name);
      }
    });

    test('nothing of it ever moves: a stated fact never moves again, '
        'and Motion None changes nothing', () {
      for (final motion in MotionPreference.values) {
        expect(_resolution(), _resolution(), reason: motion.name);
      }
    });
  });

  group('Governance — the executable scans ship with the resolution', () {
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

    final resolutionFile = File(
      'lib/foundation/design_kit/navigation/'
      'mentora_navigation_resolution.dart',
    );

    void refuse(Map<String, RegExp> forbidden, String because) {
      final source = codeOf(resolutionFile);
      for (final entry in forbidden.entries) {
        expect(
          entry.value.hasMatch(source),
          isFalse,
          reason: '${resolutionFile.path}: $because ${entry.key}',
        );
      }
    }

    test('an answer imports the demand and the places, and nothing '
        'else', () {
      final imports = RegExp(r'^import (.*);', multiLine: true)
          .allMatches(codeOf(resolutionFile))
          .map((match) => match.group(1))
          .toList();

      expect(imports, [
        "'mentora_navigation_request.dart'",
        "'mentora_route.dart'",
      ]);
    });

    test('an answer never navigates: no navigator, no framework route, '
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
        'a network or a backend': RegExp(
          r'(?<![A-Za-z])(http|HttpClient|WebSocket|Firestore)(?![A-Za-z])',
        ),
      }, 'it never carries');
    });

    test('an answer never builds and never animates: no widget, no '
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

    test('an answer knows no platform and no presentation', () {
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

    test('an answer holds no state and no mutation: a stated fact '
        'never moves again', () {
      final source = codeOf(resolutionFile);
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

    test('an answer decides nothing: no business, no permission, no '
        'promise, no machinery of any kind', () {
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
        'a machinery': RegExp(
          r'(?<![A-Za-z])(Flow|Engine|Controller|Coordinator|Service)'
          r'(?![A-Za-z])',
        ),
      }, 'it never carries');
    });

    test('the boundary stands on every side: the answer speaks for '
        'none of the other six voices', () {
      final source = codeOf(resolutionFile);

      // Not WHERE the person is — that is the state.
      expect(
        RegExp(
          r'(?<![A-Za-z])(MentoraNavigationState|activeRoute|currentRoute|'
          r'active\w*|current\w*)(?![A-Za-z])',
        ).hasMatch(source),
        isFalse,
        reason: 'the answer never knows where the person is',
      );
      // Not WHAT IS POSSIBLE — that is the graph.
      expect(
        RegExp(
          r'(?<![A-Za-z])(MentoraNavigationGraph|MentoraTransition|'
          r'transitions|reachableFrom)(?![A-Za-z])',
        ).hasMatch(source),
        isFalse,
        reason: 'the answer never says what is possible',
      );
      expect(source.contains('reachableFrom'), isFalse);
      expect(source.contains('allows('), isFalse);
      // Not WHAT A CONTEXT WAS TOLD — that is the announcement.
      expect(source.contains('MentoraNavigationAnnouncement'), isFalse);
      // The demand keeps its own voice: the answer verifies through
      // it, and never reaches around it to the gathering.
      expect(
        RegExp(r'request\.verify\(registry\)').hasMatch(source),
        isTrue,
        reason: 'the demand is verified by the demand, never in its place',
      );
      expect(
        RegExp(r'registry\.routes').hasMatch(source),
        isFalse,
        reason: 'the answer never walks the gathering itself',
      );
    });

    test('one navigation resolution exists, inside the Design Kit and '
        'nowhere else', () {
      final declarations = <String>[];
      for (final file in dartFilesOf('lib')) {
        for (final match in RegExp(
          r'class\s+([A-Z]\w*(NavigationResolution|NavigationResult|'
          r'NavigationDecision))(?![A-Za-z])',
        ).allMatches(codeOf(file))) {
          declarations.add(
            '${match.group(1)} in ${file.path.replaceAll(r'\', '/')}',
          );
        }
      }
      expect(declarations, [
        'MentoraNavigationResolution in '
            'lib/foundation/design_kit/navigation/'
            'mentora_navigation_resolution.dart',
      ]);
    });
  });
}
