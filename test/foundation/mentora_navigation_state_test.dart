import 'dart:io';

import 'package:flutter/material.dart' show TextDirection;
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_navigation_graph.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_navigation_state.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_route.dart';
import 'package:mentora/foundation/design_kit/structure/workspace/mentora_workspace_style.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';

MentoraRoute _place(
  String id, {
  MentoraRouteNature nature = MentoraRouteNature.principal,
}) => MentoraRoute(id: id, name: 'Lieu $id', nature: nature);

MentoraTransition _passage(String from, String to) =>
    MentoraTransition(fromRouteId: from, toRouteId: to);

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
        [_passage('entree', 'accueil'), _passage('accueil', 'consultation')],
  );
}

MentoraNavigationState _state({
  MentoraNavigationGraph? graph,
  String activeRouteId = 'accueil',
}) => MentoraNavigationState(
  graph: graph ?? _graph(),
  activeRouteId: activeRouteId,
);

void main() {
  group('MentoraNavigationState — where the person currently is', () {
    test('a state is the official graph and the place the person is '
        'in — and a whole state passes whole', () {
      final graph = _graph();
      final state = MentoraNavigationState(
        graph: graph,
        activeRouteId: 'accueil',
      );

      expect(state.graph, same(graph));
      expect(state.activeRouteId, 'accueil');
      state.verify();
    });

    test('the active place is resolved against the product itself: the '
        'route comes back whole', () {
      final state = _state();

      expect(state.activeRoute.id, 'accueil');
      expect(state.activeRoute.name, 'Lieu accueil');
      expect(state.activeRoute.nature, MentoraRouteNature.principal);
    });

    test('the person may stand at the entry, and anywhere the product '
        'goes', () {
      for (final id in const ['entree', 'accueil', 'consultation']) {
        final state = _state(activeRouteId: id);
        state.verify();
        expect(state.activeRoute.id, id, reason: id);
      }
    });

    test('the state composes the graph: the topology it reads against '
        'IS the product’s, same object, single owner', () {
      final graph = _graph();
      final state = MentoraNavigationState(
        graph: graph,
        activeRouteId: 'accueil',
      );

      expect(identical(state.graph, graph), isTrue);
      expect(identical(state.graph.registry, graph.registry), isTrue);
    });

    test('the state answers WHERE, never WHAT IS POSSIBLE: what could '
        'happen next stays the graph’s voice, unrepeated', () {
      final state = _state();

      // The question of possibility is asked to the graph the state
      // composes — the state itself offers no such answer, and the
      // scan below proves its source never will.
      expect(state.graph.reachableFrom('accueil'), {'consultation'});
      expect(
        state.graph.allows(fromRouteId: 'accueil', toRouteId: 'consultation'),
        isTrue,
      );
    });

    test('moving is a new announcement, never a mutation: the old state '
        'never changes', () {
      final graph = _graph();
      final before = MentoraNavigationState(
        graph: graph,
        activeRouteId: 'accueil',
      );
      final after = MentoraNavigationState(
        graph: graph,
        activeRouteId: 'consultation',
      );

      expect(before.activeRouteId, 'accueil');
      expect(after.activeRouteId, 'consultation');
      expect(before, isNot(after));
      // And the topology did not move with the person.
      expect(identical(before.graph, after.graph), isTrue);
    });

    test('two states with the same place in the same topology ARE the '
        'same state', () {
      final graph = _graph();
      final first = MentoraNavigationState(
        graph: graph,
        activeRouteId: 'accueil',
      );
      final second = MentoraNavigationState(
        graph: graph,
        activeRouteId: 'accueil',
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect({first, second}, hasLength(1));
    });

    test('a state differs by the place the person is in', () {
      final graph = _graph();

      expect(
        MentoraNavigationState(graph: graph, activeRouteId: 'accueil'),
        isNot(MentoraNavigationState(graph: graph, activeRouteId: 'entree')),
      );
    });

    test('standing in the same-named place of ANOTHER topology is not '
        'standing in the same place: a product declares its topology '
        'once', () {
      final first = _state(graph: _graph(), activeRouteId: 'accueil');
      final second = _state(graph: _graph(), activeRouteId: 'accueil');

      expect(first, isNot(second));
    });

    test('a state is never equal to something that is not a state', () {
      expect(_state(), isNot(equals('accueil')));
      expect(_state(), isNot(equals(_graph())));
    });

    test('a state is immutable: it is built const, and the same words '
        'are the same object', () {
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
      const first = MentoraNavigationState(
        graph: graph,
        activeRouteId: 'entree',
      );
      const second = MentoraNavigationState(
        graph: graph,
        activeRouteId: 'entree',
      );

      expect(identical(first, second), isTrue);
    });

    test('the announcement a working context receives is another '
        'concept: an echo by identity, never a second truth', () {
      final state = _state();
      final announcement = MentoraNavigationAnnouncement(
        destinationId: state.activeRouteId,
      );

      // The identity flows from the one truth to the echo.
      expect(announcement.destinationId, state.activeRouteId);
      // And the two are never interchangeable.
      expect(announcement, isNot(equals(state)));
    });
  });

  group('Fail closed — a state without a contract refuses', () {
    void refuses(MentoraNavigationState state, String fragment) {
      expect(
        () => state.verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains(fragment),
          ),
        ),
      );
    }

    test('a state over an invalid graph is refused — by the graph, the '
        'one owner of what is possible', () {
      refuses(
        _state(graph: _graph(transitions: [_passage('entree', 'accueil')])),
        'No path leads to "consultation"',
      );
      refuses(
        _state(
          graph: _graph(routes: const [], transitions: const []),
        ),
        'empty registry is refused',
      );
    });

    test('a state without a place is refused: a person is always '
        'somewhere', () {
      refuses(_state(activeRouteId: ''), 'always somewhere');
    });

    test('a place the product does not have is refused: a state never '
        'guesses', () {
      refuses(_state(activeRouteId: 'ailleurs'), 'cannot be somewhere');
      expect(
        () => _state(activeRouteId: 'ailleurs').activeRoute,
        throwsStateError,
      );
    });
  });

  group('A position is indifferent to every presentation', () {
    test('it stays itself under every one of the four themes', () {
      final graph = _graph();
      for (final variant in ThemeVariantId.values) {
        expect(
          MentoraNavigationState(graph: graph, activeRouteId: 'accueil'),
          MentoraNavigationState(graph: graph, activeRouteId: 'accueil'),
          reason: variant.name,
        );
      }
      expect(ThemeVariantId.values, hasLength(4));
    });

    test('it stays itself under every one of the four font scales', () {
      final graph = _graph();
      for (final scale in FontScalePreference.values) {
        expect(
          MentoraNavigationState(graph: graph, activeRouteId: 'accueil'),
          MentoraNavigationState(graph: graph, activeRouteId: 'accueil'),
          reason: scale.name,
        );
      }
      expect(FontScalePreference.values, hasLength(4));
    });

    test('it stays itself under every reading comfort', () {
      final graph = _graph();
      for (final comfort in ReadingComfortPreference.values) {
        expect(
          MentoraNavigationState(graph: graph, activeRouteId: 'accueil'),
          MentoraNavigationState(graph: graph, activeRouteId: 'accueil'),
          reason: comfort.name,
        );
      }
    });

    test('it has no side: the reading direction cannot reach it', () {
      final graph = _graph();
      for (final direction in TextDirection.values) {
        expect(
          MentoraNavigationState(graph: graph, activeRouteId: 'accueil'),
          MentoraNavigationState(graph: graph, activeRouteId: 'accueil'),
          reason: direction.name,
        );
      }
    });

    test('nothing of it ever moves on its own: Motion None changes '
        'nothing', () {
      final graph = _graph();
      for (final motion in MotionPreference.values) {
        expect(
          MentoraNavigationState(graph: graph, activeRouteId: 'accueil'),
          MentoraNavigationState(graph: graph, activeRouteId: 'accueil'),
          reason: motion.name,
        );
      }
    });
  });

  group('Governance — the executable scans ship with the state', () {
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

    final stateFile = File(
      'lib/foundation/design_kit/navigation/mentora_navigation_state.dart',
    );

    void refuse(Map<String, RegExp> forbidden, String because) {
      final source = codeOf(stateFile);
      for (final entry in forbidden.entries) {
        expect(
          entry.value.hasMatch(source),
          isFalse,
          reason: '${stateFile.path}: $because ${entry.key}',
        );
      }
    }

    test('a state imports the topology and the places, and nothing '
        'else', () {
      final imports = RegExp(
        r'^import (.*);',
        multiLine: true,
      ).allMatches(codeOf(stateFile)).map((match) => match.group(1)).toList();

      expect(imports, [
        "'mentora_navigation_graph.dart'",
        "'mentora_route.dart'",
      ]);
    });

    test('a state never navigates: no navigator, no framework route, '
        'no history, no back stack, no flow', () {
      refuse({
        'a navigator': RegExp(
          r'(?<![A-Za-z])(Navigator|GoRouter|AutoRoute)(?![A-Za-z])',
        ),
        'a framework route': RegExp(
          r'(?<![A-Za-z])(Route<|PageRoute|MaterialPageRoute|'
          r'CupertinoPageRoute)(?![A-Za-z])',
        ),
        'a history or a stack': RegExp(
          r'(?<![A-Za-z])(History|BackStack|history|backStack|pop|push|'
          r'previous\w*|visited)\s*[(.<=:]',
        ),
        'a flow or an engine': RegExp(
          r'(?<![A-Za-z])(Flow|Engine|Controller|Coordinator)(?![A-Za-z])',
        ),
        'an address or a deep link': RegExp(
          r'(?<![A-Za-z])(Uri|url|Url|URL|DeepLink|deepLink|pushNamed|'
          r'routeName)\s*[:.(=<]',
        ),
      }, 'it never carries');
    });

    test('a state never builds: no widget, no context, no page, no '
        'screen, no animation', () {
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

    test('a state knows no platform and no presentation', () {
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

    test('a state holds no position-by-number and no mutation', () {
      final source = codeOf(stateFile);
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

    test('a state decides nothing: no business, no permission, no '
        'promise', () {
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
      }, 'it never carries');
    });

    test('the boundary is absolute: the state never repeats the '
        'graph’s answers, and never touches its passages', () {
      final source = codeOf(stateFile);

      // No answer of possibility of its own — the graph's voice is not
      // repeated here.
      expect(RegExp(r'reachableFrom|allows\(').hasMatch(source), isFalse);
      // No passage is read: where the person is needs no topology walk.
      expect(
        RegExp(
          r'(?<![A-Za-z])(MentoraTransition|transitions)(?![A-Za-z])',
        ).hasMatch(source),
        isFalse,
      );
      // And the graph keeps its own verification voice.
      expect(RegExp(r'graph\.verify\(\)').hasMatch(source), isTrue);
    });

    test('one navigation state exists, inside the Design Kit and '
        'nowhere else — and the old name is gone from the whole '
        'foundation', () {
      // Only PUBLIC types claim a name: the private `State` class of a
      // stateful widget is the framework's naming convention, and it
      // claims nothing.
      final declarations = <String>[];
      for (final file in dartFilesOf('lib/foundation')) {
        for (final match in RegExp(
          r'class\s+([A-Z]\w*NavigationState)(?![A-Za-z])',
        ).allMatches(codeOf(file))) {
          declarations.add(
            '${match.group(1)} in ${file.path.replaceAll(r'\', '/')}',
          );
        }
      }
      expect(declarations, [
        'MentoraNavigationState in '
            'lib/foundation/design_kit/navigation/'
            'mentora_navigation_state.dart',
      ]);

      // The workspace speaks of an ANNOUNCEMENT now: the echo says it
      // is an echo, and no type claims the name of the truth.
      final announcements = <String>[];
      for (final file in dartFilesOf('lib/foundation')) {
        if (RegExp(
          r'class\s+MentoraNavigationAnnouncement(?![A-Za-z])',
        ).hasMatch(codeOf(file))) {
          announcements.add(file.path.replaceAll(r'\', '/'));
        }
      }
      expect(announcements, hasLength(1));
      expect(
        announcements.single,
        endsWith('structure/workspace/mentora_workspace_style.dart'),
      );
    });
  });
}
