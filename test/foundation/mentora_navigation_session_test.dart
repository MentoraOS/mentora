import 'dart:io';

import 'package:flutter/material.dart' show TextDirection;
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_navigation_announcement.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_navigation_coordinator.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_navigation_graph.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_navigation_request.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_navigation_resolution.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_navigation_session.dart';
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
    entryRouteId: 'entree',
    transitions:
        transitions ??
        [
          MentoraTransition(fromRouteId: 'entree', toRouteId: 'accueil'),
          MentoraTransition(fromRouteId: 'accueil', toRouteId: 'consultation'),
        ],
  );
}

/// One whole dialogue, and the session that carries it.
MentoraNavigationSession _session({
  MentoraNavigationGraph? graph,
  String activeRouteId = 'accueil',
  MentoraRoute? asked,
  MentoraRoute? resolved,
  String? announcedId,
  MentoraNavigationState? stateOfSession,
  MentoraNavigationRequest? requestOfSession,
  MentoraNavigationResolution? resolutionOfSession,
}) {
  final topology = graph ?? _graph();
  final askedRoute = asked ?? _place('consultation');
  final demand = MentoraNavigationRequest(route: askedRoute);
  final state = MentoraNavigationState(
    graph: topology,
    activeRouteId: activeRouteId,
  );
  final resolution = MentoraNavigationResolution(
    request: demand,
    resolvedRoute: resolved ?? askedRoute,
  );
  final coordinator = MentoraNavigationCoordinator(
    state: state,
    request: demand,
    resolution: resolution,
    announcement: MentoraNavigationAnnouncement(
      destinationId: announcedId ?? activeRouteId,
    ),
  );
  return MentoraNavigationSession(
    state: stateOfSession ?? state,
    request: requestOfSession ?? demand,
    resolution: resolutionOfSession ?? resolution,
    coordinator: coordinator,
  );
}

void main() {
  group('MentoraNavigationSession — the dialogue currently carried', () {
    test('a session is the four parts of the dialogue in progress, and '
        'a whole session passes whole', () {
      final session = _session();

      expect(session.state.activeRouteId, 'accueil');
      expect(session.request.route.id, 'consultation');
      expect(session.resolution.resolvedRoute.id, 'consultation');
      expect(session.coordinator.announcement.destinationId, 'accueil');
      session.verify();
    });

    test('every part is required by the TYPE: a session missing a part '
        'does not compile', () {
      final session = _session();

      expect(session.state, isA<MentoraNavigationState>());
      expect(session.request, isA<MentoraNavigationRequest>());
      expect(session.resolution, isA<MentoraNavigationResolution>());
      expect(session.coordinator, isA<MentoraNavigationCoordinator>());
    });

    test('the parts travel whole and strictly intact', () {
      final graph = _graph();
      final asked = _place('consultation');
      final demand = MentoraNavigationRequest(route: asked);
      final state = MentoraNavigationState(
        graph: graph,
        activeRouteId: 'accueil',
      );
      final resolution = MentoraNavigationResolution(
        request: demand,
        resolvedRoute: asked,
      );
      final coordinator = MentoraNavigationCoordinator(
        state: state,
        request: demand,
        resolution: resolution,
        announcement: const MentoraNavigationAnnouncement(
          destinationId: 'accueil',
        ),
      );
      final session = MentoraNavigationSession(
        state: state,
        request: demand,
        resolution: resolution,
        coordinator: coordinator,
      );

      expect(identical(session.state, state), isTrue);
      expect(identical(session.request, demand), isTrue);
      expect(identical(session.resolution, resolution), isTrue);
      expect(identical(session.coordinator, coordinator), isTrue);
    });

    test('the session reaches past none of its parts: the topology and '
        'the gathering stay behind the state, with their one holder', () {
      final graph = _graph();
      final session = _session(graph: graph);

      // The one topology is reachable only THROUGH the parts — the
      // session holds no field for it, and its source cannot even
      // name it (scanned below).
      expect(identical(session.state.graph, graph), isTrue);
      expect(identical(session.coordinator.graph, session.state.graph), isTrue);
    });

    test('the session states which dialogue is in progress, and states '
        'nothing more: verifying decides nothing about the passage', () {
      // The demand asks for a passage that was never declared — and
      // the session stands: whether the passage is authorised is the
      // policy's answer, and whether it happens is nobody's here.
      _session(
        activeRouteId: 'accueil',
        asked: _place('entree', nature: MentoraRouteNature.entry),
      ).verify();
    });

    test('verifying a session moves no one and changes nothing, twice '
        'over', () {
      final graph = _graph();
      final session = _session(graph: graph);

      session.verify();
      session.verify();

      expect(session, _session(graph: graph));
      expect(session.state.activeRouteId, 'accueil');
      expect(session.request.route.id, 'consultation');
    });

    test('a new dialogue is a new session: the old one never changes', () {
      final graph = _graph();
      final before = _session(graph: graph);
      final after = _session(
        graph: graph,
        activeRouteId: 'consultation',
        asked: _place('detail'),
      );

      expect(before.state.activeRouteId, 'accueil');
      expect(after.state.activeRouteId, 'consultation');
      expect(before, isNot(equals(after)));
      expect(before, _session(graph: graph));
    });

    test('two sessions carrying the same dialogue ARE the same '
        'session', () {
      final graph = _graph();

      expect(_session(graph: graph), _session(graph: graph));
      expect(_session(graph: graph).hashCode, _session(graph: graph).hashCode);
      expect({_session(graph: graph), _session(graph: graph)}, hasLength(1));
    });

    test('a session differs by any part of its dialogue', () {
      final graph = _graph();

      expect(
        _session(graph: graph),
        isNot(_session(graph: graph, activeRouteId: 'entree')),
      );
      expect(
        _session(graph: graph),
        isNot(_session(graph: graph, asked: _place('accueil'))),
      );
      expect(
        _session(graph: graph),
        isNot(_session(graph: graph, announcedId: 'consultation')),
      );
    });

    test('two sessions over two topologies are never the same session: '
        'a product declares its topology once', () {
      expect(_session(), isNot(_session()));
    });

    test('a session is never equal to something that is not a '
        'session', () {
      final session = _session();

      expect(session, isNot(equals(session.coordinator)));
      expect(session, isNot(equals('session')));
    });

    test('a session is immutable: it is built const, and the same '
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
      const state = MentoraNavigationState(
        graph: graph,
        activeRouteId: 'entree',
      );
      const request = MentoraNavigationRequest(
        route: MentoraRoute(
          id: 'entree',
          name: 'L’entrée',
          nature: MentoraRouteNature.entry,
        ),
      );
      const resolution = MentoraNavigationResolution(
        request: request,
        resolvedRoute: MentoraRoute(
          id: 'entree',
          name: 'L’entrée',
          nature: MentoraRouteNature.entry,
        ),
      );
      const coordinator = MentoraNavigationCoordinator(
        state: state,
        request: request,
        resolution: resolution,
        announcement: MentoraNavigationAnnouncement(destinationId: 'entree'),
      );
      const first = MentoraNavigationSession(
        state: state,
        request: request,
        resolution: resolution,
        coordinator: coordinator,
      );
      const second = MentoraNavigationSession(
        state: state,
        request: request,
        resolution: resolution,
        coordinator: coordinator,
      );

      expect(identical(first, second), isTrue);
    });
  });

  group('Fail closed — every refusal keeps its owner’s voice', () {
    void refuses(MentoraNavigationSession session, String fragment) {
      expect(
        () => session.verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains(fragment),
          ),
        ),
      );
    }

    test('an invalid gathering is refused — the registry’s voice, '
        'unrewritten', () {
      refuses(
        _session(
          graph: _graph(routes: const [], transitions: const []),
        ),
        'empty registry is refused',
      );
    });

    test('an invalid topology is refused — the graph’s voice, '
        'unrewritten', () {
      refuses(
        _session(
          graph: _graph(
            transitions: [
              MentoraTransition(fromRouteId: 'entree', toRouteId: 'accueil'),
            ],
          ),
        ),
        'No path leads to "consultation"',
      );
    });

    test('an invalid position is refused — the state’s voice, '
        'unrewritten', () {
      refuses(
        _session(activeRouteId: 'ailleurs'),
        'cannot be somewhere the product does not go',
      );
    });

    test('an invalid demand is refused — the demand’s voice, '
        'unrewritten', () {
      refuses(
        _session(asked: _place('ailleurs')),
        'only ask to go to a place the product declared',
      );
      refuses(
        _session(asked: _place('consultation', name: '')),
        'without a name cannot be offered',
      );
    });

    test('a substitution is refused — the resolution’s voice, '
        'unrewritten', () {
      refuses(_session(resolved: _place('accueil')), 'is a substitution');
    });

    test('an echo that does not repeat the truth is refused — the '
        'coordinator’s voice, unrewritten', () {
      refuses(_session(announcedId: 'consultation'), 'no second truth');
      refuses(_session(announcedId: ''), 'tells a context nothing');
    });

    test('a coordinator speaking of another position is refused — the '
        'session’s only kind of refusal: the dialogue is one', () {
      final graph = _graph();
      refuses(
        _session(
          graph: graph,
          stateOfSession: MentoraNavigationState(
            graph: graph,
            activeRouteId: 'entree',
          ),
        ),
        'another position than the one this session carries',
      );
    });

    test('a coordinator speaking of another demand is refused', () {
      refuses(
        _session(
          requestOfSession: MentoraNavigationRequest(route: _place('accueil')),
        ),
        'another demand than the one this session carries',
      );
    });

    test('a coordinator speaking of another answer is refused', () {
      final other = MentoraNavigationRequest(route: _place('accueil'));
      refuses(
        _session(
          resolutionOfSession: MentoraNavigationResolution(
            request: other,
            resolvedRoute: _place('accueil'),
          ),
        ),
        'another answer than the one this session carries',
      );
    });

    test('the coordinator speaks before the agreements: a broken voice '
        'below is heard before a broken agreement here', () {
      // Both are wrong: the echo does not repeat the truth AND the
      // session's request disagrees with the coordinator's. The
      // coordinator's voice comes first.
      refuses(
        _session(
          announcedId: 'consultation',
          requestOfSession: MentoraNavigationRequest(route: _place('accueil')),
        ),
        'no second truth',
      );
    });
  });

  group('A dialogue in progress is indifferent to every presentation', () {
    test('it stays itself under every one of the four themes', () {
      final graph = _graph();
      for (final variant in ThemeVariantId.values) {
        expect(
          _session(graph: graph),
          _session(graph: graph),
          reason: variant.name,
        );
      }
      expect(ThemeVariantId.values, hasLength(4));
    });

    test('it stays itself under every one of the four font scales', () {
      final graph = _graph();
      for (final scale in FontScalePreference.values) {
        expect(
          _session(graph: graph),
          _session(graph: graph),
          reason: scale.name,
        );
      }
      expect(FontScalePreference.values, hasLength(4));
    });

    test('it stays itself under every reading comfort', () {
      final graph = _graph();
      for (final comfort in ReadingComfortPreference.values) {
        expect(
          _session(graph: graph),
          _session(graph: graph),
          reason: comfort.name,
        );
      }
    });

    test('it has no side: the reading direction cannot reach it', () {
      final graph = _graph();
      for (final direction in TextDirection.values) {
        expect(
          _session(graph: graph),
          _session(graph: graph),
          reason: direction.name,
        );
      }
    });

    test('nothing of it ever moves: stating the dialogue is not a '
        'movement, and Motion None changes nothing', () {
      final graph = _graph();
      for (final motion in MotionPreference.values) {
        expect(
          _session(graph: graph),
          _session(graph: graph),
          reason: motion.name,
        );
      }
    });
  });

  group('Governance — the executable scans ship with the session', () {
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

    final sessionFile = File(
      'lib/foundation/design_kit/navigation/mentora_navigation_session.dart',
    );

    void refuse(Map<String, RegExp> forbidden, String because) {
      final source = codeOf(sessionFile);
      for (final entry in forbidden.entries) {
        expect(
          entry.value.hasMatch(source),
          isFalse,
          reason: '${sessionFile.path}: $because ${entry.key}',
        );
      }
    }

    test('a session imports the four parts of the dialogue, and '
        'nothing else', () {
      final imports = RegExp(
        r'^import (.*);',
        multiLine: true,
      ).allMatches(codeOf(sessionFile)).map((match) => match.group(1)).toList();

      expect(imports, [
        "'mentora_navigation_coordinator.dart'",
        "'mentora_navigation_request.dart'",
        "'mentora_navigation_resolution.dart'",
        "'mentora_navigation_state.dart'",
      ]);
    });

    test('a session knows no framework: no navigator, no router, no '
        'widget, no context, no animation, no theme, no platform', () {
      refuse({
        'a navigator or a router': RegExp(
          r'(?<![A-Za-z])(Navigator|GoRouter|AutoRoute|RouterDelegate|'
          r'Router)(?![A-Za-z])',
        ),
        'a framework route': RegExp(
          r'(?<![A-Za-z])(Route<|PageRoute|MaterialPageRoute|'
          r'CupertinoPageRoute)(?![A-Za-z])',
        ),
        'a widget or a context': RegExp(
          r'(?<![A-Za-z])(Widget|BuildContext)(?![A-Za-z])',
        ),
        'an animation or a gesture': RegExp(
          r'(?<![A-Za-z])(AnimationController|Animation<|FadeTransition|'
          r'SlideTransition|Curve|Duration|Gesture\w*)(?![A-Za-z])',
        ),
        'a platform or a presentation': RegExp(
          r'(?<![A-Za-z])(Platform|TargetPlatform|kIsWeb|MediaQuery|'
          r'LayoutBuilder)(?![A-Za-z])',
        ),
        'an ambient theme': RegExp(r'Theme\.of\('),
      }, 'it never carries');
    });

    test('a session is no machine: no engine, no pipeline, no flow, no '
        'service, no controller, no state machine', () {
      refuse({
        'a machinery': RegExp(
          r'(?<![A-Za-z])(Engine|Controller|Service|Flow|Pipeline|'
          r'Orchestrator|Machine|Workflow)(?![A-Za-z])',
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

    test('a session has no memory: no history, no pile, no undo, no '
        'index, no position by number', () {
      refuse({
        'a history or a pile': RegExp(
          r'(?<![A-Za-z])(History|BackStack|history|backStack|Stack|Undo|'
          r'Redo|undo|redo|pop|push|previous\w*|visited)\s*[(.<=:]',
        ),
        'a memory of its own': RegExp(
          r'(?<![A-Za-z])(memory|cache|remember\w*)\s*[:.(=]',
        ),
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
    });

    test('every field of the session is final: a dialogue in progress '
        'is stated, never edited', () {
      final source = codeOf(sessionFile);
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

    test('a session knows no business and no permission', () {
      refuse({
        'a business domain': RegExp(
          r'(?<![A-Za-z])(User|Wallet|Product|Expert|Invoice|Business|'
          r'Account|Profile|Model|Repository|Entity)(?![a-z])',
        ),
        'a permission': RegExp(
          r'(?<![A-Za-z])(permission|granted|denied|role|admin|guard)'
          r'\s*[:.(=]',
        ),
        'a network or a backend': RegExp(
          r'(?<![A-Za-z])(http|HttpClient|WebSocket|Firestore)(?![A-Za-z])',
        ),
      }, 'it never carries');
    });

    test('a session reaches past none of its parts: it cannot even '
        'name the topology, the gathering, a place or a passage', () {
      final source = codeOf(sessionFile);

      for (final beyond in const [
        'MentoraNavigationGraph',
        'MentoraRouteRegistry',
        'MentoraTransition',
        'MentoraRoute',
        'MentoraNavigationPolicy',
        'MentoraNavigationAnnouncement',
        'MentoraDestination',
      ]) {
        expect(
          RegExp('(?<![A-Za-z])$beyond(?![A-Za-z])').hasMatch(source),
          isFalse,
          reason:
              'the session composes its four parts, and $beyond is '
              'not one of them',
        );
      }
      expect(source.contains('reachableFrom'), isFalse);
      expect(source.contains('allows('), isFalse);
      expect(source.contains('permits('), isFalse);
    });

    test('a session judges nothing in another voice’s place: the '
        'coordinator is verified by the coordinator, and the only '
        'checks of its own are the three agreements', () {
      final source = codeOf(sessionFile);

      expect(
        RegExp(r'coordinator\.verify\(\)').hasMatch(source),
        isTrue,
        reason: 'the dialogue is verified by its own order of voices',
      );
      // The three agreements — and no other verification exists: the
      // session's own checks all read `coordinator.<part> != <part>`.
      expect(
        RegExp(r'coordinator\.state\s*!=\s*state').hasMatch(source),
        isTrue,
      );
      expect(
        RegExp(r'coordinator\.request\s*!=\s*request').hasMatch(source),
        isTrue,
      );
      expect(
        RegExp(r'coordinator\.resolution\s*!=\s*resolution').hasMatch(source),
        isTrue,
      );
      // No verification of a part in the part's stead.
      expect(RegExp(r'state\.verify\(').hasMatch(source), isFalse);
      expect(RegExp(r'request\.verify\(').hasMatch(source), isFalse);
      expect(RegExp(r'resolution\.verify\(').hasMatch(source), isFalse);
    });

    test('one navigation session exists, inside the Design Kit and '
        'nowhere else — and the sessions of the application layer are '
        'other concepts, untouched', () {
      final declarations = <String>[];
      for (final file in dartFilesOf('lib')) {
        for (final match in RegExp(
          r'class\s+([A-Z]\w*NavigationSession)(?![A-Za-z])',
        ).allMatches(codeOf(file))) {
          declarations.add(
            '${match.group(1)} in ${file.path.replaceAll(r'\', '/')}',
          );
        }
      }
      expect(declarations, [
        'MentoraNavigationSession in '
            'lib/foundation/design_kit/navigation/'
            'mentora_navigation_session.dart',
      ]);

      // Within the foundation, the word Session has one owner.
      final sessions = <String>[];
      for (final file in dartFilesOf('lib/foundation')) {
        for (final match in RegExp(
          r'class\s+([A-Z]\w*Session)(?![A-Za-z])',
        ).allMatches(codeOf(file))) {
          sessions.add(match.group(1)!);
        }
      }
      expect(sessions, ['MentoraNavigationSession']);
    });

    test('the whole navigation vocabulary still knows no framework: '
        'ten files, zero framework imports', () {
      for (final name in const [
        'mentora_route.dart',
        'mentora_navigation_graph.dart',
        'mentora_navigation_state.dart',
        'mentora_navigation_request.dart',
        'mentora_navigation_resolution.dart',
        'mentora_navigation_announcement.dart',
        'mentora_navigation_coordinator.dart',
        'mentora_navigation_policy.dart',
        'mentora_navigation_session.dart',
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
      // And the two pure FACTS import nothing at all: a place and an
      // echo need nothing to be true.
      for (final name in const [
        'mentora_route.dart',
        'mentora_navigation_announcement.dart',
      ]) {
        final source = codeOf(
          File('lib/foundation/design_kit/navigation/$name'),
        );
        expect(
          RegExp(r'^import ', multiLine: true).hasMatch(source),
          isFalse,
          reason: '$name: a fact needs nothing to be true',
        );
      }
    });
  });
}
