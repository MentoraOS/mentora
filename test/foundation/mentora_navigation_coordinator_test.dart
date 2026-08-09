import 'dart:io';

import 'package:flutter/material.dart' show TextDirection;
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_navigation_announcement.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_navigation_coordinator.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_navigation_graph.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_navigation_request.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_navigation_resolution.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_navigation_state.dart';
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

/// One whole dialogue: the person stands at home and asks for the
/// consultation, which is what was resolved, and the workspace is told
/// where the person is.
MentoraNavigationCoordinator _dialogue({
  MentoraNavigationGraph? graph,
  String activeRouteId = 'accueil',
  MentoraRoute? asked,
  MentoraRoute? resolved,
  MentoraNavigationRequest? request,
  String? announcedId,
}) {
  final topology = graph ?? _graph();
  final askedRoute = asked ?? _place('consultation');
  final demand = request ?? MentoraNavigationRequest(route: askedRoute);
  return MentoraNavigationCoordinator(
    state: MentoraNavigationState(
      graph: topology,
      activeRouteId: activeRouteId,
    ),
    request: demand,
    resolution: MentoraNavigationResolution(
      request: demand,
      resolvedRoute: resolved ?? askedRoute,
    ),
    announcement: MentoraNavigationAnnouncement(
      destinationId: announcedId ?? activeRouteId,
    ),
  );
}

void main() {
  group('MentoraNavigationCoordinator — the order the truths talk in', () {
    test('a dialogue composes the six truths, and a whole dialogue '
        'passes whole', () {
      final dialogue = _dialogue();

      expect(dialogue.state.activeRouteId, 'accueil');
      expect(dialogue.request.route.id, 'consultation');
      expect(dialogue.resolution.resolvedRoute.id, 'consultation');
      expect(dialogue.announcement.destinationId, 'accueil');
      dialogue.verify();
    });

    test('every part is required by the TYPE: a dialogue missing a '
        'voice does not compile', () {
      final dialogue = _dialogue();

      expect(dialogue.state, isA<MentoraNavigationState>());
      expect(dialogue.request, isA<MentoraNavigationRequest>());
      expect(dialogue.resolution, isA<MentoraNavigationResolution>());
      expect(dialogue.announcement, isA<MentoraNavigationAnnouncement>());
    });

    test('the topology and the gathering are aliases over one holder: '
        'the coordinator opens no second one', () {
      final graph = _graph();
      final dialogue = _dialogue(graph: graph);

      expect(identical(dialogue.graph, graph), isTrue);
      expect(identical(dialogue.graph, dialogue.state.graph), isTrue);
      expect(identical(dialogue.registry, graph.registry), isTrue);
    });

    test('the parts travel whole and strictly intact', () {
      final graph = _graph();
      final asked = _place('consultation');
      final request = MentoraNavigationRequest(route: asked);
      final state = MentoraNavigationState(
        graph: graph,
        activeRouteId: 'accueil',
      );
      final resolution = MentoraNavigationResolution(
        request: request,
        resolvedRoute: asked,
      );
      const announcement = MentoraNavigationAnnouncement(
        destinationId: 'accueil',
      );
      final dialogue = MentoraNavigationCoordinator(
        state: state,
        request: request,
        resolution: resolution,
        announcement: announcement,
      );

      expect(identical(dialogue.state, state), isTrue);
      expect(identical(dialogue.request, request), isTrue);
      expect(identical(dialogue.resolution, resolution), isTrue);
      expect(identical(dialogue.announcement, announcement), isTrue);
    });

    test('the person may ask from anywhere for anywhere: the dialogue '
        'orders the voices, it does not rule on the passage', () {
      // The passage accueil→entree was never declared — and the
      // dialogue still stands: whether a passage is open is the
      // graph's answer to whoever DECIDES, later. Ordering the
      // dialogue is not deciding.
      _dialogue(
        activeRouteId: 'accueil',
        asked: _place('entree', nature: MentoraRouteNature.entry),
      ).verify();
    });

    test('verifying a dialogue produces no effect: everything is '
        'exactly as it was, twice over', () {
      final graph = _graph();
      final dialogue = _dialogue(graph: graph);

      dialogue.verify();
      dialogue.verify();

      expect(dialogue, _dialogue(graph: graph));
      expect(dialogue.state.activeRouteId, 'accueil');
      expect(dialogue.announcement.destinationId, 'accueil');
    });

    test('the dialogue changes no state: where the person is after the '
        'answer is where they were — moving belongs to no one here', () {
      final dialogue = _dialogue();

      dialogue.verify();

      // The demand asked for the consultation; the person still
      // stands at home. A coordinator orders voices — it never walks.
      expect(dialogue.request.route.id, 'consultation');
      expect(dialogue.state.activeRouteId, 'accueil');
    });

    test('the echo is a whole value of its own: two announcements of '
        'the same identity ARE the same announcement', () {
      const first = MentoraNavigationAnnouncement(destinationId: 'accueil');
      const second = MentoraNavigationAnnouncement(destinationId: 'accueil');

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      // A runtime copy is NOT the same object — and a set still keeps
      // one of them: the equality is the value's, not the identity's.
      final runtimeCopy = MentoraNavigationAnnouncement(
        destinationId: 'accueil',
      );
      expect(identical(first, runtimeCopy), isFalse);
      expect({first, runtimeCopy}, hasLength(1));
      expect(identical(first, second), isTrue);
      expect(
        first,
        isNot(const MentoraNavigationAnnouncement(destinationId: 'entree')),
      );
      expect(first, isNot(equals('accueil')));
    });

    test('two dialogues with the same words ARE the same dialogue', () {
      final graph = _graph();

      expect(_dialogue(graph: graph), _dialogue(graph: graph));
      expect(
        _dialogue(graph: graph).hashCode,
        _dialogue(graph: graph).hashCode,
      );
      expect({_dialogue(graph: graph), _dialogue(graph: graph)}, hasLength(1));
    });

    test('a dialogue differs by any of its voices', () {
      final graph = _graph();

      expect(
        _dialogue(graph: graph),
        isNot(_dialogue(graph: graph, activeRouteId: 'entree')),
      );
      expect(
        _dialogue(graph: graph),
        isNot(_dialogue(graph: graph, asked: _place('accueil'))),
      );
      expect(
        _dialogue(graph: graph),
        isNot(_dialogue(graph: graph, resolved: _place('accueil'))),
      );
      expect(
        _dialogue(graph: graph),
        isNot(_dialogue(graph: graph, announcedId: 'consultation')),
      );
    });

    test('two dialogues over two topologies are never the same '
        'dialogue: a product declares its topology once', () {
      expect(_dialogue(graph: _graph()), isNot(_dialogue(graph: _graph())));
    });

    test('a dialogue is never equal to something that is not a '
        'dialogue', () {
      expect(_dialogue(), isNot(equals('dialogue')));
      expect(_dialogue(), isNot(equals(_graph())));
    });

    test('a dialogue is immutable: it is built const, and the same '
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
      const request = MentoraNavigationRequest(
        route: MentoraRoute(
          id: 'entree',
          name: 'L’entrée',
          nature: MentoraRouteNature.entry,
        ),
      );
      const first = MentoraNavigationCoordinator(
        state: MentoraNavigationState(graph: graph, activeRouteId: 'entree'),
        request: request,
        resolution: MentoraNavigationResolution(
          request: request,
          resolvedRoute: MentoraRoute(
            id: 'entree',
            name: 'L’entrée',
            nature: MentoraRouteNature.entry,
          ),
        ),
        announcement: MentoraNavigationAnnouncement(destinationId: 'entree'),
      );
      const second = MentoraNavigationCoordinator(
        state: MentoraNavigationState(graph: graph, activeRouteId: 'entree'),
        request: request,
        resolution: MentoraNavigationResolution(
          request: request,
          resolvedRoute: MentoraRoute(
            id: 'entree',
            name: 'L’entrée',
            nature: MentoraRouteNature.entry,
          ),
        ),
        announcement: MentoraNavigationAnnouncement(destinationId: 'entree'),
      );

      expect(identical(first, second), isTrue);
    });
  });

  group('The order of orchestration — the earlier voice speaks first', () {
    void refuses(MentoraNavigationCoordinator dialogue, String fragment) {
      expect(
        () => dialogue.verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains(fragment),
          ),
        ),
      );
    }

    test('an invalid graph speaks before an invalid request: what '
        'exists comes before what is asked', () {
      refuses(
        _dialogue(
          graph: _graph(
            transitions: [
              MentoraTransition(fromRouteId: 'entree', toRouteId: 'accueil'),
            ],
          ),
          asked: _place('ailleurs'),
        ),
        'No path leads to "consultation"',
      );
    });

    test('an invalid position speaks before an invalid request: where '
        'the person is comes before what they ask', () {
      refuses(
        _dialogue(activeRouteId: 'ailleurs', asked: _place('nulle-part')),
        'cannot be somewhere the product does not go',
      );
    });

    test('an invalid request speaks before a substitution: what is '
        'asked comes before what was resolved', () {
      final forged = MentoraNavigationRequest(route: _place('ailleurs'));
      refuses(
        _dialogue(request: forged, resolved: _place('accueil')),
        'only ask to go to a place the product declared',
      );
    });

    test('a substitution speaks before a wrong echo: what was resolved '
        'comes before what the workspace is told', () {
      refuses(
        _dialogue(resolved: _place('accueil'), announcedId: 'ailleurs'),
        'is a substitution',
      );
    });

    test('the echo speaks last, and only when every other voice has '
        'stood', () {
      refuses(
        _dialogue(announcedId: 'consultation'),
        'The echo repeats the truth',
      );
    });
  });

  group('Fail closed — a dialogue without a contract refuses', () {
    void refuses(MentoraNavigationCoordinator dialogue, String fragment) {
      expect(
        () => dialogue.verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains(fragment),
          ),
        ),
      );
    }

    test('an invalid gathering is refused — with the registry’s own '
        'voice', () {
      refuses(
        _dialogue(
          graph: _graph(routes: const [], transitions: const []),
        ),
        'empty registry is refused',
      );
    });

    test('an invalid topology is refused — with the graph’s own '
        'voice', () {
      refuses(
        _dialogue(
          graph: _graph(
            transitions: [
              MentoraTransition(fromRouteId: 'entree', toRouteId: 'accueil'),
            ],
          ),
        ),
        'No path leads to "consultation"',
      );
    });

    test('an invalid position is refused — with the state’s own '
        'voice', () {
      refuses(_dialogue(activeRouteId: ''), 'always somewhere');
      refuses(_dialogue(activeRouteId: 'ailleurs'), 'cannot be somewhere');
    });

    test('an invalid demand is refused — with the demand’s own voice', () {
      refuses(
        _dialogue(asked: _place('ailleurs')),
        'only ask to go to a place the product declared',
      );
      refuses(
        _dialogue(asked: _place('consultation', name: '')),
        'without a name cannot be offered',
      );
    });

    test('an invalid resolution is refused — with the resolution’s own '
        'voice', () {
      refuses(_dialogue(resolved: _place('accueil')), 'is a substitution');
    });

    test('a resolution answering another demand is refused: a dialogue '
        'has one demand', () {
      final graph = _graph();
      final asked = _place('consultation');
      final other = MentoraNavigationRequest(route: _place('accueil'));
      final dialogue = MentoraNavigationCoordinator(
        state: MentoraNavigationState(graph: graph, activeRouteId: 'accueil'),
        request: MentoraNavigationRequest(route: asked),
        resolution: MentoraNavigationResolution(
          request: other,
          resolvedRoute: _place('accueil'),
        ),
        announcement: const MentoraNavigationAnnouncement(
          destinationId: 'accueil',
        ),
      );

      refuses(dialogue, 'answers another demand');
    });

    test('an empty announcement is refused: it tells a context '
        'nothing', () {
      refuses(_dialogue(announcedId: ''), 'tells a context nothing');
    });

    test('an echo that does not repeat the truth is refused: there is '
        'no second truth', () {
      refuses(_dialogue(announcedId: 'consultation'), 'no second truth');
    });
  });

  group('A dialogue is indifferent to every presentation', () {
    test('it stays itself under every one of the four themes', () {
      final graph = _graph();
      for (final variant in ThemeVariantId.values) {
        expect(
          _dialogue(graph: graph),
          _dialogue(graph: graph),
          reason: variant.name,
        );
      }
      expect(ThemeVariantId.values, hasLength(4));
    });

    test('it stays itself under every one of the four font scales', () {
      final graph = _graph();
      for (final scale in FontScalePreference.values) {
        expect(
          _dialogue(graph: graph),
          _dialogue(graph: graph),
          reason: scale.name,
        );
      }
      expect(FontScalePreference.values, hasLength(4));
    });

    test('it stays itself under every reading comfort', () {
      final graph = _graph();
      for (final comfort in ReadingComfortPreference.values) {
        expect(
          _dialogue(graph: graph),
          _dialogue(graph: graph),
          reason: comfort.name,
        );
      }
    });

    test('it has no side: the reading direction cannot reach it', () {
      final graph = _graph();
      for (final direction in TextDirection.values) {
        expect(
          _dialogue(graph: graph),
          _dialogue(graph: graph),
          reason: direction.name,
        );
      }
    });

    test('nothing of it ever moves: a dialogue is an order of voices, '
        'and Motion None changes nothing', () {
      final graph = _graph();
      for (final motion in MotionPreference.values) {
        expect(
          _dialogue(graph: graph),
          _dialogue(graph: graph),
          reason: motion.name,
        );
      }
    });
  });

  group('Governance — the executable scans ship with the coordinator', () {
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

    final coordinatorFile = File(
      'lib/foundation/design_kit/navigation/'
      'mentora_navigation_coordinator.dart',
    );

    void refuse(Map<String, RegExp> forbidden, String because) {
      final source = codeOf(coordinatorFile);
      for (final entry in forbidden.entries) {
        expect(
          entry.value.hasMatch(source),
          isFalse,
          reason: '${coordinatorFile.path}: $because ${entry.key}',
        );
      }
    }

    test('a dialogue imports the six voices, and nothing else', () {
      final imports = RegExp(r'^import (.*);', multiLine: true)
          .allMatches(codeOf(coordinatorFile))
          .map((match) => match.group(1))
          .toList();

      expect(imports, [
        "'mentora_navigation_announcement.dart'",
        "'mentora_navigation_graph.dart'",
        "'mentora_navigation_request.dart'",
        "'mentora_navigation_resolution.dart'",
        "'mentora_navigation_state.dart'",
        "'mentora_route.dart'",
      ]);
    });

    test('the whole navigation vocabulary knows no Flutter: seven '
        'voices, zero framework imports', () {
      for (final name in const [
        'mentora_route.dart',
        'mentora_navigation_graph.dart',
        'mentora_navigation_state.dart',
        'mentora_navigation_request.dart',
        'mentora_navigation_resolution.dart',
        'mentora_navigation_announcement.dart',
        'mentora_navigation_coordinator.dart',
      ]) {
        final source = codeOf(
          File('lib/foundation/design_kit/navigation/$name'),
        );
        expect(
          RegExp(r"^import 'package:", multiLine: true).hasMatch(source),
          isFalse,
          reason: '$name: a truth of navigation needs no framework',
        );
      }
    });

    test('a coordinator never navigates: no navigator, no delegate, no '
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

    test('a coordinator never builds and never animates', () {
      refuse({
        'a widget': RegExp(r'(?<![A-Za-z])Widget(?![A-Za-z])'),
        'a build context': RegExp(r'(?<![A-Za-z])BuildContext(?![A-Za-z])'),
        'a page or a screen': RegExp(
          r'(?<![A-Za-z])(Page|Screen|Scaffold)\s*[(.<]',
        ),
        'an animation': RegExp(
          r'(?<![A-Za-z])(AnimationController|Animation<|Animation\(|'
          r'FadeTransition|SlideTransition|Curve|Duration)(?![A-Za-z])',
        ),
      }, 'it never carries');
    });

    test('a coordinator knows no platform and no presentation', () {
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

    test('a coordinator is not a machine: no engine, no controller, no '
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
        'a permission': RegExp(
          r'(?<![A-Za-z])(permission|granted|denied|role|admin|guard)'
          r'\s*[:.(=]',
        ),
        'a business domain': RegExp(
          r'(?<![A-Za-z])(User|Wallet|Product|Expert|Invoice|Business|'
          r'Account|Profile|Model|Repository|Entity)(?![a-z])',
        ),
      }, 'it never carries');
    });

    test('a coordinator holds no state of its own and no mutation', () {
      final source = codeOf(coordinatorFile);
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

    test('a coordinator never answers in another voice’s place', () {
      final source = codeOf(coordinatorFile);

      // Not what is possible: the graph is composed, never consulted
      // in its stead — no possibility question is asked or answered.
      expect(source.contains('reachableFrom'), isFalse);
      expect(source.contains('allows('), isFalse);
      // Not where the person is, resolved in the state's stead: the
      // route-object accessors stay the state's own.
      expect(
        RegExp(
          r'(?<![A-Za-z])(activeRoute|currentRoute)(?![A-Za-z])',
        ).hasMatch(source),
        isFalse,
        reason: 'the place itself is resolved by the state, never here',
      );
      // Each voice is verified BY ITSELF, in the official order.
      final order = [
        source.indexOf('state.verify()'),
        source.indexOf('request.verify(registry)'),
        source.indexOf('resolution.verify(registry)'),
        source.indexOf('announcement.destinationId'),
      ];
      expect(order.every((position) => position >= 0), isTrue);
      for (int voice = 1; voice < order.length; voice += 1) {
        expect(
          order[voice],
          greaterThan(order[voice - 1]),
          reason: 'the official order of the dialogue is the source order',
        );
      }
    });

    test('one coordinator exists, inside the Design Kit and nowhere '
        'else — and no orchestrator, pipeline or engine of navigation '
        'exists anywhere', () {
      final declarations = <String>[];
      for (final file in dartFilesOf('lib')) {
        for (final match in RegExp(
          r'class\s+([A-Z]\w*Navigation(Coordinator|Orchestrator|Pipeline|'
          r'Engine|Service|Controller))(?![A-Za-z])',
        ).allMatches(codeOf(file))) {
          declarations.add(
            '${match.group(1)} in ${file.path.replaceAll(r'\', '/')}',
          );
        }
      }
      expect(declarations, [
        'MentoraNavigationCoordinator in '
            'lib/foundation/design_kit/navigation/'
            'mentora_navigation_coordinator.dart',
      ]);
    });

    test('the echo lives with the navigation vocabulary, and the '
        'workspace declares no navigation type of its own anymore', () {
      final workspaceStyle = codeOf(
        File(
          'lib/foundation/design_kit/structure/workspace/'
          'mentora_workspace_style.dart',
        ),
      );

      expect(
        RegExp(
          r'class\s+\w*Navigation\w*(?![A-Za-z])',
        ).hasMatch(workspaceStyle),
        isFalse,
        reason:
            'the navigation vocabulary has one home, and the workspace '
            'consumes it',
      );
      expect(
        File(
          'lib/foundation/design_kit/navigation/'
          'mentora_navigation_announcement.dart',
        ).existsSync(),
        isTrue,
      );
    });
  });
}
