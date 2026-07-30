import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/core/automation/domain/automation.dart';
import 'package:mentora/core/automation/domain/automation_id.dart';
import 'package:mentora/core/automation/repository/in_memory_automation_repository.dart';

import 'automation_test_factory.dart';

void main() {
  group('InMemoryAutomationRepository', () {
    group('initial state', () {
      test('starts empty', () async {
        final InMemoryAutomationRepository repository =
            InMemoryAutomationRepository();

        expect(repository.length, 0);
        expect(repository.isEmpty, isTrue);
        expect(repository.isNotEmpty, isFalse);
        expect(await repository.findAll(), isEmpty);
      });

      test('returns null when an automation does not exist', () async {
        final InMemoryAutomationRepository repository =
            InMemoryAutomationRepository();

        final Automation? result = await repository.findById(
          AutomationId('unknown'),
        );

        expect(result, isNull);
      });

      test('reports false when an automation does not exist', () async {
        final InMemoryAutomationRepository repository =
            InMemoryAutomationRepository();

        final bool result = await repository.exists(AutomationId('unknown'));

        expect(result, isFalse);
      });

      test('accepts an empty initial collection', () async {
        final InMemoryAutomationRepository repository =
            InMemoryAutomationRepository(automations: const <Automation>[]);

        expect(repository.length, 0);
        expect(repository.isEmpty, isTrue);
        expect(await repository.findAll(), isEmpty);
      });
    });

    group('construction', () {
      test('persists initial automations in supplied order', () async {
        final Automation first = AutomationTestFactory.create(id: 'first');
        final Automation second = AutomationTestFactory.create(id: 'second');
        final Automation third = AutomationTestFactory.create(id: 'third');

        final InMemoryAutomationRepository repository =
            InMemoryAutomationRepository(
              automations: <Automation>[first, second, third],
            );

        final List<Automation> automations = await repository.findAll();

        expect(repository.length, 3);
        expect(repository.isEmpty, isFalse);
        expect(repository.isNotEmpty, isTrue);
        expect(automations, hasLength(3));
        expect(automations[0], same(first));
        expect(automations[1], same(second));
        expect(automations[2], same(third));
      });

      test(
        'replaces duplicate initial identifiers while preserving position',
        () async {
          final Automation original = AutomationTestFactory.create(
            id: 'shared-id',
            name: 'Original automation',
            version: 1,
          );
          final Automation middle = AutomationTestFactory.create(id: 'middle');
          final Automation replacement = AutomationTestFactory.create(
            id: 'shared-id',
            name: 'Replacement automation',
            version: 2,
          );

          final InMemoryAutomationRepository repository =
              InMemoryAutomationRepository(
                automations: <Automation>[original, middle, replacement],
              );

          final List<Automation> automations = await repository.findAll();

          expect(repository.length, 2);
          expect(automations, hasLength(2));
          expect(automations[0], same(replacement));
          expect(automations[1], same(middle));
          expect(await repository.findById(replacement.id), same(replacement));
        },
      );
    });

    group('save', () {
      test('persists a new automation', () async {
        final InMemoryAutomationRepository repository =
            InMemoryAutomationRepository();
        final Automation automation = AutomationTestFactory.create(id: 'saved');

        await repository.save(automation);

        expect(repository.length, 1);
        expect(repository.isEmpty, isFalse);
        expect(repository.isNotEmpty, isTrue);
        expect(await repository.findById(automation.id), same(automation));
        expect(await repository.exists(automation.id), isTrue);
      });

      test('persists multiple independent automations', () async {
        final InMemoryAutomationRepository repository =
            InMemoryAutomationRepository();
        final Automation first = AutomationTestFactory.create(id: 'first');
        final Automation second = AutomationTestFactory.create(id: 'second');

        await repository.save(first);
        await repository.save(second);

        expect(repository.length, 2);
        expect(await repository.findById(first.id), same(first));
        expect(await repository.findById(second.id), same(second));
      });

      test('preserves insertion order for new automations', () async {
        final InMemoryAutomationRepository repository =
            InMemoryAutomationRepository();
        final Automation first = AutomationTestFactory.create(id: 'first');
        final Automation second = AutomationTestFactory.create(id: 'second');
        final Automation third = AutomationTestFactory.create(id: 'third');

        await repository.save(first);
        await repository.save(second);
        await repository.save(third);

        final List<Automation> automations = await repository.findAll();

        expect(automations, hasLength(3));
        expect(automations[0], same(first));
        expect(automations[1], same(second));
        expect(automations[2], same(third));
      });

      test(
        'replaces an existing automation with the same identifier',
        () async {
          final Automation original = AutomationTestFactory.create(
            id: 'updatable',
            name: 'Original',
            version: 1,
          );
          final Automation replacement = AutomationTestFactory.create(
            id: 'updatable',
            name: 'Replacement',
            version: 2,
          );
          final InMemoryAutomationRepository repository =
              InMemoryAutomationRepository(automations: <Automation>[original]);

          await repository.save(replacement);

          expect(repository.length, 1);
          expect(await repository.findById(replacement.id), same(replacement));
          expect(await repository.findById(original.id), isNot(same(original)));
        },
      );

      test('preserves original insertion position when replacing', () async {
        final Automation first = AutomationTestFactory.create(
          id: 'first',
          name: 'Original first',
          version: 1,
        );
        final Automation second = AutomationTestFactory.create(id: 'second');
        final Automation third = AutomationTestFactory.create(id: 'third');
        final Automation firstReplacement = AutomationTestFactory.create(
          id: 'first',
          name: 'Updated first',
          version: 2,
        );
        final InMemoryAutomationRepository repository =
            InMemoryAutomationRepository(
              automations: <Automation>[first, second, third],
            );

        await repository.save(firstReplacement);

        final List<Automation> automations = await repository.findAll();

        expect(repository.length, 3);
        expect(automations[0], same(firstReplacement));
        expect(automations[1], same(second));
        expect(automations[2], same(third));
      });

      test('repeated save with the same instance is idempotent', () async {
        final Automation automation = AutomationTestFactory.create(
          id: 'idempotent',
        );
        final InMemoryAutomationRepository repository =
            InMemoryAutomationRepository();

        await repository.save(automation);
        await repository.save(automation);

        expect(repository.length, 1);
        expect(await repository.findById(automation.id), same(automation));
      });
    });

    group('findById', () {
      test('returns the exact persisted instance', () async {
        final Automation automation = AutomationTestFactory.create(
          id: 'resolvable',
        );
        final InMemoryAutomationRepository repository =
            InMemoryAutomationRepository(automations: <Automation>[automation]);

        final Automation? result = await repository.findById(automation.id);

        expect(result, same(automation));
      });

      test('returns null for an unknown identifier', () async {
        final Automation existing = AutomationTestFactory.create(
          id: 'existing',
        );
        final InMemoryAutomationRepository repository =
            InMemoryAutomationRepository(automations: <Automation>[existing]);

        final Automation? result = await repository.findById(
          AutomationId('unknown'),
        );

        expect(result, isNull);
        expect(repository.length, 1);
      });

      test(
        'repeated lookups are deterministic and do not mutate state',
        () async {
          final Automation automation = AutomationTestFactory.create(
            id: 'stable',
          );
          final InMemoryAutomationRepository repository =
              InMemoryAutomationRepository(
                automations: <Automation>[automation],
              );

          final Automation? firstResult = await repository.findById(
            automation.id,
          );
          final Automation? secondResult = await repository.findById(
            automation.id,
          );

          expect(firstResult, same(automation));
          expect(secondResult, same(automation));
          expect(repository.length, 1);
          expect(repository.isNotEmpty, isTrue);
        },
      );
    });

    group('findAll', () {
      test('returns every persisted automation in order', () async {
        final Automation first = AutomationTestFactory.create(id: 'first');
        final Automation second = AutomationTestFactory.create(id: 'second');
        final Automation third = AutomationTestFactory.create(id: 'third');
        final InMemoryAutomationRepository repository =
            InMemoryAutomationRepository(
              automations: <Automation>[first, second, third],
            );

        final List<Automation> result = await repository.findAll();

        expect(result, hasLength(3));
        expect(result[0], same(first));
        expect(result[1], same(second));
        expect(result[2], same(third));
      });

      test('returns an unmodifiable collection', () async {
        final Automation persisted = AutomationTestFactory.create(
          id: 'persisted',
        );
        final Automation additional = AutomationTestFactory.create(
          id: 'additional',
        );
        final InMemoryAutomationRepository repository =
            InMemoryAutomationRepository(automations: <Automation>[persisted]);

        final List<Automation> result = await repository.findAll();

        expect(() => result.add(additional), throwsUnsupportedError);
        expect(() => result.remove(persisted), throwsUnsupportedError);
        expect(() => result.clear(), throwsUnsupportedError);

        expect(repository.length, 1);
        expect(await repository.findById(persisted.id), same(persisted));
      });

      test('returns a snapshot independent from future saves', () async {
        final Automation first = AutomationTestFactory.create(id: 'first');
        final Automation second = AutomationTestFactory.create(id: 'second');
        final InMemoryAutomationRepository repository =
            InMemoryAutomationRepository(automations: <Automation>[first]);

        final List<Automation> snapshot = await repository.findAll();

        await repository.save(second);

        expect(snapshot, hasLength(1));
        expect(snapshot.single, same(first));

        final List<Automation> current = await repository.findAll();

        expect(current, hasLength(2));
        expect(current[0], same(first));
        expect(current[1], same(second));
      });

      test('returns a snapshot independent from future replacements', () async {
        final Automation original = AutomationTestFactory.create(
          id: 'automation',
          name: 'Original',
          version: 1,
        );
        final Automation replacement = AutomationTestFactory.create(
          id: 'automation',
          name: 'Replacement',
          version: 2,
        );
        final InMemoryAutomationRepository repository =
            InMemoryAutomationRepository(automations: <Automation>[original]);

        final List<Automation> snapshot = await repository.findAll();

        await repository.save(replacement);

        expect(snapshot.single, same(original));
        expect((await repository.findAll()).single, same(replacement));
      });

      test('returns a new snapshot for each invocation', () async {
        final Automation automation = AutomationTestFactory.create(
          id: 'automation',
        );
        final InMemoryAutomationRepository repository =
            InMemoryAutomationRepository(automations: <Automation>[automation]);

        final List<Automation> firstResult = await repository.findAll();
        final List<Automation> secondResult = await repository.findAll();

        expect(firstResult, isNot(same(secondResult)));
        expect(firstResult.single, same(automation));
        expect(secondResult.single, same(automation));
      });
    });

    group('exists', () {
      test('returns true for a persisted automation', () async {
        final Automation automation = AutomationTestFactory.create(
          id: 'existing',
        );
        final InMemoryAutomationRepository repository =
            InMemoryAutomationRepository(automations: <Automation>[automation]);

        final bool result = await repository.exists(automation.id);

        expect(result, isTrue);
      });

      test('returns false for an unknown automation', () async {
        final Automation automation = AutomationTestFactory.create(
          id: 'existing',
        );
        final InMemoryAutomationRepository repository =
            InMemoryAutomationRepository(automations: <Automation>[automation]);

        final bool result = await repository.exists(AutomationId('unknown'));

        expect(result, isFalse);
      });

      test('reflects save and delete lifecycle changes', () async {
        final Automation automation = AutomationTestFactory.create(
          id: 'lifecycle',
        );
        final InMemoryAutomationRepository repository =
            InMemoryAutomationRepository();

        expect(await repository.exists(automation.id), isFalse);

        await repository.save(automation);

        expect(await repository.exists(automation.id), isTrue);

        await repository.delete(automation.id);

        expect(await repository.exists(automation.id), isFalse);
      });
    });

    group('delete', () {
      test('removes an existing automation and returns true', () async {
        final Automation automation = AutomationTestFactory.create(
          id: 'deletable',
        );
        final InMemoryAutomationRepository repository =
            InMemoryAutomationRepository(automations: <Automation>[automation]);

        final bool result = await repository.delete(automation.id);

        expect(result, isTrue);
        expect(repository.length, 0);
        expect(repository.isEmpty, isTrue);
        expect(repository.isNotEmpty, isFalse);
        expect(await repository.findById(automation.id), isNull);
        expect(await repository.exists(automation.id), isFalse);
      });

      test('returns false when the automation does not exist', () async {
        final Automation existing = AutomationTestFactory.create(
          id: 'existing',
        );
        final InMemoryAutomationRepository repository =
            InMemoryAutomationRepository(automations: <Automation>[existing]);

        final bool result = await repository.delete(AutomationId('unknown'));

        expect(result, isFalse);
        expect(repository.length, 1);
        expect(await repository.findById(existing.id), same(existing));
      });

      test('does not affect other persisted automations', () async {
        final Automation first = AutomationTestFactory.create(id: 'first');
        final Automation second = AutomationTestFactory.create(id: 'second');
        final Automation third = AutomationTestFactory.create(id: 'third');
        final InMemoryAutomationRepository repository =
            InMemoryAutomationRepository(
              automations: <Automation>[first, second, third],
            );

        await repository.delete(second.id);

        final List<Automation> remaining = await repository.findAll();

        expect(repository.length, 2);
        expect(remaining, hasLength(2));
        expect(remaining[0], same(first));
        expect(remaining[1], same(third));
        expect(await repository.findById(first.id), same(first));
        expect(await repository.findById(third.id), same(third));
      });

      test('can delete the same identifier repeatedly', () async {
        final Automation automation = AutomationTestFactory.create(
          id: 'deletable',
        );
        final InMemoryAutomationRepository repository =
            InMemoryAutomationRepository(automations: <Automation>[automation]);

        final bool firstDeletion = await repository.delete(automation.id);
        final bool secondDeletion = await repository.delete(automation.id);

        expect(firstDeletion, isTrue);
        expect(secondDeletion, isFalse);
        expect(repository.isEmpty, isTrue);
      });

      test('allows a deleted identifier to be persisted again', () async {
        final Automation original = AutomationTestFactory.create(
          id: 'reusable-id',
          name: 'Original',
        );
        final Automation replacement = AutomationTestFactory.create(
          id: 'reusable-id',
          name: 'Replacement',
        );
        final InMemoryAutomationRepository repository =
            InMemoryAutomationRepository(automations: <Automation>[original]);

        await repository.delete(original.id);
        await repository.save(replacement);

        expect(repository.length, 1);
        expect(await repository.findById(replacement.id), same(replacement));
      });
    });

    group('clear', () {
      test('removes every persisted automation', () async {
        final Automation first = AutomationTestFactory.create(id: 'first');
        final Automation second = AutomationTestFactory.create(id: 'second');
        final InMemoryAutomationRepository repository =
            InMemoryAutomationRepository(
              automations: <Automation>[first, second],
            );

        await repository.clear();

        expect(repository.length, 0);
        expect(repository.isEmpty, isTrue);
        expect(repository.isNotEmpty, isFalse);
        expect(await repository.findAll(), isEmpty);
        expect(await repository.findById(first.id), isNull);
        expect(await repository.findById(second.id), isNull);
        expect(await repository.exists(first.id), isFalse);
        expect(await repository.exists(second.id), isFalse);
      });

      test('can be called repeatedly', () async {
        final InMemoryAutomationRepository repository =
            InMemoryAutomationRepository(
              automations: <Automation>[
                AutomationTestFactory.create(id: 'automation'),
              ],
            );

        await repository.clear();
        await repository.clear();

        expect(repository.length, 0);
        expect(repository.isEmpty, isTrue);
        expect(await repository.findAll(), isEmpty);
      });

      test('allows persistence after clearing', () async {
        final Automation original = AutomationTestFactory.create(
          id: 'automation',
          name: 'Original',
        );
        final Automation replacement = AutomationTestFactory.create(
          id: 'replacement',
          name: 'Replacement',
        );
        final InMemoryAutomationRepository repository =
            InMemoryAutomationRepository(automations: <Automation>[original]);

        await repository.clear();
        await repository.save(replacement);

        expect(repository.length, 1);
        expect(repository.isNotEmpty, isTrue);
        expect(await repository.findById(replacement.id), same(replacement));
        expect(await repository.findById(original.id), isNull);
      });
    });
  });
}
