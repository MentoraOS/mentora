import 'dart:io';

import 'package:flutter/material.dart' show TextDirection;
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/state/mentora_state.dart';
import 'package:mentora/foundation/design_kit/state/mentora_state_snapshot.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';

MentoraState _fact({String id = 'theme', String value = 'sombre'}) =>
    MentoraState(id: id, value: value);

void main() {
  group('MentoraState — what is official, currently', () {
    test('a state is one official fact: its identity, and the value it '
        'holds right now', () {
      const fact = MentoraState(id: 'theme', value: 'sombre');

      expect(fact.id, 'theme');
      expect(fact.value, 'sombre');
      fact.verify();
    });

    test('both words are required by the TYPE: a fact about nothing, '
        'or holding nothing, does not compile as absence', () {
      expect(_fact().id, isA<String>());
      expect(_fact().value, isA<String>());
    });

    test('two states with the same words ARE the same state', () {
      expect(_fact(), _fact());
      expect(_fact().hashCode, _fact().hashCode);
      expect({_fact(), _fact()}, hasLength(1));
    });

    test('a state differs by either of its words', () {
      expect(_fact(), isNot(_fact(id: 'contraste')));
      expect(_fact(), isNot(_fact(value: 'clair')));
    });

    test('a state is never equal to something that is not a state', () {
      expect(_fact(), isNot(equals('sombre')));
      expect(_fact(), isNot(equals(MentoraStateSnapshot(state: _fact()))));
    });

    test('a state is immutable: it is built const, and the same words '
        'are the same object', () {
      const first = MentoraState(id: 'theme', value: 'sombre');
      const second = MentoraState(id: 'theme', value: 'sombre');

      expect(identical(first, second), isTrue);
    });

    test('a fact that moved is a NEW fact: the old one never changes', () {
      final before = _fact();
      final after = _fact(value: 'clair');

      expect(before.value, 'sombre');
      expect(after.value, 'clair');
      expect(before, isNot(after));
      expect(before, _fact());
    });

    test('a state without a contract refuses — fail closed', () {
      expect(
        () => _fact(id: '').verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('without an identity is not a state'),
          ),
        ),
      );
      expect(
        () => _fact(value: '').verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('nothing is not a fact'),
          ),
        ),
      );
      _fact().verify();
    });

    test('verifying a state changes nothing, twice over', () {
      final fact = _fact();

      fact.verify();
      fact.verify();

      expect(fact, _fact());
    });
  });

  group('A fact is indifferent to every presentation', () {
    test('it stays itself under every one of the four themes', () {
      for (final variant in ThemeVariantId.values) {
        expect(_fact(), _fact(), reason: variant.name);
      }
      expect(ThemeVariantId.values, hasLength(4));
    });

    test('it stays itself under every one of the four font scales', () {
      for (final scale in FontScalePreference.values) {
        expect(_fact(), _fact(), reason: scale.name);
      }
      expect(FontScalePreference.values, hasLength(4));
    });

    test('it stays itself under every reading comfort', () {
      for (final comfort in ReadingComfortPreference.values) {
        expect(_fact(), _fact(), reason: comfort.name);
      }
    });

    test('it has no side: the reading direction cannot reach it', () {
      for (final direction in TextDirection.values) {
        expect(_fact(), _fact(), reason: direction.name);
      }
    });

    test('nothing of it ever moves: Motion None changes nothing of a '
        'fact', () {
      for (final motion in MotionPreference.values) {
        expect(_fact(), _fact(), reason: motion.name);
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
      'lib/foundation/design_kit/state/mentora_state.dart',
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

    test('a fact imports NOTHING: it needs nothing to be true', () {
      expect(
        RegExp(r'^import ', multiLine: true).hasMatch(codeOf(stateFile)),
        isFalse,
      );
    });

    test('a state knows no mutation, no history, no store, no reducer '
        'and no machine — it cannot even name them', () {
      final source = codeOf(stateFile);

      for (final beyond in const [
        'MentoraStateMutation',
        'MentoraStateSnapshot',
      ]) {
        expect(
          source.contains(beyond),
          isFalse,
          reason: 'the fact answers one question, and $beyond is another',
        );
      }
      refuse({
        'a history or a memory': RegExp(
          r'(?<![A-Za-z])(History|history|previous\w*|visited|memory|'
          r'cache|Undo|Redo)\s*[(.<=:]',
        ),
        'a store or a reducer': RegExp(
          r'(?<![A-Za-z])(Store|Reducer|Dispatcher|Middleware|Bloc|Cubit|'
          r'Riverpod|Redux)(?![A-Za-z])',
        ),
        'an event': RegExp(r'(?<![A-Za-z])(Event|event)\s*[(.<=:]'),
      }, 'it never carries');
    });

    test('a state knows no framework, no platform and no '
        'presentation', () {
      refuse({
        'a widget or a context': RegExp(
          r'(?<![A-Za-z])(Widget|BuildContext)(?![A-Za-z])',
        ),
        'a machinery': RegExp(
          r'(?<![A-Za-z])(Engine|Controller|Service|Flow|Pipeline|'
          r'Orchestrator|Workflow)(?![A-Za-z])',
        ),
        'a notification of change': RegExp(
          r'(?<![A-Za-z])(setState|notifyListeners|addListener|'
          r'ChangeNotifier|ValueNotifier)(?![A-Za-z])',
        ),
        'a promise': RegExp(
          r'(?<![A-Za-z])(Future|Stream|async|await)(?![A-Za-z])',
        ),
        'a platform': RegExp(
          r'(?<![A-Za-z])(Platform|TargetPlatform|kIsWeb|MediaQuery)'
          r'(?![A-Za-z])',
        ),
        'an ambient theme': RegExp(r'Theme\.of\('),
        'a storage or a serialization': RegExp(
          r'(?<![A-Za-z])(SharedPreferences|Hive|Firestore|fromJson|'
          r'toJson|persist\w*|storage)(?![A-Za-z(])',
        ),
      }, 'it never carries');
    });

    test('a state holds no mutable thing: every field is final, no '
        'setter, no var, no late, no untyped value', () {
      final source = codeOf(stateFile);
      refuse({
        'a mutation of its own': RegExp(r'(?<![A-Za-z])(late|var)\s'),
        'a setter': RegExp(r'(?<![A-Za-z])set\s+\w+\('),
        'an untyped value': RegExp(
          r'(?<![A-Za-z])(dynamic|Object\?)(?![A-Za-z])',
        ),
        'a position by number': RegExp(
          r'(?<![A-Za-z])(int\s+\w*[Ii]ndex|\.indexOf\()',
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

    test('a state knows no business: a fact of the foundation names no '
        'domain of the company', () {
      refuse({
        'a business domain': RegExp(
          r'(?<![A-Za-z])(User|Wallet|Product|Expert|Invoice|Business|'
          r'Account|Profile|Model|Repository|Entity)(?![a-z])',
        ),
        'a permission': RegExp(
          r'(?<![A-Za-z])(permission|granted|denied|role|admin)\s*[:.(=]',
        ),
        'a network': RegExp(
          r'(?<![A-Za-z])(http|HttpClient|WebSocket)(?![A-Za-z])',
        ),
      }, 'it never carries');
    });

    test('one official state exists, inside the Design Kit and nowhere '
        'else — and the states of other layers are other concepts', () {
      final declarations = <String>[];
      for (final file in dartFilesOf('lib')) {
        for (final match in RegExp(
          r'class\s+(MentoraState)(?![A-Za-z])',
        ).allMatches(codeOf(file))) {
          declarations.add(
            '${match.group(1)} in ${file.path.replaceAll(r'\', '/')}',
          );
        }
      }
      expect(declarations, [
        'MentoraState in lib/foundation/design_kit/state/mentora_state.dart',
      ]);
    });

    test('the whole state vocabulary knows no framework: three files, '
        'zero framework imports — and the fact imports nothing at all', () {
      for (final name in const [
        'mentora_state.dart',
        'mentora_state_snapshot.dart',
        'mentora_state_mutation.dart',
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
