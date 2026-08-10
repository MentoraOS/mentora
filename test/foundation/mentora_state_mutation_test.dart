import 'dart:io';

import 'package:flutter/material.dart' show TextDirection;
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
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

void main() {
  group('MentoraStateMutation — the transformation asked', () {
    test('a mutation is the fact it starts from and the value asked '
        'for, and nothing else', () {
      final change = _change();

      expect(change.from.id, 'theme');
      expect(change.from.value, 'sombre');
      expect(change.requestedValue, 'clair');
      change.verify();
    });

    test('both parts are required by the TYPE: a transformation of '
        'nothing, or towards nothing, does not compile as absence', () {
      expect(_change().from, isA<MentoraState>());
      expect(_change().requestedValue, isA<String>());
    });

    test('the fact travels whole and strictly intact: the very fact it '
        'starts from is the fact carried', () {
      final fact = _fact();
      final change = MentoraStateMutation(from: fact, requestedValue: 'clair');

      expect(identical(change.from, fact), isTrue);
    });

    test('a mutation does not execute: after the description, the fact '
        'still holds what it held', () {
      final fact = _fact();
      final change = MentoraStateMutation(from: fact, requestedValue: 'clair');

      change.verify();

      // The change was described, not performed: the official fact is
      // exactly what it was, and no next fact exists anywhere.
      expect(fact.value, 'sombre');
      expect(fact, _fact());
      expect(change.requestedValue, 'clair');
    });

    test('a mutation does not produce the next state: what it exposes '
        'is the demand, never the outcome', () {
      final change = _change();

      // The whole surface of a mutation is its two parts. The scan
      // below proves its source cannot even BUILD a state.
      expect(change.from, isA<MentoraState>());
      expect(change.requestedValue, isA<String>());
    });

    test('two demands with the same words ARE the same demand', () {
      expect(_change(), _change());
      expect(_change().hashCode, _change().hashCode);
      expect({_change(), _change()}, hasLength(1));
    });

    test('a demand differs by the fact it starts from, and by the '
        'value asked for', () {
      expect(_change(), isNot(_change(from: _fact(id: 'contraste'))));
      expect(_change(), isNot(_change(requestedValue: 'eleve')));
    });

    test('a demand is never equal to something that is not a demand', () {
      expect(_change(), isNot(equals(_fact())));
      expect(_change(), isNot(equals('clair')));
    });

    test('a mutation is immutable: it is built const, and the same '
        'words are the same object', () {
      const first = MentoraStateMutation(
        from: MentoraState(id: 'theme', value: 'sombre'),
        requestedValue: 'clair',
      );
      const second = MentoraStateMutation(
        from: MentoraState(id: 'theme', value: 'sombre'),
        requestedValue: 'clair',
      );

      expect(identical(first, second), isTrue);
    });

    test('verifying a mutation changes nothing, twice over', () {
      final change = _change();

      change.verify();
      change.verify();

      expect(change, _change());
    });
  });

  group('Fail closed — a description without a contract refuses', () {
    void refuses(MentoraStateMutation change, String fragment) {
      expect(
        () => change.verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains(fragment),
          ),
        ),
      );
    }

    test('a malformed fact is refused — with the FACT’s voice, '
        'unrewritten', () {
      refuses(
        _change(from: _fact(id: '')),
        'without an identity is not a state',
      );
      refuses(_change(from: _fact(value: '')), 'nothing is not a fact');
    });

    test('a transformation towards nothing is refused', () {
      refuses(_change(requestedValue: ''), 'nothing is not a transformation');
    });

    test('a transformation that demands nothing is refused: asking a '
        'fact to become what it already is describes no change', () {
      refuses(
        _change(requestedValue: 'sombre'),
        'A transformation that demands nothing is not a transformation',
      );
    });

    test('a whole description passes whole', () {
      _change().verify();
      _change(
        from: _fact(id: 'contraste', value: 'normal'),
        requestedValue: 'eleve',
      ).verify();
    });
  });

  group('A description is indifferent to every presentation', () {
    test('it stays itself under every one of the four themes', () {
      for (final variant in ThemeVariantId.values) {
        expect(_change(), _change(), reason: variant.name);
      }
      expect(ThemeVariantId.values, hasLength(4));
    });

    test('it stays itself under every one of the four font scales', () {
      for (final scale in FontScalePreference.values) {
        expect(_change(), _change(), reason: scale.name);
      }
      expect(FontScalePreference.values, hasLength(4));
    });

    test('it stays itself under every reading comfort', () {
      for (final comfort in ReadingComfortPreference.values) {
        expect(_change(), _change(), reason: comfort.name);
      }
    });

    test('it has no side: the reading direction cannot reach it', () {
      for (final direction in TextDirection.values) {
        expect(_change(), _change(), reason: direction.name);
      }
    });

    test('nothing of it ever moves: a description is not the movement, '
        'and Motion None changes nothing', () {
      for (final motion in MotionPreference.values) {
        expect(_change(), _change(), reason: motion.name);
      }
    });
  });

  group('Governance — the executable scans ship with the mutation', () {
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

    final mutationFile = File(
      'lib/foundation/design_kit/state/mentora_state_mutation.dart',
    );

    void refuse(Map<String, RegExp> forbidden, String because) {
      final source = codeOf(mutationFile);
      for (final entry in forbidden.entries) {
        expect(
          entry.value.hasMatch(source),
          isFalse,
          reason: '${mutationFile.path}: $because ${entry.key}',
        );
      }
    }

    test('a description imports the fact, and nothing else', () {
      final imports = RegExp(r'^import (.*);', multiLine: true)
          .allMatches(codeOf(mutationFile))
          .map((match) => match.group(1))
          .toList();

      expect(imports, ["'mentora_state.dart'"]);
    });

    test('a mutation never builds the next state: its source cannot '
        'even invoke the fact’s constructor', () {
      expect(
        codeOf(mutationFile).contains('MentoraState('),
        isFalse,
        reason:
            'describing a change and producing the outcome are two '
            'voices — the next fact is announced elsewhere, whole',
      );
    });

    test('a mutation never executes: no apply, no execute, no commit, '
        'no dispatch', () {
      refuse({
        'an execution': RegExp(
          r'(?<![A-Za-z])(apply|execute|perform|commit|dispatch|run)'
          r'\s*[(<]',
        ),
        'a production of the outcome': RegExp(
          r'(?<![A-Za-z])(next|result|outcome|produced?)\s*[(.<=:]',
        ),
      }, 'it never carries');
    });

    test('a mutation knows no snapshot: describing a change and '
        'recording a fact are two voices', () {
      expect(codeOf(mutationFile).contains('MentoraStateSnapshot'), isFalse);
    });

    test('a mutation holds no mutable thing and no machinery', () {
      final source = codeOf(mutationFile);
      refuse({
        'a mutation of its own': RegExp(r'(?<![A-Za-z])(late|var)\s'),
        'a setter': RegExp(r'(?<![A-Za-z])set\s+\w+\('),
        'an untyped value': RegExp(
          r'(?<![A-Za-z])(dynamic|Object\?)(?![A-Za-z])',
        ),
        'a machinery': RegExp(
          r'(?<![A-Za-z])(Engine|Controller|Service|Flow|Pipeline|Store|'
          r'Reducer|Dispatcher)(?![A-Za-z])',
        ),
        'a promise': RegExp(
          r'(?<![A-Za-z])(Future|Stream|async|await)(?![A-Za-z])',
        ),
        'a history': RegExp(
          r'(?<![A-Za-z])(history|previous\w*|Undo|Redo)\s*[(.<=:]',
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

    test('the fact keeps its own voice: the mutation verifies through '
        'it, and adds only what it owns', () {
      final source = codeOf(mutationFile);

      expect(
        RegExp(r'from\.verify\(\)').hasMatch(source),
        isTrue,
        reason: 'the fact is verified by the fact',
      );
    });

    test('one mutation exists, inside the Design Kit and nowhere '
        'else', () {
      final declarations = <String>[];
      for (final file
          in Directory('lib')
              .listSync(recursive: true)
              .whereType<File>()
              .where((file) => file.path.endsWith('.dart'))) {
        for (final match in RegExp(
          r'class\s+(\w*StateMutation)(?![A-Za-z])',
        ).allMatches(codeOf(file))) {
          declarations.add(
            '${match.group(1)} in ${file.path.replaceAll(r'\', '/')}',
          );
        }
      }
      expect(declarations, [
        'MentoraStateMutation in '
            'lib/foundation/design_kit/state/mentora_state_mutation.dart',
      ]);
    });
  });
}
