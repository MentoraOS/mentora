import 'dart:io';

import 'package:flutter/material.dart' show TextDirection;
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_navigation_graph.dart';
import 'package:mentora/foundation/design_kit/navigation/mentora_route.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';

MentoraRoute _place(
  String id, {
  MentoraRouteNature nature = MentoraRouteNature.principal,
}) => MentoraRoute(id: id, name: 'Lieu $id', nature: nature);

MentoraTransition _passage(String from, String to) =>
    MentoraTransition(fromRouteId: from, toRouteId: to);

/// The product the tests walk: an entry, a principal level, and an
/// interior place reached from it.
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
            _place('detail', nature: MentoraRouteNature.interior),
          ],
    ),
    entryRouteId: entryRouteId,
    transitions:
        transitions ??
        [
          _passage('entree', 'accueil'),
          _passage('accueil', 'consultation'),
          _passage('consultation', 'detail'),
          _passage('detail', 'accueil'),
        ],
  );
}

void main() {
  group('MentoraTransition — one allowed passage between two places', () {
    test('a passage is its two identities, and nothing else', () {
      const passage = MentoraTransition(
        fromRouteId: 'accueil',
        toRouteId: 'consultation',
      );

      expect(passage.fromRouteId, 'accueil');
      expect(passage.toRouteId, 'consultation');
    });

    test('two passages with the same words ARE the same passage', () {
      expect(_passage('a', 'b'), _passage('a', 'b'));
      expect(_passage('a', 'b').hashCode, _passage('a', 'b').hashCode);
      expect({_passage('a', 'b'), _passage('a', 'b')}, hasLength(1));
    });

    test('a passage differs by either of its ends, and a passage is '
        'never its reverse', () {
      expect(_passage('a', 'b'), isNot(_passage('a', 'c')));
      expect(_passage('a', 'b'), isNot(_passage('c', 'b')));
      expect(_passage('a', 'b'), isNot(_passage('b', 'a')));
    });

    test('a passage is immutable: the same words are the same object', () {
      const first = MentoraTransition(fromRouteId: 'a', toRouteId: 'b');
      const second = MentoraTransition(fromRouteId: 'a', toRouteId: 'b');

      expect(identical(first, second), isTrue);
    });
  });

  group('MentoraNavigationGraph — which places lead to which places', () {
    test('a graph is the one gathering, one entry and the passages — '
        'and a whole graph passes whole', () {
      final graph = _graph();

      expect(graph.registry.routes, hasLength(4));
      expect(graph.entryRouteId, 'entree');
      expect(graph.transitions, hasLength(4));
      graph.verify();
    });

    test('the entry is ONE place by the TYPE: a second entry has '
        'nowhere to be written', () {
      // The field is a single identity — not a list, not a set. What
      // the compiler already refuses, no run-time check repeats.
      expect(_graph().entryRouteId, isA<String>());
    });

    test('the graph gathers nothing itself: the places it speaks of ARE '
        'the registry, same object, single owner', () {
      final graph = _graph();

      expect(identical(graph.registry.routes, graph.registry.routes), isTrue);
      // And the refusal of a duplicated place is the REGISTRY speaking
      // — the graph adds no second voice.
      expect(
        () => _graph(
          routes: [_place('entree'), _place('entree')],
          transitions: const [],
        ).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('Two places never share one identity'),
          ),
        ),
      );
    });

    test('reachable places are exactly what was declared', () {
      final graph = _graph();

      expect(graph.reachableFrom('accueil'), {'consultation'});
      expect(graph.reachableFrom('consultation'), {'detail'});
      expect(graph.reachableFrom('entree'), {'accueil'});
    });

    test('a place declared to lead nowhere leads nowhere: nothing is '
        'computed, nothing is completed', () {
      final graph = _graph(
        transitions: [
          _passage('entree', 'accueil'),
          _passage('accueil', 'consultation'),
          _passage('accueil', 'detail'),
        ],
      );
      graph.verify();

      expect(graph.reachableFrom('detail'), isEmpty);
      expect(graph.reachableFrom('consultation'), isEmpty);
    });

    test('asking about a place the product does not have is refused: '
        'the topology never guesses', () {
      expect(() => _graph().reachableFrom('ailleurs'), throwsStateError);
    });

    test('a passage is allowed exactly when it was declared', () {
      final graph = _graph();

      expect(
        graph.allows(fromRouteId: 'accueil', toRouteId: 'consultation'),
        isTrue,
      );
      // The reverse was never declared: a topology has directions.
      expect(
        graph.allows(fromRouteId: 'consultation', toRouteId: 'accueil'),
        isFalse,
      );
      expect(graph.allows(fromRouteId: 'entree', toRouteId: 'detail'), isFalse);
    });

    test('connectivity holds through chains: a place reached only at '
        'the end of a path is reached', () {
      _graph(
        transitions: [
          _passage('entree', 'accueil'),
          _passage('accueil', 'consultation'),
          _passage('consultation', 'detail'),
        ],
      ).verify();
    });

    test('a graph is immutable: it is built const, and the same words '
        'are the same object', () {
      const first = MentoraNavigationGraph(
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
      const second = MentoraNavigationGraph(
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

      expect(identical(first, second), isTrue);
    });

    test('a graph of one place is whole: entering is reaching', () {
      _graph(
        routes: [_place('entree', nature: MentoraRouteNature.entry)],
        transitions: const [],
      ).verify();
    });
  });

  group('Fail closed — a topology without a contract refuses', () {
    void refuses(MentoraNavigationGraph graph, String fragment) {
      expect(
        () => graph.verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains(fragment),
          ),
        ),
      );
    }

    test('a graph with no place at all is refused — by the registry, '
        'the one owner of that refusal', () {
      refuses(
        _graph(routes: const [], transitions: const []),
        'empty registry is refused',
      );
    });

    test('a graph without an entry is refused', () {
      refuses(_graph(entryRouteId: ''), 'without an entry');
    });

    test('an entry that is not a place of the product is refused', () {
      refuses(_graph(entryRouteId: 'ailleurs'), 'never guesses');
    });

    test('a passage from an unknown place is refused', () {
      refuses(
        _graph(
          transitions: [
            _passage('entree', 'accueil'),
            _passage('accueil', 'consultation'),
            _passage('consultation', 'detail'),
            _passage('ailleurs', 'accueil'),
          ],
        ),
        'leads from nowhere',
      );
    });

    test('a passage to an unknown place is refused', () {
      refuses(
        _graph(
          transitions: [
            _passage('entree', 'accueil'),
            _passage('accueil', 'consultation'),
            _passage('consultation', 'detail'),
            _passage('detail', 'ailleurs'),
          ],
        ),
        'leads nowhere',
      );
    });

    test('a place never leads to itself — the foundation forbids it, '
        'and says why', () {
      refuses(
        _graph(
          transitions: [
            _passage('entree', 'accueil'),
            _passage('accueil', 'consultation'),
            _passage('consultation', 'detail'),
            _passage('accueil', 'accueil'),
          ],
        ),
        'never leads to itself',
      );
    });

    test('a passage declared twice is refused: one truth, once', () {
      refuses(
        _graph(
          transitions: [
            _passage('entree', 'accueil'),
            _passage('accueil', 'consultation'),
            _passage('consultation', 'detail'),
            _passage('accueil', 'consultation'),
          ],
        ),
        'declared once',
      );
    });

    test('a place no path leads to is refused, wherever it stands', () {
      refuses(
        _graph(
          transitions: [
            _passage('entree', 'accueil'),
            _passage('accueil', 'consultation'),
          ],
        ),
        'No path leads to "detail"',
      );
      // And reachability follows passages, never declaration order:
      // a place listed FIRST but never led to is just as unreachable.
      refuses(
        _graph(
          routes: [
            _place('perdu'),
            _place('entree', nature: MentoraRouteNature.entry),
            _place('accueil'),
          ],
          transitions: [_passage('entree', 'accueil')],
        ),
        'No path leads to "perdu"',
      );
    });

    test('the refusals of the places themselves still speak with the '
        'registry’s voice', () {
      refuses(
        _graph(routes: [_place(''), _place('accueil')], transitions: const []),
        'not a place',
      );
    });
  });

  group('A topology is indifferent to every presentation', () {
    test('it stays itself under every one of the four themes', () {
      for (final variant in ThemeVariantId.values) {
        expect(_passage('a', 'b'), _passage('a', 'b'), reason: variant.name);
      }
      expect(ThemeVariantId.values, hasLength(4));
    });

    test('it stays itself under every one of the four font scales', () {
      for (final scale in FontScalePreference.values) {
        expect(_passage('a', 'b'), _passage('a', 'b'), reason: scale.name);
      }
      expect(FontScalePreference.values, hasLength(4));
    });

    test('it stays itself under every reading comfort', () {
      for (final comfort in ReadingComfortPreference.values) {
        expect(_passage('a', 'b'), _passage('a', 'b'), reason: comfort.name);
      }
    });

    test('it has no side: the reading direction cannot reach it', () {
      for (final direction in TextDirection.values) {
        expect(_passage('a', 'b'), _passage('a', 'b'), reason: direction.name);
      }
    });

    test('nothing of it ever moves: Motion None changes nothing', () {
      for (final motion in MotionPreference.values) {
        expect(_passage('a', 'b'), _passage('a', 'b'), reason: motion.name);
      }
    });
  });

  group('Governance — the executable scans ship with the graph', () {
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

    final graphFile = File(
      'lib/foundation/design_kit/navigation/mentora_navigation_graph.dart',
    );

    void refuse(Map<String, RegExp> forbidden, String because) {
      final source = codeOf(graphFile);
      for (final entry in forbidden.entries) {
        expect(
          entry.value.hasMatch(source),
          isFalse,
          reason: '${graphFile.path}: $because ${entry.key}',
        );
      }
    }

    test('a topology imports the places, and nothing else', () {
      final imports = RegExp(
        r'^import (.*);',
        multiLine: true,
      ).allMatches(codeOf(graphFile)).map((match) => match.group(1)).toList();

      expect(imports, ["'mentora_route.dart'"]);
    });

    test('a topology never navigates: no navigator, no framework '
        'route, no history, no back stack', () {
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
          r'\s*[(.<=]',
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

    test('a topology never builds: no widget, no context, no page, no '
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

    test('a topology knows no platform and no presentation', () {
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

    test('a topology holds no state: it does not know where a person '
        'is, and remembers nothing', () {
      final source = codeOf(graphFile);
      refuse({
        'a current place': RegExp(
          r'(?<![A-Za-z])(current\w*|selected\w*|active\w*|visited)'
          r'\s*[:.(=]',
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

    test('a topology decides nothing: no business, no permission, no '
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

    test('the graph gathers no places of its own: the registry stays '
        'the one holder, and no second list of routes exists', () {
      final source = codeOf(graphFile);

      expect(
        RegExp(r'final\s+List<MentoraRoute>').hasMatch(source),
        isFalse,
        reason: 'the places are held by the registry, and by it alone',
      );
      expect(
        RegExp(r'registry\.verify\(\)').hasMatch(source),
        isTrue,
        reason: 'the places are verified by their one owner',
      );
    });

    test('one graph and one transition exist, inside the Design Kit '
        'and nowhere else', () {
      for (final single in const [
        'MentoraNavigationGraph',
        'MentoraTransition',
      ]) {
        final places = <String>[];
        for (final file in dartFilesOf('lib')) {
          if (RegExp('class\\s+$single(?![A-Za-z])').hasMatch(codeOf(file))) {
            places.add(file.path.replaceAll(r'\', '/'));
          }
        }
        expect(places, hasLength(1), reason: single);
        expect(
          places.single,
          endsWith('design_kit/navigation/mentora_navigation_graph.dart'),
          reason: single,
        );
      }
    });

    test('no second topology exists anywhere in the foundation', () {
      final declarations = <String>[];
      for (final file in dartFilesOf('lib/foundation')) {
        for (final match in RegExp(
          r'class\s+(\w*(Graph|Topology))(?![A-Za-z])',
        ).allMatches(codeOf(file))) {
          declarations.add(
            '${match.group(1)} in ${file.path.replaceAll(r'\', '/')}',
          );
        }
      }
      expect(declarations, [
        'MentoraNavigationGraph in '
            'lib/foundation/design_kit/navigation/'
            'mentora_navigation_graph.dart',
      ]);
    });
  });
}
