import 'dart:io';

import 'package:flutter/material.dart' show TextDirection;
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/contracts/mentora_contract.dart';
import 'package:mentora/foundation/design_kit/contracts/mentora_contract_coordinator.dart';
import 'package:mentora/foundation/design_kit/contracts/mentora_contract_registry.dart';
import 'package:mentora/foundation/design_kit/contracts/mentora_contract_request.dart';
import 'package:mentora/foundation/design_kit/contracts/mentora_contract_resolution.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';

MentoraContract _contract({
  String id = 'accessibilite',
  String? name,
  String? description,
}) => MentoraContract(
  id: id,
  name: name ?? 'Contrat $id',
  description: description,
);

MentoraContractRegistry _registry({List<MentoraContract>? contracts}) =>
    MentoraContractRegistry(
      contracts: contracts ?? [_contract(), _contract(id: 'motion')],
    );

MentoraContractRequest _ask({MentoraContract? contract}) =>
    MentoraContractRequest(contract: contract ?? _contract());

MentoraContractResolution _answer({
  MentoraContract? asked,
  MentoraContract? resolved,
}) {
  final contract = asked ?? _contract();
  return MentoraContractResolution(
    request: MentoraContractRequest(contract: contract),
    resolvedContract: resolved ?? contract,
  );
}

MentoraContractCoordinator _dialogue({
  MentoraContractRegistry? registry,
  MentoraContract? asked,
  MentoraContract? resolved,
  MentoraContractRequest? request,
}) {
  final contract = asked ?? _contract();
  final demand = request ?? MentoraContractRequest(contract: contract);
  return MentoraContractCoordinator(
    registry: registry ?? _registry(),
    request: demand,
    resolution: MentoraContractResolution(
      request: demand,
      resolvedContract: resolved ?? contract,
    ),
  );
}

void main() {
  group('MentoraContract — the official contract', () {
    test('a contract is its identity, its name and what completes it — '
        'and a whole contract passes whole', () {
      const contract = MentoraContract(
        id: 'accessibilite',
        name: 'Le contrat d’accessibilité',
        description: 'Ce que chaque composant doit à chaque personne',
      );

      expect(contract.id, 'accessibilite');
      expect(contract.name, 'Le contrat d’accessibilité');
      expect(
        contract.description,
        'Ce que chaque composant doit à chaque personne',
      );
      contract.verify();
    });

    test('the completion is optional: a contract may be its name '
        'alone', () {
      expect(_contract().description, isNull);
      _contract().verify();
    });

    test('two contracts with the same words ARE the same contract — '
        'and differ by any of them', () {
      expect(_contract(), _contract());
      expect(_contract().hashCode, _contract().hashCode);
      expect({_contract(), _contract()}, hasLength(1));
      expect(_contract(), isNot(_contract(id: 'motion')));
      expect(_contract(), isNot(_contract(name: 'Un autre nom')));
      expect(_contract(), isNot(_contract(description: 'Ce qui complète')));
    });

    test('a contract is never equal to something that is not a '
        'contract', () {
      expect(_contract(), isNot(equals('accessibilite')));
      expect(_contract(), isNot(equals(_ask())));
    });

    test('a contract is immutable: it is built const, and the same '
        'words are the same object', () {
      const first = MentoraContract(id: 'motion', name: 'Le mouvement');
      const second = MentoraContract(id: 'motion', name: 'Le mouvement');

      expect(identical(first, second), isTrue);
    });

    test('a contract without a contract refuses — fail closed', () {
      expect(
        () => _contract(id: '').verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('without an identity is not a contract'),
          ),
        ),
      );
      expect(
        () => _contract(name: '').verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('binds no one'),
          ),
        ),
      );
      expect(
        () => _contract(description: '').verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('an ambiguity is refused'),
          ),
        ),
      );
    });
  });

  group('MentoraContractRegistry — the official set', () {
    test('the registry gathers the contracts once, and a whole '
        'gathering passes whole', () {
      final registry = _registry();

      expect(registry.contracts, hasLength(2));
      registry.verify();
    });

    test('a registry is declared once, like the topology: it is built '
        'const, and it is not a value that varies', () {
      const first = MentoraContractRegistry(
        contracts: [MentoraContract(id: 'motion', name: 'Le mouvement')],
      );
      const second = MentoraContractRegistry(
        contracts: [MentoraContract(id: 'motion', name: 'Le mouvement')],
      );

      expect(identical(first, second), isTrue);
    });

    test('a product without a contract is refused', () {
      expect(
        () => _registry(contracts: const []).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('promises nothing'),
          ),
        ),
      );
    });

    test('a malformed contract is refused with the CONTRACT’s voice, '
        'wherever it stands', () {
      expect(
        () => _registry(
          contracts: [
            _contract(),
            _contract(id: ''),
          ],
        ).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('without an identity is not a contract'),
          ),
        ),
      );
    });

    test('two contracts never share one identity — adjacent or not', () {
      expect(
        () => _registry(
          contracts: [
            _contract(),
            _contract(name: 'Un autre nom'),
          ],
        ).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('Two contracts never share one identity'),
          ),
        ),
      );
      expect(
        () => _registry(
          contracts: [
            _contract(),
            _contract(id: 'motion'),
            _contract(name: 'Un autre nom'),
          ],
        ).verify(),
        throwsStateError,
      );
    });
  });

  group('MentoraContractRequest — the demand concerning a contract', () {
    test('a request carries the contract whole and strictly intact — '
        'and a whole demand passes whole, wherever it stands', () {
      final contract = _contract();
      final request = MentoraContractRequest(contract: contract);

      expect(identical(request.contract, contract), isTrue);
      final registry = _registry();
      for (final declared in registry.contracts) {
        MentoraContractRequest(contract: declared).verify(registry);
      }
    });

    test('two demands about the same contract ARE the same demand', () {
      expect(_ask(), _ask());
      expect(_ask().hashCode, _ask().hashCode);
      expect({_ask(), _ask()}, hasLength(1));
      expect(_ask(), isNot(_ask(contract: _contract(id: 'motion'))));
      expect(_ask(), isNot(equals(_contract())));
    });

    test('a request is immutable: it is built const, and the same '
        'words are the same object', () {
      const first = MentoraContractRequest(
        contract: MentoraContract(id: 'motion', name: 'Le mouvement'),
      );
      const second = MentoraContractRequest(
        contract: MentoraContract(id: 'motion', name: 'Le mouvement'),
      );

      expect(identical(first, second), isTrue);
    });

    test('a contract the product never declared is refused — and a '
        'forgery too: the same identity with other words', () {
      expect(
        () => _ask(contract: _contract(id: 'ailleurs')).verify(_registry()),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('only ask about a contract the product declared'),
          ),
        ),
      );
      expect(
        () =>
            _ask(contract: _contract(name: 'Un autre nom')).verify(_registry()),
        throwsStateError,
      );
      expect(
        () => _ask(
          contract: _contract(description: 'Ce qui complète'),
        ).verify(_registry()),
        throwsStateError,
      );
    });

    test('an invalid contract is refused with the CONTRACT’s own '
        'voice, and verifying moves nothing', () {
      final registry = _registry();
      expect(
        () => _ask(contract: _contract(id: '')).verify(registry),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('without an identity is not a contract'),
          ),
        ),
      );
      final request = _ask();
      request.verify(registry);
      request.verify(registry);
      expect(request, _ask());
    });
  });

  group('MentoraContractResolution — the official answer', () {
    test('a resolution is the demand and the contract that answered '
        'it, whole and strictly intact — and a whole answer passes '
        'whole', () {
      final contract = _contract();
      final answer = _answer(asked: contract);

      expect(identical(answer.resolvedContract, contract), isTrue);
      answer.verify(_registry());
    });

    test('two answers with the same words ARE the same answer', () {
      expect(_answer(), _answer());
      expect(_answer().hashCode, _answer().hashCode);
      expect({_answer(), _answer()}, hasLength(1));
      expect(_answer(), isNot(_answer(asked: _contract(id: 'motion'))));
      expect(_answer(), isNot(equals(_ask())));
    });

    test('a resolution is immutable: it is built const, and the same '
        'words are the same object', () {
      const contract = MentoraContract(id: 'motion', name: 'Le mouvement');
      const first = MentoraContractResolution(
        request: MentoraContractRequest(contract: contract),
        resolvedContract: contract,
      );
      const second = MentoraContractResolution(
        request: MentoraContractRequest(contract: contract),
        resolvedContract: contract,
      );

      expect(identical(first, second), isTrue);
    });

    test('a substitution is refused: resolving another contract than '
        'the one asked about is not answering — by the words too', () {
      expect(
        () => _answer(resolved: _contract(id: 'motion')).verify(_registry()),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('is a substitution'),
          ),
        ),
      );
      expect(
        () => _answer(
          resolved: _contract(name: 'Un autre nom'),
        ).verify(_registry()),
        throwsStateError,
      );
    });

    test('an invalid demand is refused through the DEMAND’s own voice, '
        'and stating the fact twice changes nothing', () {
      expect(
        () => _answer(asked: _contract(id: 'ailleurs')).verify(_registry()),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('only ask about a contract the product declared'),
          ),
        ),
      );
      final registry = _registry();
      final answer = _answer();
      answer.verify(registry);
      answer.verify(registry);
      expect(answer, _answer());
    });
  });

  group('MentoraContractCoordinator — the order of the dialogue', () {
    test('a dialogue composes the three truths, and a whole dialogue '
        'passes whole', () {
      final dialogue = _dialogue();

      expect(dialogue.registry.contracts, hasLength(2));
      expect(dialogue.request.contract.id, 'accessibilite');
      expect(dialogue.resolution.resolvedContract.id, 'accessibilite');
      dialogue.verify();
    });

    test('the parts travel whole and strictly intact, and verifying '
        'twice changes nothing anywhere', () {
      final registry = _registry();
      final dialogue = _dialogue(registry: registry);

      dialogue.verify();
      dialogue.verify();

      expect(identical(dialogue.registry, registry), isTrue);
      expect(dialogue, _dialogue(registry: registry));
    });

    test('two dialogues over the same gathering with the same words '
        'ARE the same dialogue — and two gatherings are two '
        'products', () {
      final registry = _registry();

      expect(_dialogue(registry: registry), _dialogue(registry: registry));
      expect(
        _dialogue(registry: registry).hashCode,
        _dialogue(registry: registry).hashCode,
      );
      expect({
        _dialogue(registry: registry),
        _dialogue(registry: registry),
      }, hasLength(1));
      expect(_dialogue(), isNot(_dialogue()));
    });

    test('a dialogue is immutable: it is built const, and the same '
        'words are the same object', () {
      const contract = MentoraContract(id: 'motion', name: 'Le mouvement');
      const registry = MentoraContractRegistry(contracts: [contract]);
      const request = MentoraContractRequest(contract: contract);
      const first = MentoraContractCoordinator(
        registry: registry,
        request: request,
        resolution: MentoraContractResolution(
          request: request,
          resolvedContract: contract,
        ),
      );
      const second = MentoraContractCoordinator(
        registry: registry,
        request: request,
        resolution: MentoraContractResolution(
          request: request,
          resolvedContract: contract,
        ),
      );

      expect(identical(first, second), isTrue);
    });

    test('the official order holds: an invalid gathering speaks before '
        'an invalid demand, and the demand before a substitution', () {
      expect(
        () => _dialogue(
          registry: _registry(contracts: const []),
          asked: _contract(id: 'ailleurs'),
        ).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('promises nothing'),
          ),
        ),
      );
      expect(
        () => _dialogue(
          asked: _contract(id: 'ailleurs'),
          resolved: _contract(id: 'motion'),
        ).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('only ask about a contract the product declared'),
          ),
        ),
      );
      expect(
        () => _dialogue(resolved: _contract(id: 'motion')).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('is a substitution'),
          ),
        ),
      );
    });

    test('a resolution answering another demand is refused: a dialogue '
        'has one demand', () {
      final registry = _registry();
      final demand = MentoraContractRequest(contract: _contract());
      final other = MentoraContractRequest(contract: _contract(id: 'motion'));
      final dialogue = MentoraContractCoordinator(
        registry: registry,
        request: demand,
        resolution: MentoraContractResolution(
          request: other,
          resolvedContract: _contract(id: 'motion'),
        ),
      );

      expect(
        () => dialogue.verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('answers another demand'),
          ),
        ),
      );
    });
  });

  group('A contract is indifferent to every presentation', () {
    test('the five stay themselves under the four themes, the four '
        'scales, every comfort, both directions and Motion None', () {
      final registry = _registry();
      for (final variant in ThemeVariantId.values) {
        expect(_contract(), _contract(), reason: variant.name);
        expect(_ask(), _ask(), reason: variant.name);
      }
      for (final scale in FontScalePreference.values) {
        expect(_answer(), _answer(), reason: scale.name);
      }
      for (final comfort in ReadingComfortPreference.values) {
        expect(
          _dialogue(registry: registry),
          _dialogue(registry: registry),
          reason: comfort.name,
        );
      }
      for (final direction in TextDirection.values) {
        expect(_contract(), _contract(), reason: direction.name);
      }
      for (final motion in MotionPreference.values) {
        expect(_ask(), _ask(), reason: motion.name);
      }
      expect(ThemeVariantId.values, hasLength(4));
      expect(FontScalePreference.values, hasLength(4));
    });
  });

  group('Governance — the executable scans ship with the five', () {
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

    File contractFileOf(String name) =>
        File('lib/foundation/design_kit/contracts/$name');

    const names = [
      'mentora_contract.dart',
      'mentora_contract_registry.dart',
      'mentora_contract_request.dart',
      'mentora_contract_resolution.dart',
      'mentora_contract_coordinator.dart',
    ];

    test('each of the five imports exactly what it composes — and the '
        'contract imports nothing at all', () {
      List<String?> importsOf(String name) =>
          RegExp(r'^import (.*);', multiLine: true)
              .allMatches(codeOf(contractFileOf(name)))
              .map((match) => match.group(1))
              .toList();

      expect(importsOf('mentora_contract.dart'), isEmpty);
      expect(importsOf('mentora_contract_registry.dart'), [
        "'mentora_contract.dart'",
      ]);
      expect(importsOf('mentora_contract_request.dart'), [
        "'mentora_contract.dart'",
        "'mentora_contract_registry.dart'",
      ]);
      expect(importsOf('mentora_contract_resolution.dart'), [
        "'mentora_contract.dart'",
        "'mentora_contract_registry.dart'",
        "'mentora_contract_request.dart'",
      ]);
      expect(importsOf('mentora_contract_coordinator.dart'), [
        "'mentora_contract_registry.dart'",
        "'mentora_contract_request.dart'",
        "'mentora_contract_resolution.dart'",
      ]);
    });

    test('the chain of voices is required: the demand verifies the '
        'contract, the answer verifies the demand, the dialogue lets '
        'each speak in the official order — and none reaches around', () {
      expect(
        RegExp(
          r'contract\.verify\(\)',
        ).hasMatch(codeOf(contractFileOf('mentora_contract_request.dart'))),
        isTrue,
      );
      final resolution = codeOf(
        contractFileOf('mentora_contract_resolution.dart'),
      );
      expect(
        RegExp(r'request\.verify\(registry\)').hasMatch(resolution),
        isTrue,
      );
      expect(
        RegExp(r'registry\.contracts').hasMatch(resolution),
        isFalse,
        reason: 'the answer never walks the gathering itself',
      );
      final coordinator = codeOf(
        contractFileOf('mentora_contract_coordinator.dart'),
      );
      final order = [
        coordinator.indexOf('registry.verify()'),
        coordinator.indexOf('request.verify(registry)'),
        coordinator.indexOf('resolution.verify(registry)'),
      ];
      expect(order.every((position) => position >= 0), isTrue);
      for (int voice = 1; voice < order.length; voice += 1) {
        expect(order[voice], greaterThan(order[voice - 1]));
      }
    });

    test('no voice can even name a voice that is not its own', () {
      for (final beyond in const [
        'MentoraContractRegistry',
        'MentoraContractRequest',
        'MentoraContractResolution',
        'MentoraContractCoordinator',
      ]) {
        expect(
          codeOf(contractFileOf('mentora_contract.dart')).contains(beyond),
          isFalse,
          reason: 'the contract is a fact, and $beyond is another question',
        );
      }
      expect(
        codeOf(
          contractFileOf('mentora_contract_request.dart'),
        ).contains('MentoraContractResolution'),
        isFalse,
      );
      expect(
        codeOf(
          contractFileOf('mentora_contract_request.dart'),
        ).contains('MentoraContractCoordinator'),
        isFalse,
      );
      expect(
        codeOf(
          contractFileOf('mentora_contract_resolution.dart'),
        ).contains('MentoraContractCoordinator'),
        isFalse,
      );
    });

    test('no machine exists in any of the five, and no other layer is '
        'reached: the contracts speak to no navigation, no state, no '
        'layout', () {
      final forbidden = <String, RegExp>{
        'a machinery': RegExp(
          r'(?<![A-Za-z])(Engine|Workflow|Pipeline|Controller|Manager|'
          r'Service|Store|Reducer|Provider|Bloc|Dispatcher|Bus|Observer|'
          r'Notifier|Listener)(?![A-Za-z])',
        ),
        'a promise or a clock': RegExp(
          r'(?<![A-Za-z])(Future|Stream|async|await|Timer|Clock|Scheduler)'
          r'(?![A-Za-z])',
        ),
        'a framework': RegExp(
          r'(?<![A-Za-z])(Widget|BuildContext|Navigator|MediaQuery|'
          r'Platform)(?![A-Za-z])',
        ),
        'an ambient theme': RegExp(r'Theme\.of\('),
        'another foundation': RegExp(
          r'(?<![A-Za-z])(MentoraRoute|MentoraNavigation\w*|MentoraState|'
          r'MentoraLayout\w*)(?![A-Za-z])',
        ),
        'a storage or a network': RegExp(
          r'(?<![A-Za-z])(SharedPreferences|Hive|Firestore|http|fromJson|'
          r'toJson|cache|history)(?![A-Za-z(])',
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
      for (final name in names) {
        final source = codeOf(contractFileOf(name));
        for (final entry in forbidden.entries) {
          expect(
            entry.value.hasMatch(source),
            isFalse,
            reason: '$name: it never carries ${entry.key}',
          );
        }
      }
    });

    test('every field of every one of the five is final', () {
      for (final name in names) {
        for (final field in RegExp(
          r'^\s+(?!static)(\w[\w<>?, ]*)\s+\w+;',
          multiLine: true,
        ).allMatches(codeOf(contractFileOf(name)))) {
          expect(
            field.group(0)!.trimLeft().startsWith('final '),
            isTrue,
            reason: '$name: every field is final: ${field.group(0)!.trim()}',
          );
        }
      }
    });

    test('one of each exists inside the foundation, in the contracts '
        'layer and nowhere else', () {
      Iterable<File> dartFilesOf(String path) => Directory(path)
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));

      for (final single in const {
        'MentoraContract': 'mentora_contract.dart',
        'MentoraContractRegistry': 'mentora_contract_registry.dart',
        'MentoraContractRequest': 'mentora_contract_request.dart',
        'MentoraContractResolution': 'mentora_contract_resolution.dart',
        'MentoraContractCoordinator': 'mentora_contract_coordinator.dart',
      }.entries) {
        final places = <String>[];
        for (final file in dartFilesOf('lib')) {
          if (RegExp(
            'class\\s+${single.key}(?![A-Za-z])',
          ).hasMatch(codeOf(file))) {
            places.add(file.path.replaceAll(r'\', '/'));
          }
        }
        expect(places, hasLength(1), reason: single.key);
        expect(
          places.single,
          endsWith('design_kit/contracts/${single.value}'),
          reason: single.key,
        );
      }
    });

    test('the whole contracts vocabulary knows no framework: five '
        'files, zero framework imports', () {
      for (final name in names) {
        expect(
          RegExp(
            r"^import 'package:",
            multiLine: true,
          ).hasMatch(codeOf(contractFileOf(name))),
          isFalse,
          reason: '$name: a truth of the contracts needs no framework',
        );
      }
    });
  });
}
