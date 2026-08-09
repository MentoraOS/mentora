import 'dart:io';

import 'package:flutter/material.dart' show TextDirection;
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_navigation_graph.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_navigation_policy.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_navigation_request.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_route.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';

MentoraRoute _place(
  String id, {
  String? name,
  MentoraRouteNature nature = MentoraRouteNature.principal,
}) => MentoraRoute(id: id, name: name ?? 'Lieu $id', nature: nature);

MentoraNavigationGraph _graph({
  List<MentoraRoute>? routes,
  String entryRouteId = 'entree',
  List<MentoraTransition>? transitions,
}) {
  return MentoraNavigationGraph(
    registry: MentoraRouteRegistry(
      routes:
          routes ??
          [
            _place('entree', nature: MentoraRouteNature.entry),
            _place('accueil'),
            _place('consultation'),
          ],
    ),
    entryRouteId: entryRouteId,
    transitions:
        transitions ??
        [
          MentoraTransition(fromRouteId: 'entree', toRouteId: 'accueil'),
          MentoraTransition(fromRouteId: 'accueil', toRouteId: 'consultation'),
        ],
  );
}

MentoraNavigationPolicy _policy({MentoraNavigationGraph? graph}) =>
    MentoraNavigationPolicy(graph: graph ?? _graph());

MentoraNavigationRequest _ask(String id, {String? name}) =>
    MentoraNavigationRequest(route: _place(id, name: name));

void main() {
  group('MentoraNavigationPolicy — the authority of the rules', () {
    test('an authority is the topology it pronounces over, and a whole '
        'authority passes whole', () {
      final graph = _graph();
      final policy = MentoraNavigationPolicy(graph: graph);

      expect(policy.graph, same(graph));
      policy.verify();
    });

    test('the topology is required by the TYPE: an authority over '
        'nothing does not compile', () {
      expect(_policy().graph, isA<MentoraNavigationGraph>());
    });

    test('the gathering is an alias over the one holder: the policy '
        'opens no second one', () {
      final graph = _graph();
      final policy = MentoraNavigationPolicy(graph: graph);

      expect(identical(policy.registry, graph.registry), isTrue);
      expect(identical(policy.graph, graph), isTrue);
    });

    test('a declared passage is authorised: the answer is yes', () {
      final policy = _policy();

      expect(
        policy.permits(fromRouteId: 'accueil', request: _ask('consultation')),
        isTrue,
      );
      expect(
        policy.permits(fromRouteId: 'entree', request: _ask('accueil')),
        isTrue,
      );
    });

    test('an undeclared passage is not authorised: the answer is no — '
        'and a no is an answer, never an error', () {
      final policy = _policy();

      expect(
        policy.permits(fromRouteId: 'entree', request: _ask('consultation')),
        isFalse,
      );
    });

    test('the rules have directions: the reverse of a declared passage '
        'was not declared, and the answer is no', () {
      final policy = _policy();

      expect(
        policy.permits(fromRouteId: 'accueil', request: _ask('consultation')),
        isTrue,
      );
      expect(
        policy.permits(fromRouteId: 'consultation', request: _ask('accueil')),
        isFalse,
      );
    });

    test('the authority consults the topology, never repeats it: the '
        'answer IS the declared passage, for every pair of places', () {
      final graph = _graph();
      final policy = MentoraNavigationPolicy(graph: graph);

      for (final from in graph.registry.routes) {
        for (final to in graph.registry.routes) {
          if (from.id == to.id) continue;
          // The demand asks for the DECLARED place itself — asking
          // for a rebuilt one would be a forgery, and rightly refused.
          expect(
            policy.permits(
              fromRouteId: from.id,
              request: MentoraNavigationRequest(route: to),
            ),
            graph.allows(fromRouteId: from.id, toRouteId: to.id),
            reason: '${from.id} -> ${to.id}',
          );
        }
      }
    });

    test('pronouncing the rules moves no one: the answer changes '
        'nothing anywhere, twice over', () {
      final graph = _graph();
      final policy = MentoraNavigationPolicy(graph: graph);
      final request = _ask('consultation');

      final first = policy.permits(fromRouteId: 'accueil', request: request);
      final second = policy.permits(fromRouteId: 'accueil', request: request);

      expect(first, isTrue);
      expect(second, isTrue);
      expect(policy, MentoraNavigationPolicy(graph: graph));
      expect(request, _ask('consultation'));
      expect(identical(policy.graph, graph), isTrue);
    });

    test('a no decides no movement either: after the answer, nothing '
        'was produced — no state, no resolution, no announcement', () {
      final policy = _policy();

      final answer = policy.permits(
        fromRouteId: 'entree',
        request: _ask('consultation'),
      );

      // The answer is a bool, and only a bool: what happens with it
      // belongs to whoever asked. The scans prove the policy's source
      // cannot even name the types it must never produce.
      expect(answer, isFalse);
      expect(answer, isA<bool>());
    });

    test('two authorities over the same topology ARE the same '
        'authority', () {
      final graph = _graph();

      expect(
        MentoraNavigationPolicy(graph: graph),
        MentoraNavigationPolicy(graph: graph),
      );
      expect(
        MentoraNavigationPolicy(graph: graph).hashCode,
        MentoraNavigationPolicy(graph: graph).hashCode,
      );
      expect({
        MentoraNavigationPolicy(graph: graph),
        MentoraNavigationPolicy(graph: graph),
      }, hasLength(1));
    });

    test('two authorities over two topologies are never the same: a '
        'product declares its topology once', () {
      expect(_policy(), isNot(_policy()));
    });

    test('an authority is never equal to something that is not an '
        'authority', () {
      final graph = _graph();

      expect(MentoraNavigationPolicy(graph: graph), isNot(equals(graph)));
      expect(_policy(), isNot(equals('policy')));
    });

    test('an authority is immutable: it is built const, and the same '
        'words are the same object', () {
      const graph = MentoraNavigationGraph(
        registry: MentoraRouteRegistry(
          routes: [
            MentoraRoute(
              id: 'entree',
              name: 'L’entrée',
              nature: MentoraRouteNature.entry,
            ),
          ],
        ),
        entryRouteId: 'entree',
        transitions: [],
      );
      const first = MentoraNavigationPolicy(graph: graph);
      const second = MentoraNavigationPolicy(graph: graph);

      expect(identical(first, second), isTrue);
    });
  });

  group('Fail closed — malformed things are refused, not answered', () {
    test('an authority over an invalid topology refuses — with the '
        'graph’s own voice', () {
      expect(
        () => _policy(
          graph: _graph(
            transitions: [
              MentoraTransition(fromRouteId: 'entree', toRouteId: 'accueil'),
            ],
          ),
        ).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('No path leads to "consultation"'),
          ),
        ),
      );
    });

    test('an authority over an invalid gathering refuses — with the '
        'registry’s own voice', () {
      expect(
        () => _policy(
          graph: _graph(routes: const [], transitions: const []),
        ).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('empty registry is refused'),
          ),
        ),
      );
    });

    test('an invalid demand is refused — with the route’s own voice, '
        'through the demand’s own verification', () {
      expect(
        () => _policy().permits(fromRouteId: 'accueil', request: _ask('')),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('without an identity is not a place'),
          ),
        ),
      );
      expect(
        () => _policy().permits(
          fromRouteId: 'accueil',
          request: _ask('consultation', name: ''),
        ),
        throwsStateError,
      );
    });

    test('a demand for a place the product never declared is refused — '
        'with the demand’s own voice', () {
      expect(
        () => _policy().permits(
          fromRouteId: 'accueil',
          request: _ask('ailleurs'),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('only ask to go to a place the product declared'),
          ),
        ),
      );
    });

    test('a forged place is refused: the same identity with other '
        'words is outside the product', () {
      expect(
        () => _policy().permits(
          fromRouteId: 'accueil',
          request: _ask('consultation', name: 'Un autre nom'),
        ),
        throwsStateError,
      );
    });

    test('an origin that is not a place of the product is refused: an '
        'authority never guesses where a demand was made from', () {
      expect(
        () => _policy().permits(
          fromRouteId: 'ailleurs',
          request: _ask('consultation'),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('never guesses where a demand was made from'),
          ),
        ),
      );
    });

    test('the demand speaks before the origin: the order of the voices '
        'holds inside the judgment too', () {
      expect(
        () => _policy().permits(fromRouteId: 'ailleurs', request: _ask('')),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('without an identity is not a place'),
          ),
        ),
      );
    });
  });

  group('An authority is indifferent to every presentation', () {
    test('it stays itself under every one of the four themes', () {
      final graph = _graph();
      for (final variant in ThemeVariantId.values) {
        expect(
          MentoraNavigationPolicy(graph: graph),
          MentoraNavigationPolicy(graph: graph),
          reason: variant.name,
        );
      }
      expect(ThemeVariantId.values, hasLength(4));
    });

    test('it stays itself under every one of the four font scales', () {
      final graph = _graph();
      for (final scale in FontScalePreference.values) {
        expect(
          MentoraNavigationPolicy(graph: graph),
          MentoraNavigationPolicy(graph: graph),
          reason: scale.name,
        );
      }
      expect(FontScalePreference.values, hasLength(4));
    });

    test('it stays itself under every reading comfort', () {
      final graph = _graph();
      for (final comfort in ReadingComfortPreference.values) {
        expect(
          MentoraNavigationPolicy(graph: graph),
          MentoraNavigationPolicy(graph: graph),
          reason: comfort.name,
        );
      }
    });

    test('it has no side: the reading direction cannot reach it', () {
      final graph = _graph();
      for (final direction in TextDirection.values) {
        expect(
          MentoraNavigationPolicy(graph: graph),
          MentoraNavigationPolicy(graph: graph),
          reason: direction.name,
        );
      }
    });

    test('nothing of it ever moves: pronouncing the rules is not a '
        'movement, and Motion None changes nothing', () {
      final graph = _graph();
      for (final motion in MotionPreference.values) {
        expect(
          MentoraNavigationPolicy(graph: graph),
          MentoraNavigationPolicy(graph: graph),
          reason: motion.name,
        );
      }
    });
  });

  group('Governance — the executable scans ship with the policy', () {
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

    final policyFile = File(
      'lib/foundation/design_kit/navigation/mentora_navigation_policy.dart',
    );

    void refuse(Map<String, RegExp> forbidden, String because) {
      final source = codeOf(policyFile);
      for (final entry in forbidden.entries) {
        expect(
          entry.value.hasMatch(source),
          isFalse,
          reason: '${policyFile.path}: $because ${entry.key}',
        );
      }
    }

    test('an authority imports the topology, the demand and the '
        'places, and nothing else', () {
      final imports = RegExp(
        r'^import (.*);',
        multiLine: true,
      ).allMatches(codeOf(policyFile)).map((match) => match.group(1)).toList();

      expect(imports, [
        "'mentora_navigation_graph.dart'",
        "'mentora_navigation_request.dart'",
        "'mentora_route.dart'",
      ]);
    });

    test('an authority never navigates: no navigator, no delegate, no '
        'framework route, no history, no back stack', () {
      refuse({
        'a navigator': RegExp(
          r'(?<![A-Za-z])(Navigator|GoRouter|AutoRoute|RouterDelegate)'
          r'(?![A-Za-z])',
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

    test('an authority never builds and never animates', () {
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

    test('an authority knows no platform and no presentation', () {
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

    test('an authority is not a machine: no engine, no controller, no '
        'service, no flow, no listener, no promise', () {
      refuse({
        'a machinery': RegExp(
          r'(?<![A-Za-z])(Engine|Controller|Service|Flow|Pipeline|'
          r'Orchestrator)(?![A-Za-z])',
        ),
        'a notification of change': RegExp(
          r'(?<![A-Za-z])(setState|notifyListeners|addListener|'
          r'ChangeNotifier|ValueNotifier)(?![A-Za-z])',
        ),
        'a promise': RegExp(
          r'(?<![A-Za-z])(Future|Stream|async|await)(?![A-Za-z])',
        ),
      }, 'it never carries');
    });

    test('an authority knows no business permission: the rules of the '
        'product are the declared places and passages, nothing else', () {
      refuse({
        'a business permission': RegExp(
          r'(?<![A-Za-z])(permission|granted|denied|role|admin|guard)'
          r'\s*[:.(=]',
        ),
        'a business domain': RegExp(
          r'(?<![A-Za-z])(User|Wallet|Product|Expert|Invoice|Business|'
          r'Account|Profile|Model|Repository|Entity)(?![a-z])',
        ),
      }, 'it never carries');
    });

    test('an authority holds no state of its own and no mutation', () {
      final source = codeOf(policyFile);
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

    test('an authority produces none of the other voices: no state, no '
        'resolution, no announcement, no coordinator', () {
      final source = codeOf(policyFile);

      for (final voice in const [
        'MentoraNavigationState',
        'MentoraNavigationResolution',
        'MentoraNavigationAnnouncement',
        'MentoraNavigationCoordinator',
      ]) {
        expect(
          source.contains(voice),
          isFalse,
          reason: 'the policy cannot even name $voice',
        );
      }
      // And it does not know where the person is: the origin arrives
      // as an identity, handed by whoever asks.
      expect(
        RegExp(
          r'(?<![A-Za-z])(activeRoute|currentRoute)(?![A-Za-z])',
        ).hasMatch(source),
        isFalse,
      );
    });

    test('the authority consults the voices below it, never repeats '
        'them: the demand verifies itself, and the passage is the '
        'graph’s word', () {
      final source = codeOf(policyFile);

      expect(
        RegExp(r'request\.verify\(registry\)').hasMatch(source),
        isTrue,
        reason: 'the demand is verified by the demand, never in its place',
      );
      expect(
        RegExp(r'graph\.allows\(').hasMatch(source),
        isTrue,
        reason: 'the declared passage is the graph’s word, consulted',
      );
      expect(
        RegExp(r'graph\.verify\(\)').hasMatch(source),
        isTrue,
        reason: 'an authority over an invalid product pronounces nothing',
      );
      // It never re-walks the topology itself.
      expect(source.contains('reachableFrom'), isFalse);
      expect(
        RegExp(
          r'(?<![A-Za-z])(MentoraTransition|transitions)(?![A-Za-z])',
        ).hasMatch(source),
        isFalse,
        reason: 'the passages stay the graph’s own',
      );
    });

    test('one policy exists, inside the Design Kit and nowhere else — '
        'and no rules or authority type of navigation exists anywhere', () {
      final declarations = <String>[];
      for (final file in dartFilesOf('lib')) {
        for (final match in RegExp(
          r'class\s+([A-Z]\w*Navigation(Policy|Rules|Authority|Decision))'
          r'(?![A-Za-z])',
        ).allMatches(codeOf(file))) {
          declarations.add(
            '${match.group(1)} in ${file.path.replaceAll(r'\', '/')}',
          );
        }
      }
      expect(declarations, [
        'MentoraNavigationPolicy in '
            'lib/foundation/design_kit/navigation/'
            'mentora_navigation_policy.dart',
      ]);

      // And within the foundation, the word Policy has one owner.
      final policies = <String>[];
      for (final file in dartFilesOf('lib/foundation')) {
        for (final match in RegExp(
          r'class\s+([A-Z]\w*Policy)(?![A-Za-z])',
        ).allMatches(codeOf(file))) {
          policies.add(match.group(1)!);
        }
      }
      expect(policies, ['MentoraNavigationPolicy']);
    });
  });
}
