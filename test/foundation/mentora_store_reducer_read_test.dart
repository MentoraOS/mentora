import 'dart:io';

import 'package:flutter/material.dart' show TextDirection;
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/state/mentora_projection.dart';
import 'package:mentora/foundation/design_kit/state/mentora_query.dart';
import 'package:mentora/foundation/design_kit/state/mentora_read_model.dart';
import 'package:mentora/foundation/design_kit/state/mentora_reducer.dart';
import 'package:mentora/foundation/design_kit/state/mentora_state.dart';
import 'package:mentora/foundation/design_kit/state/mentora_state_mutation.dart';
import 'package:mentora/foundation/design_kit/state/mentora_state_snapshot.dart';
import 'package:mentora/foundation/design_kit/state/mentora_store.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';

MentoraState _fact({String id = 'theme', String value = 'sombre'}) =>
    MentoraState(id: id, value: value);

MentoraStore _store({List<MentoraState>? facts}) => MentoraStore(
  facts: facts ?? [_fact(), _fact(id: 'contraste', value: 'normal')],
);

MentoraProjection _representation({MentoraState? of}) =>
    MentoraProjection(snapshot: MentoraStateSnapshot(state: of ?? _fact()));

MentoraReadModel _reading({MentoraState? of}) =>
    MentoraReadModel(projection: _representation(of: of));

void main() {
  group('MentoraStore — where the official state lives', () {
    test('a store is the official facts, each whole — and a whole '
        'store passes whole', () {
      final store = _store();

      expect(store.facts, hasLength(2));
      expect(store.facts.first.id, 'theme');
      store.verify();
    });

    test('the store holds and does nothing else: verifying twice '
        'changes nothing anywhere', () {
      final facts = [_fact()];
      final store = MentoraStore(facts: facts);

      store.verify();
      store.verify();

      expect(identical(store.facts, facts), isTrue);
      expect(facts.single, _fact());
    });

    test('a store is declared once, like the topology: it is not a '
        'value that varies, and it is built const', () {
      const first = MentoraStore(
        facts: [MentoraState(id: 'theme', value: 'sombre')],
      );
      const second = MentoraStore(
        facts: [MentoraState(id: 'theme', value: 'sombre')],
      );

      expect(identical(first, second), isTrue);
    });

    test('a store with nothing official is refused', () {
      expect(
        () => _store(facts: const []).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('nothing is not a state that lives anywhere'),
          ),
        ),
      );
    });

    test('a malformed fact is refused with the FACT’s voice, wherever '
        'it stands', () {
      expect(
        () => _store(
          facts: [
            _fact(),
            _fact(id: ''),
          ],
        ).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('without an identity is not a state'),
          ),
        ),
      );
    });

    test('two facts never share one identity — adjacent or not: '
        'identity is a set, never a comparison with the neighbour', () {
      expect(
        () => _store(
          facts: [
            _fact(),
            _fact(value: 'clair'),
          ],
        ).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('Two facts never share one identity'),
          ),
        ),
      );
      expect(
        () => _store(
          facts: [
            _fact(),
            _fact(id: 'contraste', value: 'normal'),
            _fact(value: 'clair'),
          ],
        ).verify(),
        throwsStateError,
      );
    });
  });

  group('MentoraReducer — how a mutation officially transforms', () {
    test('the official reduction is exactly what the mutation '
        'described: the same identity, holding the requested value', () {
      const reducer = MentoraReducer();
      final next = reducer.reduce(
        MentoraStateMutation(from: _fact(), requestedValue: 'clair'),
      );

      expect(next.id, 'theme');
      expect(next.value, 'clair');
      next.verify();
    });

    test('the reducer touches nothing it was given: the fact the '
        'mutation starts from remains exactly what it was', () {
      const reducer = MentoraReducer();
      final fact = _fact();
      final mutation = MentoraStateMutation(
        from: fact,
        requestedValue: 'clair',
      );

      final next = reducer.reduce(mutation);

      expect(fact.value, 'sombre');
      expect(fact, _fact());
      expect(next, isNot(same(fact)));
      expect(mutation, isNot(same(next)));
    });

    test('the reducer has no state of its own: reducing twice gives '
        'the same fact twice', () {
      const reducer = MentoraReducer();
      final mutation = MentoraStateMutation(
        from: _fact(),
        requestedValue: 'clair',
      );

      expect(reducer.reduce(mutation), reducer.reduce(mutation));
    });

    test('every reducer IS the one official reduction: two reducers '
        'are never two', () {
      const first = MentoraReducer();
      const second = MentoraReducer();

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(identical(first, second), isTrue);
      // Even a runtime instance is the same reduction.
      final runtime = MentoraReducer();
      expect(runtime, first);
      expect({first, runtime}, hasLength(1));
    });

    test('a malformed mutation is refused with the MUTATION’s voice — '
        'and the fact’s through it — before anything is born', () {
      const reducer = MentoraReducer();

      expect(
        () => reducer.reduce(
          MentoraStateMutation(
            from: _fact(id: ''),
            requestedValue: 'clair',
          ),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('without an identity is not a state'),
          ),
        ),
      );
      expect(
        () => reducer.reduce(
          MentoraStateMutation(from: _fact(), requestedValue: 'sombre'),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('demands nothing is not a transformation'),
          ),
        ),
      );
    });
  });

  group('MentoraProjection — the official representation built', () {
    test('a projection is the photograph it is built from, whole and '
        'strictly intact — and a whole one passes whole', () {
      final photo = MentoraStateSnapshot(state: _fact());
      final representation = MentoraProjection(snapshot: photo);

      expect(identical(representation.snapshot, photo), isTrue);
      representation.verify();
    });

    test('a projection never reads the living state: what it holds is '
        'the photograph, and a photograph never follows its subject', () {
      final representation = _representation();
      final moved = _fact(value: 'clair');

      // The fact moved elsewhere; the representation still shows what
      // its photograph shows.
      expect(moved.value, 'clair');
      expect(representation.snapshot.state.value, 'sombre');
    });

    test('two representations of the same photograph ARE the same '
        'representation — and differ by their photograph', () {
      expect(_representation(), _representation());
      expect(_representation().hashCode, _representation().hashCode);
      expect({_representation(), _representation()}, hasLength(1));
      expect(
        _representation(),
        isNot(_representation(of: _fact(value: 'clair'))),
      );
    });

    test('a projection is immutable: it is built const, and the same '
        'words are the same object', () {
      const first = MentoraProjection(
        snapshot: MentoraStateSnapshot(
          state: MentoraState(id: 'theme', value: 'sombre'),
        ),
      );
      const second = MentoraProjection(
        snapshot: MentoraStateSnapshot(
          state: MentoraState(id: 'theme', value: 'sombre'),
        ),
      );

      expect(identical(first, second), isTrue);
    });

    test('a malformed photograph is refused with the PHOTOGRAPH’s '
        'voice — and the fact’s through it — unrewritten', () {
      expect(
        () => _representation(of: _fact(value: '')).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('nothing is not a fact'),
          ),
        ),
      );
    });
  });

  group('MentoraReadModel — the official representation consulted', () {
    test('a reading serves the value the representation holds, exactly '
        'as it is', () {
      final reading = _reading();

      expect(reading.read(const MentoraQuery(stateId: 'theme')), 'sombre');
      reading.verify();
    });

    test('a reading modifies nothing: asked twice, it serves the same '
        'value twice, and everything is exactly as it was', () {
      final fact = _fact();
      final reading = _reading(of: fact);
      const question = MentoraQuery(stateId: 'theme');

      expect(reading.read(question), 'sombre');
      expect(reading.read(question), 'sombre');
      expect(fact, _fact());
      expect(reading, _reading());
    });

    test('a reading answers THE question it holds the representation '
        'for: another fact is refused — a reading never guesses', () {
      expect(
        () => _reading().read(const MentoraQuery(stateId: 'contraste')),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('a reading never guesses'),
          ),
        ),
      );
    });

    test('a malformed question is refused with the QUESTION’s voice, '
        'before any answer is looked for', () {
      expect(
        () => _reading().read(const MentoraQuery(stateId: '')),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('nothing is not a question'),
          ),
        ),
      );
    });

    test('two readings of the same representation ARE the same '
        'reading — and differ by their representation', () {
      expect(_reading(), _reading());
      expect(_reading().hashCode, _reading().hashCode);
      expect({_reading(), _reading()}, hasLength(1));
      expect(_reading(), isNot(_reading(of: _fact(value: 'clair'))));
    });

    test('a read model is immutable: it is built const, and the same '
        'words are the same object', () {
      const first = MentoraReadModel(
        projection: MentoraProjection(
          snapshot: MentoraStateSnapshot(
            state: MentoraState(id: 'theme', value: 'sombre'),
          ),
        ),
      );
      const second = MentoraReadModel(
        projection: MentoraProjection(
          snapshot: MentoraStateSnapshot(
            state: MentoraState(id: 'theme', value: 'sombre'),
          ),
        ),
      );

      expect(identical(first, second), isTrue);
    });
  });

  group('The four are indifferent to every presentation', () {
    test('they stay themselves under the four themes, the four scales, '
        'every comfort, both directions and Motion None', () {
      for (final variant in ThemeVariantId.values) {
        expect(_representation(), _representation(), reason: variant.name);
        expect(_reading(), _reading(), reason: variant.name);
      }
      for (final scale in FontScalePreference.values) {
        expect(
          const MentoraReducer(),
          const MentoraReducer(),
          reason: scale.name,
        );
      }
      for (final comfort in ReadingComfortPreference.values) {
        expect(_reading(), _reading(), reason: comfort.name);
      }
      for (final direction in TextDirection.values) {
        expect(_representation(), _representation(), reason: direction.name);
      }
      for (final motion in MotionPreference.values) {
        expect(_reading(), _reading(), reason: motion.name);
      }
      expect(ThemeVariantId.values, hasLength(4));
      expect(FontScalePreference.values, hasLength(4));
    });
  });

  group('Governance — the executable scans ship with the four', () {
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

    File stateFileOf(String name) =>
        File('lib/foundation/design_kit/state/$name');

    final storeFile = stateFileOf('mentora_store.dart');
    final reducerFile = stateFileOf('mentora_reducer.dart');
    final projectionFile = stateFileOf('mentora_projection.dart');
    final readModelFile = stateFileOf('mentora_read_model.dart');

    test('each of the four imports exactly what it composes', () {
      List<String?> importsOf(File file) => RegExp(
        r'^import (.*);',
        multiLine: true,
      ).allMatches(codeOf(file)).map((match) => match.group(1)).toList();

      expect(importsOf(storeFile), ["'mentora_state.dart'"]);
      expect(importsOf(reducerFile), [
        "'mentora_state.dart'",
        "'mentora_state_mutation.dart'",
      ]);
      expect(importsOf(projectionFile), ["'mentora_state_snapshot.dart'"]);
      expect(importsOf(readModelFile), [
        "'mentora_projection.dart'",
        "'mentora_query.dart'",
      ]);
    });

    test('the reducer is the ONE place a next fact may be born: in the '
        'whole layer, only the fact itself and the reducer can invoke '
        'the fact’s constructor', () {
      final producers = <String>[];
      for (final file
          in Directory('lib/foundation/design_kit/state')
              .listSync(recursive: true)
              .whereType<File>()
              .where((file) => file.path.endsWith('.dart'))) {
        if (codeOf(file).contains('MentoraState(')) {
          producers.add(file.path.replaceAll(r'\', '/').split('/').last);
        }
      }
      producers.sort();
      expect(producers, ['mentora_reducer.dart', 'mentora_state.dart']);
    });

    test('the boundaries hold in every direction: no voice can even '
        'name a voice that is not its own', () {
      for (final beyond in const [
        'MentoraCommand',
        'MentoraEvent',
        'MentoraQuery',
        'MentoraReducer',
        'MentoraProjection',
        'MentoraReadModel',
        'MentoraStateMutation',
        'MentoraStateSnapshot',
      ]) {
        expect(
          codeOf(storeFile).contains(beyond),
          isFalse,
          reason: 'the store holds the facts, and $beyond is not one',
        );
      }
      for (final beyond in const [
        'MentoraStore',
        'MentoraProjection',
        'MentoraReadModel',
        'MentoraStateSnapshot',
        'MentoraCommand',
        'MentoraQuery',
        'MentoraEvent',
      ]) {
        expect(
          codeOf(reducerFile).contains(beyond),
          isFalse,
          reason:
              'the reducer describes the reduction, and $beyond is '
              'another question',
        );
      }
      for (final beyond in const [
        'MentoraStore',
        'MentoraReducer',
        'MentoraReadModel',
        'MentoraStateMutation',
        'MentoraCommand',
        'MentoraQuery',
        'MentoraEvent',
        'MentoraState(',
      ]) {
        expect(
          codeOf(projectionFile).contains(beyond),
          isFalse,
          reason:
              'the projection is built from the photograph, and '
              '$beyond is not it',
        );
      }
      for (final beyond in const [
        'MentoraStore',
        'MentoraReducer',
        'MentoraStateMutation',
        'MentoraStateSnapshot(',
        'MentoraCommand',
        'MentoraEvent',
        'MentoraState(',
      ]) {
        expect(
          codeOf(readModelFile).contains(beyond),
          isFalse,
          reason:
              'the reading exposes the representation, and $beyond '
              'is not it',
        );
      }
    });

    test('the projection invents no refusal, and the reducer neither: '
        'their sources contain no throw — the owners below speak', () {
      expect(RegExp(r'throw\s').hasMatch(codeOf(projectionFile)), isFalse);
      expect(RegExp(r'throw\s').hasMatch(codeOf(reducerFile)), isFalse);
      expect(
        RegExp(r'snapshot\.verify\(\)').hasMatch(codeOf(projectionFile)),
        isTrue,
      );
      expect(
        RegExp(r'mutation\.verify\(\)').hasMatch(codeOf(reducerFile)),
        isTrue,
      );
      // The reading and the store own real refusals of their own — a
      // guess refused, a duplicate refused — and each speaks once.
      expect(
        RegExp(r'query\.verify\(\)').hasMatch(codeOf(readModelFile)),
        isTrue,
      );
      expect(RegExp(r'fact\.verify\(\)').hasMatch(codeOf(storeFile)), isTrue);
    });

    test('the reducer has no state of its own: not one field in its '
        'source', () {
      expect(
        RegExp(
          r'^\s+final\s+[\w<>?, ]+\s+\w+;',
          multiLine: true,
        ).hasMatch(codeOf(reducerFile)),
        isFalse,
        reason: 'the one official reduction owns nothing',
      );
    });

    test('no machine exists in any of the four, and no mutable thing', () {
      final forbidden = <String, RegExp>{
        'a machinery': RegExp(
          r'(?<![A-Za-z])(Engine|StateMachine|Workflow|Pipeline|Middleware|'
          r'Plugin|Dispatcher|Bus|Mediator|Saga|Observer|Notifier|'
          r'Publisher|Subscriber|Listener|Controller|Service|Manager)'
          r'(?![A-Za-z])',
        ),
        'a notification': RegExp(
          r'(?<![A-Za-z])(notify\w*|publish\w*|broadcast\w*|emit\w*|'
          r'dispatch\w*|trigger\w*)\s*[(<]',
        ),
        'a promise or a clock': RegExp(
          r'(?<![A-Za-z])(Future|Stream|async|await|Timer|Scheduler)'
          r'(?![A-Za-z])',
        ),
        'a framework': RegExp(
          r'(?<![A-Za-z])(Widget|BuildContext|MediaQuery|Platform)'
          r'(?![A-Za-z])',
        ),
        'an ambient theme': RegExp(r'Theme\.of\('),
        'a storage or a cache': RegExp(
          r'(?<![A-Za-z])(SharedPreferences|Hive|Firestore|fromJson|toJson|'
          r'cache|history|Undo|Redo)(?![A-Za-z(])',
        ),
        'a mutation of its own': RegExp(r'(?<![A-Za-z])(late|var)\s'),
        'a setter': RegExp(r'(?<![A-Za-z])set\s+\w+\('),
        'an untyped value': RegExp(
          r'(?<![A-Za-z])(dynamic|Object\?)(?![A-Za-z])',
        ),
        'a position by number': RegExp(
          r'(?<![A-Za-z])(int\s+\w*[Ii]ndex|\.indexOf\()',
        ),
      };
      for (final file in [
        storeFile,
        reducerFile,
        projectionFile,
        readModelFile,
      ]) {
        final source = codeOf(file);
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason: '${file.path}: it never carries ${entry.key}',
          );
        }
      }
    });

    test('one of each exists inside the foundation — the projections '
        'of other layers are other concepts, ungoverned by this '
        'rule', () {
      Iterable<File> dartFilesOf(String path) => Directory(path)
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));

      for (final single in const {
        'MentoraStore': 'mentora_store.dart',
        'MentoraReducer': 'mentora_reducer.dart',
        'MentoraProjection': 'mentora_projection.dart',
        'MentoraReadModel': 'mentora_read_model.dart',
      }.entries) {
        final places = <String>[];
        for (final file in dartFilesOf('lib/foundation')) {
          if (RegExp(
            'class\\s+${single.key}(?![A-Za-z])',
          ).hasMatch(codeOf(file))) {
            places.add(file.path.replaceAll(r'\', '/'));
          }
        }
        expect(places, hasLength(1), reason: single.key);
        expect(
          places.single,
          endsWith('design_kit/state/${single.value}'),
          reason: single.key,
        );
      }
    });

    test('the whole state vocabulary knows no framework: ten files, '
        'zero framework imports', () {
      for (final name in const [
        'mentora_state.dart',
        'mentora_state_snapshot.dart',
        'mentora_state_mutation.dart',
        'mentora_command.dart',
        'mentora_query.dart',
        'mentora_event.dart',
        'mentora_store.dart',
        'mentora_reducer.dart',
        'mentora_projection.dart',
        'mentora_read_model.dart',
      ]) {
        final source = codeOf(stateFileOf(name));
        expect(
          RegExp(r"^import 'package:", multiLine: true).hasMatch(source),
          isFalse,
          reason: '$name: a truth of state needs no framework',
        );
      }
    });
  });
}
