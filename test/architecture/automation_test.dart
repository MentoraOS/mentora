import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/core/automation/domain/automation.dart';
import 'package:mentora/core/automation/domain/automation_action.dart';
import 'package:mentora/core/automation/domain/automation_status.dart';

import 'automation_test_factory.dart';

void main() {
  group('Automation', () {
    test('creates a valid active automation', () {
      final Automation automation = AutomationTestFactory.create();

      expect(automation.id.value, 'automation-test');
      expect(automation.name, 'Test automation');
      expect(automation.version, 1);
      expect(automation.isActive, isTrue);
      expect(automation.actions, hasLength(1));
    });

    test('normalizes the automation name', () {
      final Automation automation = AutomationTestFactory.create(
        name: '  Payment notification  ',
      );

      expect(automation.name, 'Payment notification');
    });

    test('rejects an empty name', () {
      expect(
        () => AutomationTestFactory.create(name: '   '),
        throwsArgumentError,
      );
    });

    test('rejects a version below one', () {
      expect(
        () => AutomationTestFactory.create(version: 0),
        throwsArgumentError,
      );
    });

    test('rejects an update date before creation', () {
      final DateTime createdAt = DateTime.utc(2026, 1, 2);

      expect(
        () => AutomationTestFactory.create(
          createdAt: createdAt,
          updatedAt: createdAt.subtract(const Duration(seconds: 1)),
        ),
        throwsArgumentError,
      );
    });

    test('rejects an active automation without actions', () {
      expect(
        () => AutomationTestFactory.create(
          status: AutomationStatus.active,
          actions: const <AutomationAction>[],
        ),
        throwsArgumentError,
      );
    });

    test('allows a draft automation without actions', () {
      final Automation automation = AutomationTestFactory.create(
        status: AutomationStatus.draft,
        actions: const <AutomationAction>[],
      );

      expect(automation.isDraft, isTrue);
      expect(automation.actions, isEmpty);
    });

    test('protects actions from mutation', () {
      final Automation automation = AutomationTestFactory.create();

      expect(
        () => automation.actions.add(AutomationTestFactory.action()),
        throwsUnsupportedError,
      );
    });

    test('protects metadata from mutation', () {
      final Automation automation = AutomationTestFactory.create(
        metadata: <String, Object?>{'source': 'test'},
      );

      expect(
        () => automation.metadata['source'] = 'updated',
        throwsUnsupportedError,
      );
    });

    test('copyWith preserves identity and creation date', () {
      final Automation automation = AutomationTestFactory.create();

      final DateTime newUpdatedAt = automation.updatedAt.add(
        const Duration(hours: 1),
      );

      final Automation updated = automation.copyWith(
        name: 'Updated automation',
        version: 2,
        status: AutomationStatus.paused,
        updatedAt: newUpdatedAt,
      );

      expect(updated.id, automation.id);
      expect(updated.createdAt, automation.createdAt);
      expect(updated.name, 'Updated automation');
      expect(updated.version, 2);
      expect(updated.isPaused, isTrue);
      expect(updated.updatedAt, newUpdatedAt);
    });
  });
}
