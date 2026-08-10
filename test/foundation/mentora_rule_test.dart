import 'dart:io';

import 'package:flutter/material.dart' show TextDirection;
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/foundation/design_kit/appearance/appearance_engine.dart';
import 'package:mentora/foundation/design_kit/rules/mentora_rule.dart';
import 'package:mentora/foundation/design_kit/rules/mentora_rule_coordinator.dart';
import 'package:mentora/foundation/design_kit/rules/mentora_rule_registry.dart';
import 'package:mentora/foundation/design_kit/rules/mentora_rule_request.dart';
import 'package:mentora/foundation/design_kit/rules/mentora_rule_resolution.dart';
import 'package:mentora/foundation/design_kit/theme/theme_variant.dart';

MentoraRule _rule({
  String id = 'annonce-unique',
  String? name,
  String? description,
}) => MentoraRule(id: id, name: name ?? 'Règle $id', description: description);

MentoraRuleRegistry _registry({List<MentoraRule>? rules}) =>
    MentoraRuleRegistry(
      rules: rules ?? [_rule(), _rule(id: 'identite-jamais-position')],
    );

MentoraRuleRequest _ask({MentoraRule? rule}) =>
    MentoraRuleRequest(rule: rule ?? _rule());

MentoraRuleResolution _answer({MentoraRule? asked, MentoraRule? resolved}) {
  final rule = asked ?? _rule();
  return MentoraRuleResolution(
    request: MentoraRuleRequest(rule: rule),
    resolvedRule: resolved ?? rule,
  );
}

MentoraRuleCoordinator _dialogue({
  MentoraRuleRegistry? registry,
  MentoraRule? asked,
  MentoraRule? resolved,
  MentoraRuleRequest? request,
}) {
  final rule = asked ?? _rule();
  final demand = request ?? MentoraRuleRequest(rule: rule);
  return MentoraRuleCoordinator(
    registry: registry ?? _registry(),
    request: demand,
    resolution: MentoraRuleResolution(
      request: demand,
      resolvedRule: resolved ?? rule,
    ),
  );
}

void main() {
  group('MentoraRule — the official rule', () {
    test('a rule is its identity, its name and what completes it — and '
        'a whole rule passes whole', () {
      const rule = MentoraRule(
        id: 'annonce-unique',
        name: 'Chaque région est annoncée exactement une fois',
        description: 'Ce que toute la fondation tient déjà par balayage',
      );

      expect(rule.id, 'annonce-unique');
      expect(rule.name, 'Chaque région est annoncée exactement une fois');
      expect(
        rule.description,
        'Ce que toute la fondation tient déjà par balayage',
      );
      rule.verify();
      expect(_rule().description, isNull);
      _rule().verify();
    });

    test('two rules with the same words ARE the same rule — and differ '
        'by any of them', () {
      expect(_rule(), _rule());
      expect(_rule().hashCode, _rule().hashCode);
      expect({_rule(), _rule()}, hasLength(1));
      expect(_rule(), isNot(_rule(id: 'identite-jamais-position')));
      expect(_rule(), isNot(_rule(name: 'Un autre nom')));
      expect(_rule(), isNot(_rule(description: 'Ce qui complète')));
      expect(_rule(), isNot(equals('annonce-unique')));
    });

    test('a rule is immutable: it is built const, and the same words '
        'are the same object', () {
      const first = MentoraRule(id: 'sobre', name: 'La sobriété');
      const second = MentoraRule(id: 'sobre', name: 'La sobriété');

      expect(identical(first, second), isTrue);
    });

    test('a rule without a contract refuses — fail closed', () {
      expect(
        () => _rule(id: '').verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('without an identity is not a rule'),
          ),
        ),
      );
      expect(
        () => _rule(name: '').verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('governs nothing'),
          ),
        ),
      );
      expect(
        () => _rule(description: '').verify(),
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

  group('MentoraRuleRegistry — the official set', () {
    test('the registry gathers the rules once, and a whole gathering '
        'passes whole — built const, declared once', () {
      final registry = _registry();
      expect(registry.rules, hasLength(2));
      registry.verify();

      const first = MentoraRuleRegistry(
        rules: [MentoraRule(id: 'sobre', name: 'La sobriété')],
      );
      const second = MentoraRuleRegistry(
        rules: [MentoraRule(id: 'sobre', name: 'La sobriété')],
      );
      expect(identical(first, second), isTrue);
    });

    test('a product governed by nothing is refused', () {
      expect(
        () => _registry(rules: const []).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('governed by nothing'),
          ),
        ),
      );
    });

    test('a malformed rule is refused with the RULE’s voice, wherever '
        'it stands', () {
      expect(
        () => _registry(
          rules: [
            _rule(),
            _rule(id: ''),
          ],
        ).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('without an identity is not a rule'),
          ),
        ),
      );
    });

    test('two rules never share one identity — adjacent or not', () {
      expect(
        () => _registry(
          rules: [
            _rule(),
            _rule(name: 'Un autre nom'),
          ],
        ).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('Two rules never share one identity'),
          ),
        ),
      );
      expect(
        () => _registry(
          rules: [
            _rule(),
            _rule(id: 'identite-jamais-position'),
            _rule(name: 'Un autre nom'),
          ],
        ).verify(),
        throwsStateError,
      );
    });
  });

  group('MentoraRuleRequest — the rule asked for', () {
    test('a request carries the rule whole and strictly intact — and a '
        'whole demand passes whole', () {
      final rule = _rule();
      final request = MentoraRuleRequest(rule: rule);

      expect(identical(request.rule, rule), isTrue);
      request.verify();
    });

    test('the carrier invents no refusal: a malformed rule fails with '
        'the RULE’s voice, unrewritten — and verifying moves '
        'nothing', () {
      expect(
        () => _ask(rule: _rule(id: '')).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('without an identity is not a rule'),
          ),
        ),
      );
      final request = _ask();
      request.verify();
      request.verify();
      expect(request, _ask());
    });

    test('two demands for the same rule ARE the same demand', () {
      expect(_ask(), _ask());
      expect(_ask().hashCode, _ask().hashCode);
      expect({_ask(), _ask()}, hasLength(1));
      expect(_ask(), isNot(_ask(rule: _rule(id: 'identite-jamais-position'))));
      expect(_ask(), isNot(equals(_rule())));
    });

    test('a request is immutable: it is built const, and the same '
        'words are the same object', () {
      const first = MentoraRuleRequest(
        rule: MentoraRule(id: 'sobre', name: 'La sobriété'),
      );
      const second = MentoraRuleRequest(
        rule: MentoraRule(id: 'sobre', name: 'La sobriété'),
      );

      expect(identical(first, second), isTrue);
    });
  });

  group('MentoraRuleResolution — the rule resolved', () {
    test('a resolution is the demand and the rule that answered it, '
        'whole and strictly intact — and a whole answer passes '
        'whole', () {
      final rule = _rule();
      final answer = _answer(asked: rule);

      expect(identical(answer.resolvedRule, rule), isTrue);
      answer.verify(_registry());
    });

    test('two answers with the same words ARE the same answer', () {
      expect(_answer(), _answer());
      expect(_answer().hashCode, _answer().hashCode);
      expect({_answer(), _answer()}, hasLength(1));
      expect(
        _answer(),
        isNot(_answer(asked: _rule(id: 'identite-jamais-position'))),
      );
      expect(_answer(), isNot(equals(_ask())));
    });

    test('a resolution is immutable: it is built const, and the same '
        'words are the same object', () {
      const rule = MentoraRule(id: 'sobre', name: 'La sobriété');
      const first = MentoraRuleResolution(
        request: MentoraRuleRequest(rule: rule),
        resolvedRule: rule,
      );
      const second = MentoraRuleResolution(
        request: MentoraRuleRequest(rule: rule),
        resolvedRule: rule,
      );

      expect(identical(first, second), isTrue);
    });

    test('the demand speaks always before the resolution: a malformed '
        'rule is refused through the demand, unrewritten', () {
      expect(
        () => _answer(asked: _rule(id: '')).verify(_registry()),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('without an identity is not a rule'),
          ),
        ),
      );
    });

    test('a substitution is refused: resolving another rule than the '
        'one asked for is not answering — by the words too', () {
      expect(
        () => _answer(
          resolved: _rule(id: 'identite-jamais-position'),
        ).verify(_registry()),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('is a substitution'),
          ),
        ),
      );
      expect(
        () =>
            _answer(resolved: _rule(name: 'Un autre nom')).verify(_registry()),
        throwsStateError,
      );
    });

    test('a rule the product never declared is refused — the '
        'resolution is the first voice that holds the gathering', () {
      expect(
        () => _answer(asked: _rule(id: 'ailleurs')).verify(_registry()),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('only be resolved to a rule the product declared'),
          ),
        ),
      );
      expect(
        () => _answer(
          asked: _rule(description: 'Ce qui complète'),
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

  group('MentoraRuleCoordinator — the order of the dialogue', () {
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
      const rule = MentoraRule(id: 'sobre', name: 'La sobriété');
      const registry = MentoraRuleRegistry(rules: [rule]);
      const request = MentoraRuleRequest(rule: rule);
      const first = MentoraRuleCoordinator(
        registry: registry,
        request: request,
        resolution: MentoraRuleResolution(request: request, resolvedRule: rule),
      );
      const second = MentoraRuleCoordinator(
        registry: registry,
        request: request,
        resolution: MentoraRuleResolution(request: request, resolvedRule: rule),
      );

      expect(identical(first, second), isTrue);
    });

    test('the official order holds: the gathering speaks before the '
        'demand, the demand before the substitution, and the '
        'declaration last', () {
      expect(
        () => _dialogue(
          registry: _registry(rules: const []),
          asked: _rule(id: ''),
        ).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('governed by nothing'),
          ),
        ),
      );
      expect(
        () => _dialogue(
          asked: _rule(id: ''),
          resolved: _rule(id: 'identite-jamais-position'),
        ).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('without an identity is not a rule'),
          ),
        ),
      );
      expect(
        () =>
            _dialogue(resolved: _rule(id: 'identite-jamais-position')).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('is a substitution'),
          ),
        ),
      );
      expect(
        () => _dialogue(asked: _rule(id: 'ailleurs')).verify(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('only be resolved to a rule the product declared'),
          ),
        ),
      );
    });

    test('a resolution answering another demand is refused: a dialogue '
        'has one demand', () {
      final registry = _registry();
      final demand = MentoraRuleRequest(rule: _rule());
      final other = MentoraRuleRequest(
        rule: _rule(id: 'identite-jamais-position'),
      );
      final dialogue = MentoraRuleCoordinator(
        registry: registry,
        request: demand,
        resolution: MentoraRuleResolution(
          request: other,
          resolvedRule: _rule(id: 'identite-jamais-position'),
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

  group('A rule is indifferent to every presentation', () {
    test('the five stay themselves under the four themes, the four '
        'scales, every comfort, both directions and Motion None', () {
      final registry = _registry();
      for (final variant in ThemeVariantId.values) {
        expect(_rule(), _rule(), reason: variant.name);
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
        expect(_rule(), _rule(), reason: direction.name);
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

    File ruleFileOf(String name) =>
        File('lib/foundation/design_kit/rules/$name');

    const names = [
      'mentora_rule.dart',
      'mentora_rule_registry.dart',
      'mentora_rule_request.dart',
      'mentora_rule_resolution.dart',
      'mentora_rule_coordinator.dart',
    ];

    test('each of the five imports exactly what it composes — and the '
        'rule imports nothing at all', () {
      List<String?> importsOf(String name) => RegExp(
        r'^import (.*);',
        multiLine: true,
      ).allMatches(codeOf(ruleFileOf(name))).map((m) => m.group(1)).toList();

      expect(importsOf('mentora_rule.dart'), isEmpty);
      expect(importsOf('mentora_rule_registry.dart'), ["'mentora_rule.dart'"]);
      expect(importsOf('mentora_rule_request.dart'), ["'mentora_rule.dart'"]);
      expect(importsOf('mentora_rule_resolution.dart'), [
        "'mentora_rule.dart'",
        "'mentora_rule_registry.dart'",
        "'mentora_rule_request.dart'",
      ]);
      expect(importsOf('mentora_rule_coordinator.dart'), [
        "'mentora_rule_registry.dart'",
        "'mentora_rule_request.dart'",
        "'mentora_rule_resolution.dart'",
      ]);
    });

    test('the request is a pure carrier: no throw in its source, no '
        'gathering in its reach — the rule speaks through it', () {
      final request = codeOf(ruleFileOf('mentora_rule_request.dart'));

      expect(RegExp(r'throw\s').hasMatch(request), isFalse);
      expect(request.contains('MentoraRuleRegistry'), isFalse);
      expect(RegExp(r'rule\.verify\(\)').hasMatch(request), isTrue);
    });

    test('the chain of voices is required: the demand speaks always '
        'before the resolution, and the dialogue speaks in the '
        'official order, walking no gathering itself', () {
      final resolution = codeOf(ruleFileOf('mentora_rule_resolution.dart'));
      expect(RegExp(r'request\.verify\(\)').hasMatch(resolution), isTrue);

      final coordinator = codeOf(ruleFileOf('mentora_rule_coordinator.dart'));
      final order = [
        coordinator.indexOf('registry.verify()'),
        coordinator.indexOf('request.verify()'),
        coordinator.indexOf('resolution.verify(registry)'),
      ];
      expect(order.every((position) => position >= 0), isTrue);
      for (int voice = 1; voice < order.length; voice += 1) {
        expect(order[voice], greaterThan(order[voice - 1]));
      }
      expect(RegExp(r'registry\.rules').hasMatch(coordinator), isFalse);
    });

    test('no voice can even name a voice that is not its own', () {
      for (final beyond in const [
        'MentoraRuleRegistry',
        'MentoraRuleRequest',
        'MentoraRuleResolution',
        'MentoraRuleCoordinator',
      ]) {
        expect(
          codeOf(ruleFileOf('mentora_rule.dart')).contains(beyond),
          isFalse,
          reason: 'the rule is a fact, and $beyond is another question',
        );
      }
      for (final beyond in const [
        'MentoraRuleResolution',
        'MentoraRuleCoordinator',
      ]) {
        expect(
          codeOf(ruleFileOf('mentora_rule_request.dart')).contains(beyond),
          isFalse,
        );
      }
      expect(
        codeOf(
          ruleFileOf('mentora_rule_resolution.dart'),
        ).contains('MentoraRuleCoordinator'),
        isFalse,
      );
    });

    test('the rule foundation depends on no other foundation: no '
        'layout, no navigation, no state, no contract, no capability '
        'can be named', () {
      final beyond = RegExp(
        r'(?<![A-Za-z])(MentoraLayout\w*|MentoraNavigation\w*|MentoraRoute|'
        r'MentoraDestination|MentoraState\w*|MentoraStore|MentoraReducer|'
        r'MentoraProjection|MentoraReadModel|MentoraCommand|MentoraQuery|'
        r'MentoraEvent|MentoraContract\w*|MentoraCapability\w*)(?![A-Za-z])',
      );
      for (final name in names) {
        expect(
          beyond.hasMatch(codeOf(ruleFileOf(name))),
          isFalse,
          reason: '$name: the rules speak only to the rules',
        );
      }
    });

    test('no machine, no api, no storage exists in any of the five — '
        'and no mutable thing', () {
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
        final source = codeOf(ruleFileOf(name));
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
        ).allMatches(codeOf(ruleFileOf(name)))) {
          expect(
            field.group(0)!.trimLeft().startsWith('final '),
            isTrue,
            reason: '$name: every field is final: ${field.group(0)!.trim()}',
          );
        }
      }
    });

    test('one of each exists inside the foundation, in the rules layer '
        'and nowhere else — the rules of other layers are other '
        'concepts, ungoverned by this rule', () {
      Iterable<File> dartFilesOf(String path) => Directory(path)
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));

      for (final single in const {
        'MentoraRule': 'mentora_rule.dart',
        'MentoraRuleRegistry': 'mentora_rule_registry.dart',
        'MentoraRuleRequest': 'mentora_rule_request.dart',
        'MentoraRuleResolution': 'mentora_rule_resolution.dart',
        'MentoraRuleCoordinator': 'mentora_rule_coordinator.dart',
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
          endsWith('design_kit/rules/${single.value}'),
          reason: single.key,
        );
      }
    });

    test('the whole rules vocabulary knows no framework: five files, '
        'zero framework imports', () {
      for (final name in names) {
        expect(
          RegExp(
            r"^import 'package:",
            multiLine: true,
          ).hasMatch(codeOf(ruleFileOf(name))),
          isFalse,
          reason: '$name: a truth of the rules needs no framework',
        );
      }
    });
  });
}
