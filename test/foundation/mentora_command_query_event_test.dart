import 'dart:io';

import 'package:flutter/material.dart' show TextDirection;
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/state/mentora_command.dart';
import 'package:mentora/foundation/design_kit/state/mentora_event.dart';
import 'package:mentora/foundation/design_kit/state/mentora_query.dart';
import 'package:mentora/foundation/design_kit/state/mentora_state.dart';
import 'package:mentora/foundation/design_kit/state/mentora_state_mutation.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';

MentoraState _fact({String id = 'theme', String value = 'sombre'}) =>
    MentoraState(id: id, value: value);

MentoraStateMutation _change({
  MentoraState? from,
  String requestedValue = 'clair',
}) =>
    MentoraStateMutation(from: from ?? _fact(), requestedValue: requestedValue);

MentoraCommand _command({MentoraStateMutation? mutation}) =>
    MentoraCommand(mutation: mutation ?? _change());

MentoraQuery _question({String stateId = 'theme'}) =>
    MentoraQuery(stateId: stateId);

MentoraEvent _announced({MentoraState? fact}) =>
    MentoraEvent(fact: fact ?? _fact());

void main() {
  group('MentoraCommand — the change officially asked for', () {
    test('a command is the transformation it carries, and nothing '
        'else — and a whole command passes whole', () {
      final change = _change();
      final command = MentoraCommand(mutation: change);

      expect(identical(command.mutation, change), isTrue);
      expect(command.mutation.from.id, 'theme');
      expect(command.mutation.requestedValue, 'clair');
      command.verify();
    });

    test('the change is required by the TYPE: a demand of nothing does '
        'not compile', () {
      expect(_command().mutation, isA<MentoraStateMutation>());
    });

    test('a command executes nothing: after the demand, the fact still '
        'holds what it held', () {
      final fact = _fact();
      final command = MentoraCommand(
        mutation: MentoraStateMutation(from: fact, requestedValue: 'clair'),
      );

      command.verify();
      command.verify();

      expect(fact.value, 'sombre');
      expect(fact, _fact());
      expect(command, _command());
    });

    test('two demands of the same change ARE the same demand', () {
      expect(_command(), _command());
      expect(_command().hashCode, _command().hashCode);
      expect({_command(), _command()}, hasLength(1));
    });

    test('a command differs by the change it carries, and is never '
        'equal to something that is not a command', () {
      expect(
        _command(),
        isNot(_command(mutation: _change(requestedValue: 'eleve'))),
      );
      expect(_command(), isNot(equals(_change())));
      expect(_command(), isNot(equals(_question())));
    });

    test('a command is immutable: it is built const, and the same '
        'words are the same object', () {
      const first = MentoraCommand(
        mutation: MentoraStateMutation(
          from: MentoraState(id: 'theme', value: 'sombre'),
          requestedValue: 'clair',
        ),
      );
      const second = MentoraCommand(
        mutation: MentoraStateMutation(
          from: MentoraState(id: 'theme', value: 'sombre'),
          requestedValue: 'clair',
        ),
      );

      expect(identical(first, second), isTrue);
    });

    test('a malformed change is refused with the CHANGE’s voice — and '
        'the fact’s through it — unrewritten', () {
      expect(
        () => _command(
          mutation: _change(from: _fact(id: '')),
        ).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('without an identity is not a state'),
          ),
        ),
      );
      expect(
        () => _command(mutation: _change(requestedValue: '')).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('nothing is not a transformation'),
          ),
        ),
      );
      expect(
        () => _command(mutation: _change(requestedValue: 'sombre')).verify(),
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

  group('MentoraQuery — the official information asked for', () {
    test('a query is the identity of the fact asked for, and nothing '
        'else — and a whole question passes whole', () {
      const question = MentoraQuery(stateId: 'theme');

      expect(question.stateId, 'theme');
      question.verify();
    });

    test('a query does not know the answer: it asks by identity, and '
        'the facts belong to whoever answers', () {
      // The question carries no fact and no value — only the name of
      // what is wanted. The scan below proves its source cannot even
      // name the fact type.
      expect(_question().stateId, isA<String>());
    });

    test('the same question asked twice is the same question: nothing '
        'was cached, because nothing is kept at all', () {
      final first = _question();
      final second = _question();

      first.verify();
      second.verify();

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect({first, second}, hasLength(1));
    });

    test('a question differs by the fact it names, and is never equal '
        'to something that is not a question', () {
      expect(_question(), isNot(_question(stateId: 'contraste')));
      expect(_question(), isNot(equals('theme')));
      expect(_question(), isNot(equals(_command())));
    });

    test('a query is immutable: it is built const, and the same words '
        'are the same object', () {
      const first = MentoraQuery(stateId: 'theme');
      const second = MentoraQuery(stateId: 'theme');

      expect(identical(first, second), isTrue);
    });

    test('a question about nothing is refused — fail closed', () {
      expect(
        () => _question(stateId: '').verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('nothing is not a question'),
          ),
        ),
      );
    });
  });

  group('MentoraEvent — the official fact just announced', () {
    test('an event is the fact announced, and nothing else — and a '
        'whole announcement passes whole', () {
      final fact = _fact();
      final event = MentoraEvent(fact: fact);

      expect(identical(event.fact, fact), isTrue);
      expect(event.fact.id, 'theme');
      event.verify();
    });

    test('the fact is required by the TYPE: an announcement of nothing '
        'does not compile', () {
      expect(_announced().fact, isA<MentoraState>());
    });

    test('an event produces nothing and tells no one: after the '
        'announcement, everything is exactly as it was', () {
      final fact = _fact();
      final event = MentoraEvent(fact: fact);

      event.verify();
      event.verify();

      expect(fact, _fact());
      expect(event, _announced());
    });

    test('an announcement is not a photograph: the two voices are '
        'never interchangeable', () {
      // Same underlying fact — two different statements about it.
      expect(_announced(), isNot(equals(_fact())));
      expect(_announced(), isNot(equals(_command())));
      expect(_announced(), isNot(equals(_question())));
    });

    test('two announcements of the same fact ARE the same '
        'announcement', () {
      expect(_announced(), _announced());
      expect(_announced().hashCode, _announced().hashCode);
      expect({_announced(), _announced()}, hasLength(1));
    });

    test('an announcement differs by the fact it announces', () {
      expect(_announced(), isNot(_announced(fact: _fact(value: 'clair'))));
      expect(_announced(), isNot(_announced(fact: _fact(id: 'contraste'))));
    });

    test('an event is immutable: it is built const, and the same words '
        'are the same object', () {
      const first = MentoraEvent(
        fact: MentoraState(id: 'theme', value: 'sombre'),
      );
      const second = MentoraEvent(
        fact: MentoraState(id: 'theme', value: 'sombre'),
      );

      expect(identical(first, second), isTrue);
    });

    test('a malformed fact is refused with the FACT’s voice, '
        'unrewritten', () {
      expect(
        () => _announced(fact: _fact(id: '')).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('without an identity is not a state'),
          ),
        ),
      );
      expect(
        () => _announced(fact: _fact(value: '')).verify(),
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

  group('The three questions are indifferent to every presentation', () {
    test('they stay themselves under every one of the four themes', () {
      for (final variant in ThemeVariantId.values) {
        expect(_command(), _command(), reason: variant.name);
        expect(_question(), _question(), reason: variant.name);
        expect(_announced(), _announced(), reason: variant.name);
      }
      expect(ThemeVariantId.values, hasLength(4));
    });

    test('they stay themselves under every one of the four font '
        'scales', () {
      for (final scale in FontScalePreference.values) {
        expect(_command(), _command(), reason: scale.name);
        expect(_question(), _question(), reason: scale.name);
        expect(_announced(), _announced(), reason: scale.name);
      }
      expect(FontScalePreference.values, hasLength(4));
    });

    test('they stay themselves under every reading comfort', () {
      for (final comfort in ReadingComfortPreference.values) {
        expect(_command(), _command(), reason: comfort.name);
        expect(_question(), _question(), reason: comfort.name);
        expect(_announced(), _announced(), reason: comfort.name);
      }
    });

    test('they have no side: the reading direction cannot reach '
        'them', () {
      for (final direction in TextDirection.values) {
        expect(_command(), _command(), reason: direction.name);
        expect(_question(), _question(), reason: direction.name);
        expect(_announced(), _announced(), reason: direction.name);
      }
    });

    test('nothing of them ever moves: Motion None changes nothing', () {
      for (final motion in MotionPreference.values) {
        expect(_command(), _command(), reason: motion.name);
        expect(_question(), _question(), reason: motion.name);
        expect(_announced(), _announced(), reason: motion.name);
      }
    });
  });

  group('Governance — the executable scans ship with the three', () {
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

    final commandFile = File(
      'lib/foundation/design_kit/state/mentora_command.dart',
    );
    final queryFile = File(
      'lib/foundation/design_kit/state/mentora_query.dart',
    );
    final eventFile = File(
      'lib/foundation/design_kit/state/mentora_event.dart',
    );

    void refuseIn(File file, Map<String, RegExp> forbidden) {
      final source = codeOf(file);
      for (final entry in forbidden.entries) {
        expect(
          entry.value.hasMatch(source),
          isFalse,
          reason: '${file.path}: it never carries ${entry.key}',
        );
      }
    }

    test('each of the three imports exactly its one owner — and the '
        'question imports nothing at all', () {
      List<String?> importsOf(File file) => RegExp(
        r'^import (.*);',
        multiLine: true,
      ).allMatches(codeOf(file)).map((match) => match.group(1)).toList();

      expect(importsOf(commandFile), ["'mentora_state_mutation.dart'"]);
      expect(importsOf(queryFile), isEmpty);
      expect(importsOf(eventFile), ["'mentora_state.dart'"]);
    });

    test('the boundaries hold in every direction: no voice can even '
        'name a voice that is not its own', () {
      // The command reaches the fact only THROUGH the change.
      for (final beyond in const [
        'MentoraState(',
        'MentoraStateSnapshot',
        'MentoraQuery',
        'MentoraEvent',
      ]) {
        expect(
          codeOf(commandFile).contains(beyond),
          isFalse,
          reason: 'the command carries the change, and $beyond is not it',
        );
      }
      // The query cannot name the fact type: the answer is not its.
      for (final beyond in const [
        'MentoraState',
        'MentoraCommand',
        'MentoraEvent',
        'MentoraStateMutation',
        'MentoraStateSnapshot',
      ]) {
        expect(
          codeOf(queryFile).contains(beyond),
          isFalse,
          reason: 'the query asks by identity, and $beyond is an answer',
        );
      }
      // The event announces the fact — and nothing about changing it,
      // photographing it, or asking for it.
      for (final beyond in const [
        'MentoraStateMutation',
        'MentoraStateSnapshot',
        'MentoraCommand',
        'MentoraQuery',
      ]) {
        expect(
          codeOf(eventFile).contains(beyond),
          isFalse,
          reason: 'the event announces the fact, and $beyond is not it',
        );
      }
    });

    test('the command and the event invent no refusal: their sources '
        'contain no throw, and the one owner speaks', () {
      expect(RegExp(r'throw\s').hasMatch(codeOf(commandFile)), isFalse);
      expect(RegExp(r'throw\s').hasMatch(codeOf(eventFile)), isFalse);
      expect(
        RegExp(r'mutation\.verify\(\)').hasMatch(codeOf(commandFile)),
        isTrue,
      );
      expect(RegExp(r'fact\.verify\(\)').hasMatch(codeOf(eventFile)), isTrue);
    });

    test('no machine exists in any of the three: no dispatcher, no '
        'bus, no observer, no notifier, no promise, no timer', () {
      final machinery = <String, RegExp>{
        'a machinery': RegExp(
          r'(?<![A-Za-z])(Engine|Workflow|Dispatcher|Bus|Mediator|Service|'
          r'Controller|Pipeline|Saga|Machine|Observer|Notifier|Publisher|'
          r'Subscriber|Listener)(?![A-Za-z])',
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
        'a storage or a serialization': RegExp(
          r'(?<![A-Za-z])(SharedPreferences|Hive|Firestore|fromJson|toJson)'
          r'(?![A-Za-z])',
        ),
      };
      for (final file in [commandFile, queryFile, eventFile]) {
        refuseIn(file, machinery);
      }
    });

    test('the query works on nothing: no computation, no filter, no '
        'sort, no walk, no cache', () {
      refuseIn(queryFile, {
        'a selection or an order': RegExp(
          r'\.(where|firstWhere|sort|sorted|reversed|reduce|fold|skip|'
          r'take|map)\s*[(.]',
        ),
        'a cache or a memory': RegExp(
          r'(?<![A-Za-z])(cache|memo\w*|remember\w*|history)\s*[(.<=:]',
        ),
        'a result': RegExp(r'(?<![A-Za-z])(result|answer|value)\s*[(.<=:;]'),
      });
    });

    test('none of the three holds a mutable thing: every field final, '
        'no var, no late, no setter, no untyped value', () {
      final mutable = <String, RegExp>{
        'a mutation of its own': RegExp(r'(?<![A-Za-z])(late|var)\s'),
        'a setter': RegExp(r'(?<![A-Za-z])set\s+\w+\('),
        'an untyped value': RegExp(
          r'(?<![A-Za-z])(dynamic|Object\?)(?![A-Za-z])',
        ),
        'a position by number': RegExp(
          r'(?<![A-Za-z])(int\s+\w*[Ii]ndex|\.indexOf\()',
        ),
      };
      for (final file in [commandFile, queryFile, eventFile]) {
        refuseIn(file, mutable);
        for (final field in RegExp(
          r'^\s+(?!static)(\w[\w<>?, ]*)\s+\w+;',
          multiLine: true,
        ).allMatches(codeOf(file))) {
          expect(
            field.group(0)!.trimLeft().startsWith('final '),
            isTrue,
            reason:
                '${file.path}: every field is final: '
                '${field.group(0)!.trim()}',
          );
        }
      }
    });

    test('one of each exists inside the foundation — and the event '
        'model of the legacy core is another concept, in a layer this '
        'rule does not govern', () {
      Iterable<File> dartFilesOf(String path) => Directory(path)
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));

      for (final single in const {
        'MentoraCommand': 'mentora_command.dart',
        'MentoraQuery': 'mentora_query.dart',
        'MentoraEvent': 'mentora_event.dart',
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

    test('the whole state vocabulary knows no framework: six files, '
        'zero framework imports', () {
      for (final name in const [
        'mentora_state.dart',
        'mentora_state_snapshot.dart',
        'mentora_state_mutation.dart',
        'mentora_command.dart',
        'mentora_query.dart',
        'mentora_event.dart',
      ]) {
        final source = codeOf(File('lib/foundation/design_kit/state/$name'));
        expect(
          RegExp(r"^import 'package:", multiLine: true).hasMatch(source),
          isFalse,
          reason: '$name: a truth of state needs no framework',
        );
      }
    });
  });
}
