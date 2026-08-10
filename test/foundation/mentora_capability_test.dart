import 'dart:io';

import 'package:flutter/material.dart' show TextDirection;
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/capabilities/mentora_capability.dart';
import 'package:mentora/foundation/design_kit/capabilities/mentora_capability_coordinator.dart';
import 'package:mentora/foundation/design_kit/capabilities/mentora_capability_registry.dart';
import 'package:mentora/foundation/design_kit/capabilities/mentora_capability_request.dart';
import 'package:mentora/foundation/design_kit/capabilities/mentora_capability_resolution.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';

MentoraCapability _capability({
  String id = 'consulter',
  String? name,
  String? description,
}) => MentoraCapability(
  id: id,
  name: name ?? 'Capacité $id',
  description: description,
);

MentoraCapabilityRegistry _registry({List<MentoraCapability>? capabilities}) =>
    MentoraCapabilityRegistry(
      capabilities: capabilities ?? [_capability(), _capability(id: 'publier')],
    );

MentoraCapabilityRequest _ask({MentoraCapability? capability}) =>
    MentoraCapabilityRequest(capability: capability ?? _capability());

MentoraCapabilityResolution _answer({
  MentoraCapability? asked,
  MentoraCapability? resolved,
}) {
  final capability = asked ?? _capability();
  return MentoraCapabilityResolution(
    request: MentoraCapabilityRequest(capability: capability),
    resolvedCapability: resolved ?? capability,
  );
}

MentoraCapabilityCoordinator _dialogue({
  MentoraCapabilityRegistry? registry,
  MentoraCapability? asked,
  MentoraCapability? resolved,
  MentoraCapabilityRequest? request,
}) {
  final capability = asked ?? _capability();
  final demand = request ?? MentoraCapabilityRequest(capability: capability);
  return MentoraCapabilityCoordinator(
    registry: registry ?? _registry(),
    request: demand,
    resolution: MentoraCapabilityResolution(
      request: demand,
      resolvedCapability: resolved ?? capability,
    ),
  );
}

void main() {
  group('MentoraCapability — what the product is able to do', () {
    test('a capability is its identity, its name and what completes '
        'it — and a whole capability passes whole', () {
      const capability = MentoraCapability(
        id: 'consulter',
        name: 'Consulter un expert',
        description: 'Ce que le produit sait faire pour une personne',
      );

      expect(capability.id, 'consulter');
      expect(capability.name, 'Consulter un expert');
      expect(
        capability.description,
        'Ce que le produit sait faire pour une personne',
      );
      capability.verify();
      expect(_capability().description, isNull);
      _capability().verify();
    });

    test('two capabilities with the same words ARE the same capability '
        '— and differ by any of them', () {
      expect(_capability(), _capability());
      expect(_capability().hashCode, _capability().hashCode);
      expect({_capability(), _capability()}, hasLength(1));
      expect(_capability(), isNot(_capability(id: 'publier')));
      expect(_capability(), isNot(_capability(name: 'Un autre nom')));
      expect(_capability(), isNot(_capability(description: 'Ce qui complète')));
      expect(_capability(), isNot(equals('consulter')));
    });

    test('a capability is immutable: it is built const, and the same '
        'words are the same object', () {
      const first = MentoraCapability(id: 'publier', name: 'Publier');
      const second = MentoraCapability(id: 'publier', name: 'Publier');

      expect(identical(first, second), isTrue);
    });

    test('a capability without a contract refuses — fail closed', () {
      expect(
        () => _capability(id: '').verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('without an identity is not a capability'),
          ),
        ),
      );
      expect(
        () => _capability(name: '').verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('offers nothing'),
          ),
        ),
      );
      expect(
        () => _capability(description: '').verify(),
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

  group('MentoraCapabilityRegistry — the official set', () {
    test('the registry gathers the capabilities once, and a whole '
        'gathering passes whole — built const, declared once', () {
      final registry = _registry();
      expect(registry.capabilities, hasLength(2));
      registry.verify();

      const first = MentoraCapabilityRegistry(
        capabilities: [MentoraCapability(id: 'publier', name: 'Publier')],
      );
      const second = MentoraCapabilityRegistry(
        capabilities: [MentoraCapability(id: 'publier', name: 'Publier')],
      );
      expect(identical(first, second), isTrue);
    });

    test('a product able to do nothing is refused', () {
      expect(
        () => _registry(capabilities: const []).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('able to do nothing'),
          ),
        ),
      );
    });

    test('a malformed capability is refused with the CAPABILITY’s '
        'voice, wherever it stands', () {
      expect(
        () => _registry(
          capabilities: [
            _capability(),
            _capability(id: ''),
          ],
        ).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('without an identity is not a capability'),
          ),
        ),
      );
    });

    test('two capabilities never share one identity — adjacent or '
        'not', () {
      expect(
        () => _registry(
          capabilities: [
            _capability(),
            _capability(name: 'Un autre nom'),
          ],
        ).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('Two capabilities never share one identity'),
          ),
        ),
      );
      expect(
        () => _registry(
          capabilities: [
            _capability(),
            _capability(id: 'publier'),
            _capability(name: 'Un autre nom'),
          ],
        ).verify(),
        throwsStateError,
      );
    });
  });

  group('MentoraCapabilityRequest — the capability asked for', () {
    test('a request carries the capability whole and strictly intact — '
        'and a whole demand passes whole', () {
      final capability = _capability();
      final request = MentoraCapabilityRequest(capability: capability);

      expect(identical(request.capability, capability), isTrue);
      request.verify();
    });

    test('the carrier invents no refusal: a malformed capability fails '
        'with the CAPABILITY’s voice, unrewritten — and verifying '
        'moves nothing', () {
      expect(
        () => _ask(capability: _capability(id: '')).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('without an identity is not a capability'),
          ),
        ),
      );
      final request = _ask();
      request.verify();
      request.verify();
      expect(request, _ask());
    });

    test('two demands for the same capability ARE the same demand', () {
      expect(_ask(), _ask());
      expect(_ask().hashCode, _ask().hashCode);
      expect({_ask(), _ask()}, hasLength(1));
      expect(_ask(), isNot(_ask(capability: _capability(id: 'publier'))));
      expect(_ask(), isNot(equals(_capability())));
    });

    test('a request is immutable: it is built const, and the same '
        'words are the same object', () {
      const first = MentoraCapabilityRequest(
        capability: MentoraCapability(id: 'publier', name: 'Publier'),
      );
      const second = MentoraCapabilityRequest(
        capability: MentoraCapability(id: 'publier', name: 'Publier'),
      );

      expect(identical(first, second), isTrue);
    });
  });

  group('MentoraCapabilityResolution — the capability resolved', () {
    test('a resolution is the demand and the capability that answered '
        'it, whole and strictly intact — and a whole answer passes '
        'whole', () {
      final capability = _capability();
      final answer = _answer(asked: capability);

      expect(identical(answer.resolvedCapability, capability), isTrue);
      answer.verify(_registry());
    });

    test('two answers with the same words ARE the same answer', () {
      expect(_answer(), _answer());
      expect(_answer().hashCode, _answer().hashCode);
      expect({_answer(), _answer()}, hasLength(1));
      expect(_answer(), isNot(_answer(asked: _capability(id: 'publier'))));
      expect(_answer(), isNot(equals(_ask())));
    });

    test('a resolution is immutable: it is built const, and the same '
        'words are the same object', () {
      const capability = MentoraCapability(id: 'publier', name: 'Publier');
      const first = MentoraCapabilityResolution(
        request: MentoraCapabilityRequest(capability: capability),
        resolvedCapability: capability,
      );
      const second = MentoraCapabilityResolution(
        request: MentoraCapabilityRequest(capability: capability),
        resolvedCapability: capability,
      );

      expect(identical(first, second), isTrue);
    });

    test('the demand speaks always before the resolution: a malformed '
        'capability is refused through the demand, unrewritten', () {
      expect(
        () => _answer(asked: _capability(id: '')).verify(_registry()),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('without an identity is not a capability'),
          ),
        ),
      );
    });

    test('a substitution is refused: resolving another capability than '
        'the one asked for is not answering — by the words too', () {
      expect(
        () => _answer(resolved: _capability(id: 'publier')).verify(_registry()),
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
          resolved: _capability(name: 'Un autre nom'),
        ).verify(_registry()),
        throwsStateError,
      );
    });

    test('a capability the product never declared is refused — the '
        'resolution is the first voice that holds the gathering', () {
      expect(
        () => _answer(asked: _capability(id: 'ailleurs')).verify(_registry()),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('only be resolved to a capability the product declared'),
          ),
        ),
      );
      // A forgery falls the same way: the same identity with other
      // words was never declared.
      expect(
        () => _answer(
          asked: _capability(description: 'Ce qui complète'),
        ).verify(_registry()),
        throwsStateError,
      );
    });

    test('stating the fact twice changes nothing anywhere', () {
      final registry = _registry();
      final answer = _answer();

      answer.verify(registry);
      answer.verify(registry);

      expect(answer, _answer());
    });
  });

  group('MentoraCapabilityCoordinator — the order of the dialogue', () {
    test('a dialogue composes the three truths, whole and strictly '
        'intact — and a whole dialogue passes whole, twice over', () {
      final registry = _registry();
      final dialogue = _dialogue(registry: registry);

      expect(identical(dialogue.registry, registry), isTrue);
      dialogue.verify();
      dialogue.verify();
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
      const capability = MentoraCapability(id: 'publier', name: 'Publier');
      const registry = MentoraCapabilityRegistry(capabilities: [capability]);
      const request = MentoraCapabilityRequest(capability: capability);
      const first = MentoraCapabilityCoordinator(
        registry: registry,
        request: request,
        resolution: MentoraCapabilityResolution(
          request: request,
          resolvedCapability: capability,
        ),
      );
      const second = MentoraCapabilityCoordinator(
        registry: registry,
        request: request,
        resolution: MentoraCapabilityResolution(
          request: request,
          resolvedCapability: capability,
        ),
      );

      expect(identical(first, second), isTrue);
    });

    test('the official order holds: the gathering speaks before the '
        'demand, and the demand before the resolution', () {
      expect(
        () => _dialogue(
          registry: _registry(capabilities: const []),
          asked: _capability(id: ''),
        ).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('able to do nothing'),
          ),
        ),
      );
      expect(
        () => _dialogue(
          asked: _capability(id: ''),
          resolved: _capability(id: 'publier'),
        ).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('without an identity is not a capability'),
          ),
        ),
      );
      expect(
        () => _dialogue(resolved: _capability(id: 'publier')).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('is a substitution'),
          ),
        ),
      );
      expect(
        () => _dialogue(asked: _capability(id: 'ailleurs')).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('only be resolved to a capability the product declared'),
          ),
        ),
      );
    });

    test('a resolution answering another demand is refused: a dialogue '
        'has one demand', () {
      final registry = _registry();
      final demand = MentoraCapabilityRequest(capability: _capability());
      final other = MentoraCapabilityRequest(
        capability: _capability(id: 'publier'),
      );
      final dialogue = MentoraCapabilityCoordinator(
        registry: registry,
        request: demand,
        resolution: MentoraCapabilityResolution(
          request: other,
          resolvedCapability: _capability(id: 'publier'),
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

  group('A capability is indifferent to every presentation', () {
    test('the five stay themselves under the four themes, the four '
        'scales, every comfort, both directions and Motion None', () {
      final registry = _registry();
      for (final variant in ThemeVariantId.values) {
        expect(_capability(), _capability(), reason: variant.name);
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
        expect(_capability(), _capability(), reason: direction.name);
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

    File capabilityFileOf(String name) =>
        File('lib/foundation/design_kit/capabilities/$name');

    const names = [
      'mentora_capability.dart',
      'mentora_capability_registry.dart',
      'mentora_capability_request.dart',
      'mentora_capability_resolution.dart',
      'mentora_capability_coordinator.dart',
    ];

    test('each of the five imports exactly what it composes — and the '
        'capability imports nothing at all', () {
      List<String?> importsOf(String name) =>
          RegExp(r'^import (.*);', multiLine: true)
              .allMatches(codeOf(capabilityFileOf(name)))
              .map((match) => match.group(1))
              .toList();

      expect(importsOf('mentora_capability.dart'), isEmpty);
      expect(importsOf('mentora_capability_registry.dart'), [
        "'mentora_capability.dart'",
      ]);
      expect(importsOf('mentora_capability_request.dart'), [
        "'mentora_capability.dart'",
      ]);
      expect(importsOf('mentora_capability_resolution.dart'), [
        "'mentora_capability.dart'",
        "'mentora_capability_registry.dart'",
        "'mentora_capability_request.dart'",
      ]);
      expect(importsOf('mentora_capability_coordinator.dart'), [
        "'mentora_capability_registry.dart'",
        "'mentora_capability_request.dart'",
        "'mentora_capability_resolution.dart'",
      ]);
    });

    test('the request is a pure carrier: no throw in its source, no '
        'gathering in its reach — the capability speaks through it', () {
      final request = codeOf(
        capabilityFileOf('mentora_capability_request.dart'),
      );

      expect(RegExp(r'throw\s').hasMatch(request), isFalse);
      expect(request.contains('MentoraCapabilityRegistry'), isFalse);
      expect(RegExp(r'capability\.verify\(\)').hasMatch(request), isTrue);
    });

    test('the chain of voices is required: the demand speaks always '
        'before the resolution, and the dialogue speaks in the '
        'official order', () {
      final resolution = codeOf(
        capabilityFileOf('mentora_capability_resolution.dart'),
      );
      expect(RegExp(r'request\.verify\(\)').hasMatch(resolution), isTrue);

      final coordinator = codeOf(
        capabilityFileOf('mentora_capability_coordinator.dart'),
      );
      final order = [
        coordinator.indexOf('registry.verify()'),
        coordinator.indexOf('request.verify()'),
        coordinator.indexOf('resolution.verify(registry)'),
      ];
      expect(order.every((position) => position >= 0), isTrue);
      for (int voice = 1; voice < order.length; voice += 1) {
        expect(order[voice], greaterThan(order[voice - 1]));
      }
      // And the coordinator walks no gathering itself.
      expect(RegExp(r'registry\.capabilities').hasMatch(coordinator), isFalse);
    });

    test('no voice can even name a voice that is not its own', () {
      for (final beyond in const [
        'MentoraCapabilityRegistry',
        'MentoraCapabilityRequest',
        'MentoraCapabilityResolution',
        'MentoraCapabilityCoordinator',
      ]) {
        expect(
          codeOf(capabilityFileOf('mentora_capability.dart')).contains(beyond),
          isFalse,
          reason:
              'the capability is a fact, and $beyond is another '
              'question',
        );
      }
      for (final beyond in const [
        'MentoraCapabilityResolution',
        'MentoraCapabilityCoordinator',
      ]) {
        expect(
          codeOf(
            capabilityFileOf('mentora_capability_request.dart'),
          ).contains(beyond),
          isFalse,
        );
      }
      expect(
        codeOf(
          capabilityFileOf('mentora_capability_resolution.dart'),
        ).contains('MentoraCapabilityCoordinator'),
        isFalse,
      );
    });

    test('the capability foundation depends on no other foundation: '
        'no layout, no navigation, no state, no contract can be '
        'named', () {
      final beyond = RegExp(
        r'(?<![A-Za-z])(MentoraLayout\w*|MentoraNavigation\w*|MentoraRoute|'
        r'MentoraDestination|MentoraState\w*|MentoraStore|MentoraReducer|'
        r'MentoraProjection|MentoraReadModel|MentoraCommand|MentoraQuery|'
        r'MentoraEvent|MentoraContract\w*)(?![A-Za-z])',
      );
      for (final name in names) {
        expect(
          beyond.hasMatch(codeOf(capabilityFileOf(name))),
          isFalse,
          reason: '$name: the capabilities speak only to the capabilities',
        );
      }
    });

    test('no machine, no permission, no api, no storage exists in any '
        'of the five — and no mutable thing', () {
      final forbidden = <String, RegExp>{
        'a machinery': RegExp(
          r'(?<![A-Za-z])(Engine|Service|Manager|Controller|Pipeline|'
          r'Workflow|Machine|Bloc|Provider|Notifier|Observer|Dispatcher|'
          r'Mediator|Saga)(?![A-Za-z])',
        ),
        'a promise': RegExp(
          r'(?<![A-Za-z])(Future|Stream|async|await)(?![A-Za-z])',
        ),
        'a framework': RegExp(
          r'(?<![A-Za-z])(Widget|BuildContext|Navigator|MediaQuery|'
          r'Platform)(?![A-Za-z])',
        ),
        'an ambient theme': RegExp(r'Theme\.of\('),
        'a permission or a flag': RegExp(
          r'(?<![A-Za-z])(permission|granted|denied|role|admin|flag\w*)'
          r'\s*[:.(=]',
        ),
        'an api or a storage': RegExp(
          r'(?<![A-Za-z])(http|Rest|GraphQL|fromJson|toJson|Database|'
          r'Repository|SharedPreferences|Hive|Firestore|cache|history)'
          r'(?![A-Za-z(])',
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
        final source = codeOf(capabilityFileOf(name));
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
        ).allMatches(codeOf(capabilityFileOf(name)))) {
          expect(
            field.group(0)!.trimLeft().startsWith('final '),
            isTrue,
            reason: '$name: every field is final: ${field.group(0)!.trim()}',
          );
        }
      }
    });

    test('one of each exists, in the capabilities layer and nowhere '
        'else', () {
      Iterable<File> dartFilesOf(String path) => Directory(path)
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));

      for (final single in const {
        'MentoraCapability': 'mentora_capability.dart',
        'MentoraCapabilityRegistry': 'mentora_capability_registry.dart',
        'MentoraCapabilityRequest': 'mentora_capability_request.dart',
        'MentoraCapabilityResolution': 'mentora_capability_resolution.dart',
        'MentoraCapabilityCoordinator': 'mentora_capability_coordinator.dart',
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
          endsWith('design_kit/capabilities/${single.value}'),
          reason: single.key,
        );
      }
    });

    test('the whole capabilities vocabulary knows no framework: five '
        'files, zero framework imports', () {
      for (final name in names) {
        expect(
          RegExp(
            r"^import 'package:",
            multiLine: true,
          ).hasMatch(codeOf(capabilityFileOf(name))),
          isFalse,
          reason: '$name: a truth of the capabilities needs no framework',
        );
      }
    });
  });
}
