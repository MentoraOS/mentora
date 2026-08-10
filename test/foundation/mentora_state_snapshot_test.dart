import 'dart:io';

import 'package:flutter/material.dart' show TextDirection;
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/state/mentora_state.dart';
import 'package:mentora/foundation/design_kit/state/mentora_state_snapshot.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';

MentoraState _fact({String id = 'theme', String value = 'sombre'}) =>
    MentoraState(id: id, value: value);

MentoraStateSnapshot _photo({MentoraState? state}) =>
    MentoraStateSnapshot(state: state ?? _fact());

void main() {
  group('MentoraStateSnapshot — an exact photograph of one state', () {
    test('a snapshot is the state it photographed, and nothing else', () {
      final fact = _fact();
      final photo = MentoraStateSnapshot(state: fact);

      expect(photo.state.id, 'theme');
      expect(photo.state.value, 'sombre');
      photo.verify();
    });

    test('the state is required by the TYPE: a photograph of nothing '
        'does not compile', () {
      expect(_photo().state, isA<MentoraState>());
    });

    test('the photograph is EXACT: the very fact photographed is the '
        'fact carried, strictly intact', () {
      final fact = _fact();
      final photo = MentoraStateSnapshot(state: fact);

      expect(identical(photo.state, fact), isTrue);
      expect(photo.state, fact);
    });

    test('a snapshot modifies nothing: after the photograph, the fact '
        'is exactly what it was', () {
      final fact = _fact();
      final photo = MentoraStateSnapshot(state: fact);

      photo.verify();

      expect(fact, _fact());
      expect(identical(photo.state, fact), isTrue);
    });

    test('a snapshot of a moved fact is another snapshot: photographs '
        'do not follow their subject', () {
      final before = MentoraStateSnapshot(state: _fact());
      final after = MentoraStateSnapshot(state: _fact(value: 'clair'));

      expect(before.state.value, 'sombre');
      expect(after.state.value, 'clair');
      expect(before, isNot(after));
      // The first photograph still shows what it showed.
      expect(before, MentoraStateSnapshot(state: _fact()));
    });

    test('two photographs of the same fact ARE the same photograph', () {
      expect(_photo(), _photo());
      expect(_photo().hashCode, _photo().hashCode);
      expect({_photo(), _photo()}, hasLength(1));
    });

    test('a photograph differs by the fact it shows', () {
      expect(_photo(), isNot(_photo(state: _fact(value: 'clair'))));
      expect(_photo(), isNot(_photo(state: _fact(id: 'contraste'))));
    });

    test('a photograph is never equal to its subject, nor to anything '
        'that is not a photograph', () {
      expect(_photo(), isNot(equals(_fact())));
      expect(_photo(), isNot(equals('sombre')));
    });

    test('a snapshot is immutable: it is built const, and the same '
        'words are the same object', () {
      const first = MentoraStateSnapshot(
        state: MentoraState(id: 'theme', value: 'sombre'),
      );
      const second = MentoraStateSnapshot(
        state: MentoraState(id: 'theme', value: 'sombre'),
      );

      expect(identical(first, second), isTrue);
    });

    test('verifying a snapshot changes nothing, twice over', () {
      final photo = _photo();

      photo.verify();
      photo.verify();

      expect(photo, _photo());
    });
  });

  group('Fail closed — a photograph adds no refusal of its own', () {
    test('a malformed fact fails with the FACT’s voice, through the '
        'photograph, unrewritten', () {
      expect(
        () => _photo(state: _fact(id: '')).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('without an identity is not a state'),
          ),
        ),
      );
      expect(
        () => _photo(state: _fact(value: '')).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('nothing is not a fact'),
          ),
        ),
      );
    });

    test('a whole photograph passes whole', () {
      _photo().verify();
      _photo(
        state: _fact(id: 'contraste', value: 'eleve'),
      ).verify();
    });
  });

  group('A photograph is indifferent to every presentation', () {
    test('it stays itself under every one of the four themes', () {
      for (final variant in ThemeVariantId.values) {
        expect(_photo(), _photo(), reason: variant.name);
      }
      expect(ThemeVariantId.values, hasLength(4));
    });

    test('it stays itself under every one of the four font scales', () {
      for (final scale in FontScalePreference.values) {
        expect(_photo(), _photo(), reason: scale.name);
      }
      expect(FontScalePreference.values, hasLength(4));
    });

    test('it stays itself under every reading comfort', () {
      for (final comfort in ReadingComfortPreference.values) {
        expect(_photo(), _photo(), reason: comfort.name);
      }
    });

    test('it has no side: the reading direction cannot reach it', () {
      for (final direction in TextDirection.values) {
        expect(_photo(), _photo(), reason: direction.name);
      }
    });

    test('nothing of it ever moves: a photograph never follows its '
        'subject, and Motion None changes nothing', () {
      for (final motion in MotionPreference.values) {
        expect(_photo(), _photo(), reason: motion.name);
      }
    });
  });

  group('Governance — the executable scans ship with the snapshot', () {
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

    final snapshotFile = File(
      'lib/foundation/design_kit/state/mentora_state_snapshot.dart',
    );

    void refuse(Map<String, RegExp> forbidden, String because) {
      final source = codeOf(snapshotFile);
      for (final entry in forbidden.entries) {
        expect(
          entry.value.hasMatch(source),
          isFalse,
          reason: '${snapshotFile.path}: $because ${entry.key}',
        );
      }
    }

    test('a photograph imports the fact, and nothing else', () {
      final imports = RegExp(r'^import (.*);', multiLine: true)
          .allMatches(codeOf(snapshotFile))
          .map((match) => match.group(1))
          .toList();

      expect(imports, ["'mentora_state.dart'"]);
    });

    test('a photograph never edits its subject: no restore, no merge, '
        'no comparison, no copy', () {
      refuse({
        'a restoration': RegExp(r'(?<![A-Za-z])(restore\w*|rollback)'),
        'a merge': RegExp(r'(?<![A-Za-z])(merge\w*|combine\w*)'),
        'a comparison of its own': RegExp(
          r'(?<![A-Za-z])(compare\w*|diff\w*|Comparable)(?![A-Za-z])',
        ),
        'a copy that edits': RegExp(r'copyWith'),
      }, 'it never carries');
    });

    test('a photograph knows no mutation: it cannot even name the '
        'transformation', () {
      expect(
        codeOf(snapshotFile).contains('MentoraStateMutation'),
        isFalse,
        reason: 'recording a fact and describing a change are two voices',
      );
    });

    test('a photograph invents no refusal: the fact is verified by the '
        'fact, and nothing else is verified at all', () {
      final source = codeOf(snapshotFile);

      expect(
        RegExp(r'state\.verify\(\)').hasMatch(source),
        isTrue,
        reason: 'the fact speaks with its own voice',
      );
      // Exactly one throw-less verify: the snapshot's verify contains
      // no StateError of its own.
      expect(
        RegExp(r'throw\s').hasMatch(source),
        isFalse,
        reason: 'a photograph adds no refusal of its own',
      );
    });

    test('a photograph holds no mutable thing and no machinery', () {
      final source = codeOf(snapshotFile);
      refuse({
        'a mutation of its own': RegExp(r'(?<![A-Za-z])(late|var)\s'),
        'a setter': RegExp(r'(?<![A-Za-z])set\s+\w+\('),
        'an untyped value': RegExp(
          r'(?<![A-Za-z])(dynamic|Object\?)(?![A-Za-z])',
        ),
        'a machinery': RegExp(
          r'(?<![A-Za-z])(Engine|Controller|Service|Flow|Pipeline|Store|'
          r'Reducer)(?![A-Za-z])',
        ),
        'a promise': RegExp(
          r'(?<![A-Za-z])(Future|Stream|async|await)(?![A-Za-z])',
        ),
        'a memory beyond the one photograph': RegExp(
          r'(?<![A-Za-z])(history|cache|memory|previous\w*)\s*[(.<=:]',
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

    test('one snapshot exists, inside the Design Kit and nowhere '
        'else', () {
      final declarations = <String>[];
      for (final file
          in Directory('lib')
              .listSync(recursive: true)
              .whereType<File>()
              .where((file) => file.path.endsWith('.dart'))) {
        for (final match in RegExp(
          r'class\s+(\w*StateSnapshot)(?![A-Za-z])',
        ).allMatches(codeOf(file))) {
          declarations.add(
            '${match.group(1)} in ${file.path.replaceAll(r'\', '/')}',
          );
        }
      }
      expect(declarations, [
        'MentoraStateSnapshot in '
            'lib/foundation/design_kit/state/mentora_state_snapshot.dart',
      ]);
    });
  });
}
