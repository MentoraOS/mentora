import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/core/automation/domain/automation.dart';
import 'package:mentora/core/automation/domain/automation_id.dart';
import 'package:mentora/core/automation/domain/automation_status.dart';
import 'package:mentora/core/automation/registry/automation_registry_exception.dart';
import 'package:mentora/core/automation/registry/in_memory_automation_registry.dart';

import 'automation_test_factory.dart';

void main() {
  group('InMemoryAutomationRegistry', () {
    group('initial state', () {
      test('starts empty', () {
        final InMemoryAutomationRegistry registry =
            InMemoryAutomationRegistry();

        expect(registry.length, 0);
        expect(registry.isEmpty, isTrue);
        expect(registry.isNotEmpty, isFalse);
        expect(registry.getAll(), isEmpty);
        expect(registry.getActive(), isEmpty);
      });

      test('accepts an empty initial collection', () {
        final InMemoryAutomationRegistry registry = InMemoryAutomationRegistry(
          automations: const <Automation>[],
        );

        expect(registry.length, 0);
        expect(registry.isEmpty, isTrue);
        expect(registry.getAll(), isEmpty);
      });

      test('returns null when trying to resolve an unknown automation', () {
        final InMemoryAutomationRegistry registry =
            InMemoryAutomationRegistry();
        final AutomationId unknownId = AutomationId('unknown');

        expect(registry.tryResolve(unknownId), isNull);
      });

      test('throws when resolving an unknown automation', () {
        final InMemoryAutomationRegistry registry =
            InMemoryAutomationRegistry();
        final AutomationId unknownId = AutomationId('unknown');

        expect(
          () => registry.resolve(unknownId),
          throwsA(
            isA<AutomationNotFoundException>()
                .having(
                  (AutomationNotFoundException exception) => exception.message,
                  'message',
                  'Automation "unknown" was not found.',
                )
                .having(
                  (AutomationNotFoundException exception) =>
                      exception.toString(),
                  'toString()',
                  'Automation "unknown" was not found.',
                ),
          ),
        );
      });

      test('does not contain an unknown automation', () {
        final InMemoryAutomationRegistry registry =
            InMemoryAutomationRegistry();

        expect(registry.contains(AutomationId('unknown')), isFalse);
      });
    });

    group('construction', () {
      test('registers initial automations in the supplied order', () {
        final Automation first = AutomationTestFactory.create(id: 'first');
        final Automation second = AutomationTestFactory.create(id: 'second');
        final Automation third = AutomationTestFactory.create(id: 'third');

        final InMemoryAutomationRegistry registry = InMemoryAutomationRegistry(
          automations: <Automation>[first, second, third],
        );

        final List<Automation> registered = registry.getAll();

        expect(registered, hasLength(3));
        expect(registered[0], same(first));
        expect(registered[1], same(second));
        expect(registered[2], same(third));
        expect(registry.length, 3);
        expect(registry.isEmpty, isFalse);
        expect(registry.isNotEmpty, isTrue);
      });

      test('rejects duplicate identifiers in the initial collection', () {
        final Automation first = AutomationTestFactory.create(
          id: 'duplicate',
          name: 'First automation',
        );
        final Automation duplicate = AutomationTestFactory.create(
          id: 'duplicate',
          name: 'Duplicate automation',
        );

        expect(
          () => InMemoryAutomationRegistry(
            automations: <Automation>[first, duplicate],
          ),
          throwsA(
            isA<AutomationAlreadyRegisteredException>().having(
              (AutomationAlreadyRegisteredException exception) =>
                  exception.message,
              'message',
              'Automation "duplicate" is already registered.',
            ),
          ),
        );
      });
    });

    group('registration', () {
      test('registers and resolves an automation', () {
        final InMemoryAutomationRegistry registry =
            InMemoryAutomationRegistry();
        final Automation automation = AutomationTestFactory.create(
          id: 'registered',
        );

        registry.register(automation);

        expect(registry.length, 1);
        expect(registry.isEmpty, isFalse);
        expect(registry.isNotEmpty, isTrue);
        expect(registry.contains(automation.id), isTrue);
        expect(registry.resolve(automation.id), same(automation));
        expect(registry.tryResolve(automation.id), same(automation));
      });

      test('registers multiple independent automations', () {
        final InMemoryAutomationRegistry registry =
            InMemoryAutomationRegistry();
        final Automation first = AutomationTestFactory.create(id: 'first');
        final Automation second = AutomationTestFactory.create(id: 'second');

        registry.register(first);
        registry.register(second);

        expect(registry.length, 2);
        expect(registry.resolve(first.id), same(first));
        expect(registry.resolve(second.id), same(second));
      });

      test('preserves registration order', () {
        final InMemoryAutomationRegistry registry =
            InMemoryAutomationRegistry();
        final Automation first = AutomationTestFactory.create(id: 'first');
        final Automation second = AutomationTestFactory.create(id: 'second');
        final Automation third = AutomationTestFactory.create(id: 'third');

        registry
          ..register(first)
          ..register(second)
          ..register(third);

        final List<Automation> registered = registry.getAll();

        expect(registered, hasLength(3));
        expect(registered[0], same(first));
        expect(registered[1], same(second));
        expect(registered[2], same(third));
      });

      test('rejects an already registered identifier', () {
        final InMemoryAutomationRegistry registry =
            InMemoryAutomationRegistry();
        final Automation original = AutomationTestFactory.create(
          id: 'duplicate',
          name: 'Original automation',
        );
        final Automation duplicate = AutomationTestFactory.create(
          id: 'duplicate',
          name: 'Duplicate automation',
        );

        registry.register(original);

        expect(
          () => registry.register(duplicate),
          throwsA(
            isA<AutomationAlreadyRegisteredException>()
                .having(
                  (AutomationAlreadyRegisteredException exception) =>
                      exception.message,
                  'message',
                  'Automation "duplicate" is already registered.',
                )
                .having(
                  (AutomationAlreadyRegisteredException exception) =>
                      exception.toString(),
                  'toString()',
                  'Automation "duplicate" is already registered.',
                ),
          ),
        );

        expect(registry.length, 1);
        expect(registry.resolve(original.id), same(original));
      });

      test('does not overwrite the original automation after a duplicate', () {
        final InMemoryAutomationRegistry registry =
            InMemoryAutomationRegistry();
        final Automation original = AutomationTestFactory.create(
          id: 'shared-id',
          name: 'Original',
          version: 1,
        );
        final Automation replacement = AutomationTestFactory.create(
          id: 'shared-id',
          name: 'Replacement',
          version: 2,
        );

        registry.register(original);

        expect(
          () => registry.register(replacement),
          throwsA(isA<AutomationAlreadyRegisteredException>()),
        );

        expect(registry.resolve(original.id), same(original));
        expect(registry.resolve(original.id), isNot(same(replacement)));
      });
    });

    group('bulk registration', () {
      test('registerAll registers every automation in order', () {
        final InMemoryAutomationRegistry registry =
            InMemoryAutomationRegistry();
        final Automation first = AutomationTestFactory.create(id: 'first');
        final Automation second = AutomationTestFactory.create(id: 'second');
        final Automation third = AutomationTestFactory.create(id: 'third');

        registry.registerAll(<Automation>[first, second, third]);

        final List<Automation> registered = registry.getAll();

        expect(registered, hasLength(3));
        expect(registered[0], same(first));
        expect(registered[1], same(second));
        expect(registered[2], same(third));
      });

      test('registerAll does nothing for an empty collection', () {
        final Automation existing = AutomationTestFactory.create(
          id: 'existing',
        );
        final InMemoryAutomationRegistry registry = InMemoryAutomationRegistry(
          automations: <Automation>[existing],
        );

        registry.registerAll(const <Automation>[]);

        expect(registry.length, 1);
        expect(registry.resolve(existing.id), same(existing));
      });

      test('registerAll rejects a duplicate already in the registry', () {
        final Automation existing = AutomationTestFactory.create(
          id: 'existing',
        );
        final Automation newAutomation = AutomationTestFactory.create(
          id: 'new',
        );
        final Automation duplicate = AutomationTestFactory.create(
          id: 'existing',
          name: 'Duplicate existing automation',
        );
        final InMemoryAutomationRegistry registry = InMemoryAutomationRegistry(
          automations: <Automation>[existing],
        );

        expect(
          () => registry.registerAll(<Automation>[newAutomation, duplicate]),
          throwsA(
            isA<AutomationAlreadyRegisteredException>().having(
              (AutomationAlreadyRegisteredException exception) =>
                  exception.message,
              'message',
              'Automation "existing" is already registered.',
            ),
          ),
        );

        expect(registry.length, 1);
        expect(registry.resolve(existing.id), same(existing));
        expect(registry.contains(newAutomation.id), isFalse);
      });

      test('registerAll rejects duplicate identifiers within the batch', () {
        final InMemoryAutomationRegistry registry =
            InMemoryAutomationRegistry();
        final Automation first = AutomationTestFactory.create(id: 'first');
        final Automation duplicateOne = AutomationTestFactory.create(
          id: 'duplicate',
          name: 'Duplicate one',
        );
        final Automation duplicateTwo = AutomationTestFactory.create(
          id: 'duplicate',
          name: 'Duplicate two',
        );

        expect(
          () => registry.registerAll(<Automation>[
            first,
            duplicateOne,
            duplicateTwo,
          ]),
          throwsA(
            isA<AutomationAlreadyRegisteredException>().having(
              (AutomationAlreadyRegisteredException exception) =>
                  exception.message,
              'message',
              'Automation "duplicate" is already registered.',
            ),
          ),
        );

        expect(registry.isEmpty, isTrue);
        expect(registry.length, 0);
        expect(registry.contains(first.id), isFalse);
        expect(registry.contains(duplicateOne.id), isFalse);
      });

      test('registerAll is atomic when validation fails', () {
        final Automation existing = AutomationTestFactory.create(
          id: 'existing',
        );
        final Automation firstCandidate = AutomationTestFactory.create(
          id: 'first-candidate',
        );
        final Automation duplicate = AutomationTestFactory.create(
          id: 'existing',
          name: 'Duplicate',
        );
        final Automation lastCandidate = AutomationTestFactory.create(
          id: 'last-candidate',
        );
        final InMemoryAutomationRegistry registry = InMemoryAutomationRegistry(
          automations: <Automation>[existing],
        );

        expect(
          () => registry.registerAll(<Automation>[
            firstCandidate,
            duplicate,
            lastCandidate,
          ]),
          throwsA(isA<AutomationAlreadyRegisteredException>()),
        );

        expect(registry.length, 1);
        expect(registry.getAll(), hasLength(1));
        expect(registry.resolve(existing.id), same(existing));
        expect(registry.contains(firstCandidate.id), isFalse);
        expect(registry.contains(lastCandidate.id), isFalse);
      });
    });

    group('lookup', () {
      test('resolve returns the registered instance', () {
        final Automation automation = AutomationTestFactory.create(
          id: 'resolvable',
        );
        final InMemoryAutomationRegistry registry = InMemoryAutomationRegistry(
          automations: <Automation>[automation],
        );

        final Automation resolved = registry.resolve(automation.id);

        expect(resolved, same(automation));
      });

      test('tryResolve returns the registered instance', () {
        final Automation automation = AutomationTestFactory.create(
          id: 'resolvable',
        );
        final InMemoryAutomationRegistry registry = InMemoryAutomationRegistry(
          automations: <Automation>[automation],
        );

        final Automation? resolved = registry.tryResolve(automation.id);

        expect(resolved, same(automation));
      });

      test('repeated lookups are deterministic and do not mutate state', () {
        final Automation automation = AutomationTestFactory.create(
          id: 'stable',
        );
        final InMemoryAutomationRegistry registry = InMemoryAutomationRegistry(
          automations: <Automation>[automation],
        );

        final Automation firstResolution = registry.resolve(automation.id);
        final Automation secondResolution = registry.resolve(automation.id);
        final Automation? nullableResolution = registry.tryResolve(
          automation.id,
        );

        expect(firstResolution, same(automation));
        expect(secondResolution, same(automation));
        expect(nullableResolution, same(automation));
        expect(registry.length, 1);
        expect(registry.isNotEmpty, isTrue);
      });

      test('contains distinguishes known and unknown identifiers', () {
        final Automation automation = AutomationTestFactory.create(id: 'known');
        final InMemoryAutomationRegistry registry = InMemoryAutomationRegistry(
          automations: <Automation>[automation],
        );

        expect(registry.contains(automation.id), isTrue);
        expect(registry.contains(AutomationId('unknown')), isFalse);
      });
    });

    group('active automations', () {
      test('returns only active automations', () {
        final Automation draft = AutomationTestFactory.create(
          id: 'draft',
          status: AutomationStatus.draft,
        );
        final Automation active = AutomationTestFactory.create(
          id: 'active',
          status: AutomationStatus.active,
        );
        final Automation paused = AutomationTestFactory.create(
          id: 'paused',
          status: AutomationStatus.paused,
        );
        final Automation archived = AutomationTestFactory.create(
          id: 'archived',
          status: AutomationStatus.archived,
        );
        final InMemoryAutomationRegistry registry = InMemoryAutomationRegistry(
          automations: <Automation>[draft, active, paused, archived],
        );

        final List<Automation> activeAutomations = registry.getActive();

        expect(activeAutomations, hasLength(1));
        expect(activeAutomations.single, same(active));
      });

      test('preserves registration order among active automations', () {
        final Automation firstActive = AutomationTestFactory.create(
          id: 'first-active',
          status: AutomationStatus.active,
        );
        final Automation paused = AutomationTestFactory.create(
          id: 'paused',
          status: AutomationStatus.paused,
        );
        final Automation secondActive = AutomationTestFactory.create(
          id: 'second-active',
          status: AutomationStatus.active,
        );
        final InMemoryAutomationRegistry registry = InMemoryAutomationRegistry(
          automations: <Automation>[firstActive, paused, secondActive],
        );

        final List<Automation> activeAutomations = registry.getActive();

        expect(activeAutomations, hasLength(2));
        expect(activeAutomations[0], same(firstActive));
        expect(activeAutomations[1], same(secondActive));
      });

      test('returns an empty list when no automation is active', () {
        final InMemoryAutomationRegistry registry = InMemoryAutomationRegistry(
          automations: <Automation>[
            AutomationTestFactory.create(
              id: 'draft',
              status: AutomationStatus.draft,
            ),
            AutomationTestFactory.create(
              id: 'paused',
              status: AutomationStatus.paused,
            ),
            AutomationTestFactory.create(
              id: 'archived',
              status: AutomationStatus.archived,
            ),
          ],
        );

        expect(registry.getActive(), isEmpty);
      });
    });

    group('unregistration', () {
      test('unregister removes a known automation and returns true', () {
        final Automation automation = AutomationTestFactory.create(
          id: 'removable',
        );
        final InMemoryAutomationRegistry registry = InMemoryAutomationRegistry(
          automations: <Automation>[automation],
        );

        final bool removed = registry.unregister(automation.id);

        expect(removed, isTrue);
        expect(registry.contains(automation.id), isFalse);
        expect(registry.tryResolve(automation.id), isNull);
        expect(registry.length, 0);
        expect(registry.isEmpty, isTrue);
      });

      test('unregister returns false for an unknown automation', () {
        final Automation existing = AutomationTestFactory.create(
          id: 'existing',
        );
        final InMemoryAutomationRegistry registry = InMemoryAutomationRegistry(
          automations: <Automation>[existing],
        );

        final bool removed = registry.unregister(AutomationId('unknown'));

        expect(removed, isFalse);
        expect(registry.length, 1);
        expect(registry.resolve(existing.id), same(existing));
      });

      test('unregister does not affect other automations', () {
        final Automation first = AutomationTestFactory.create(id: 'first');
        final Automation second = AutomationTestFactory.create(id: 'second');
        final Automation third = AutomationTestFactory.create(id: 'third');
        final InMemoryAutomationRegistry registry = InMemoryAutomationRegistry(
          automations: <Automation>[first, second, third],
        );

        registry.unregister(second.id);

        final List<Automation> remaining = registry.getAll();

        expect(remaining, hasLength(2));
        expect(remaining[0], same(first));
        expect(remaining[1], same(third));
        expect(registry.resolve(first.id), same(first));
        expect(registry.resolve(third.id), same(third));
      });

      test('resolve throws after an automation is unregistered', () {
        final Automation automation = AutomationTestFactory.create(
          id: 'removed',
        );
        final InMemoryAutomationRegistry registry = InMemoryAutomationRegistry(
          automations: <Automation>[automation],
        );

        registry.unregister(automation.id);

        expect(
          () => registry.resolve(automation.id),
          throwsA(isA<AutomationNotFoundException>()),
        );
      });
    });

    group('immutability', () {
      test('getAll returns an unmodifiable list', () {
        final Automation registered = AutomationTestFactory.create(
          id: 'registered',
        );
        final Automation additional = AutomationTestFactory.create(
          id: 'additional',
        );
        final InMemoryAutomationRegistry registry = InMemoryAutomationRegistry(
          automations: <Automation>[registered],
        );

        final List<Automation> automations = registry.getAll();

        expect(() => automations.add(additional), throwsUnsupportedError);
        expect(() => automations.remove(registered), throwsUnsupportedError);
        expect(() => automations.clear(), throwsUnsupportedError);

        expect(registry.length, 1);
        expect(registry.resolve(registered.id), same(registered));
      });

      test('getActive returns an unmodifiable list', () {
        final Automation active = AutomationTestFactory.create(
          id: 'active',
          status: AutomationStatus.active,
        );
        final Automation additional = AutomationTestFactory.create(
          id: 'additional',
          status: AutomationStatus.active,
        );
        final InMemoryAutomationRegistry registry = InMemoryAutomationRegistry(
          automations: <Automation>[active],
        );

        final List<Automation> activeAutomations = registry.getActive();

        expect(() => activeAutomations.add(additional), throwsUnsupportedError);
        expect(() => activeAutomations.remove(active), throwsUnsupportedError);

        expect(registry.length, 1);
        expect(registry.resolve(active.id), same(active));
      });

      test('getAll returns a snapshot independent from future changes', () {
        final Automation first = AutomationTestFactory.create(id: 'first');
        final Automation second = AutomationTestFactory.create(id: 'second');
        final InMemoryAutomationRegistry registry = InMemoryAutomationRegistry(
          automations: <Automation>[first],
        );

        final List<Automation> snapshot = registry.getAll();

        registry.register(second);

        expect(snapshot, hasLength(1));
        expect(snapshot.single, same(first));
        expect(registry.getAll(), hasLength(2));
      });

      test('getActive returns a snapshot independent from future changes', () {
        final Automation first = AutomationTestFactory.create(
          id: 'first',
          status: AutomationStatus.active,
        );
        final Automation second = AutomationTestFactory.create(
          id: 'second',
          status: AutomationStatus.active,
        );
        final InMemoryAutomationRegistry registry = InMemoryAutomationRegistry(
          automations: <Automation>[first],
        );

        final List<Automation> snapshot = registry.getActive();

        registry.register(second);

        expect(snapshot, hasLength(1));
        expect(snapshot.single, same(first));
        expect(registry.getActive(), hasLength(2));
      });
    });

    group('clear', () {
      test('removes every registered automation', () {
        final Automation first = AutomationTestFactory.create(id: 'first');
        final Automation second = AutomationTestFactory.create(id: 'second');
        final InMemoryAutomationRegistry registry = InMemoryAutomationRegistry(
          automations: <Automation>[first, second],
        );

        registry.clear();

        expect(registry.length, 0);
        expect(registry.isEmpty, isTrue);
        expect(registry.isNotEmpty, isFalse);
        expect(registry.getAll(), isEmpty);
        expect(registry.getActive(), isEmpty);
        expect(registry.tryResolve(first.id), isNull);
        expect(registry.tryResolve(second.id), isNull);
      });

      test('can be called repeatedly', () {
        final InMemoryAutomationRegistry registry = InMemoryAutomationRegistry(
          automations: <Automation>[
            AutomationTestFactory.create(id: 'automation'),
          ],
        );

        registry
          ..clear()
          ..clear();

        expect(registry.isEmpty, isTrue);
        expect(registry.length, 0);
      });

      test('allows identifiers to be registered again after clearing', () {
        final Automation original = AutomationTestFactory.create(
          id: 'reusable-id',
          name: 'Original',
        );
        final Automation replacement = AutomationTestFactory.create(
          id: 'reusable-id',
          name: 'Replacement',
        );
        final InMemoryAutomationRegistry registry = InMemoryAutomationRegistry(
          automations: <Automation>[original],
        );

        registry
          ..clear()
          ..register(replacement);

        expect(registry.length, 1);
        expect(registry.resolve(replacement.id), same(replacement));
      });
    });
  });
}
