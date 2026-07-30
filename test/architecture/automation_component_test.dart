import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/core/automation/domain/automation_action.dart';
import 'package:mentora/core/automation/domain/automation_condition.dart';
import 'package:mentora/core/automation/domain/automation_trigger.dart';

void main() {
  group('AutomationAction', () {
    test('normalizes its type', () {
      final AutomationAction action = AutomationAction(type: '  send-email  ');

      expect(action.type, 'send-email');
    });

    test('rejects an empty type', () {
      expect(() => AutomationAction(type: '   '), throwsArgumentError);
    });

    test('protects configuration from mutation', () {
      final Map<String, Object?> configuration = <String, Object?>{
        'recipient': 'client@example.com',
      };

      final AutomationAction action = AutomationAction(
        type: 'send-email',
        configuration: configuration,
      );

      expect(
        () => action.configuration['subject'] = 'Hello',
        throwsUnsupportedError,
      );
    });

    test('copyWith preserves and replaces values', () {
      final AutomationAction action = AutomationAction(type: 'send-email');

      final AutomationAction updated = action.copyWith(continueOnFailure: true);

      expect(updated.type, 'send-email');
      expect(updated.continueOnFailure, isTrue);
    });
  });

  group('AutomationCondition', () {
    test('normalizes its type', () {
      final AutomationCondition condition = AutomationCondition(
        type: '  payment-succeeded  ',
      );

      expect(condition.type, 'payment-succeeded');
    });

    test('rejects an empty type', () {
      expect(() => AutomationCondition(type: ''), throwsArgumentError);
    });

    test('protects configuration from mutation', () {
      final AutomationCondition condition = AutomationCondition(
        type: 'amount-threshold',
        configuration: <String, Object?>{'minimum': 1000},
      );

      expect(
        () => condition.configuration['minimum'] = 2000,
        throwsUnsupportedError,
      );
    });

    test('copyWith can negate the condition', () {
      final AutomationCondition condition = AutomationCondition(
        type: 'payment-succeeded',
      );

      final AutomationCondition updated = condition.copyWith(negated: true);

      expect(updated.negated, isTrue);
      expect(updated.type, condition.type);
    });
  });

  group('AutomationTrigger', () {
    test('normalizes its type', () {
      final AutomationTrigger trigger = AutomationTrigger(
        type: '  consultation-completed  ',
      );

      expect(trigger.type, 'consultation-completed');
    });

    test('rejects an empty type', () {
      expect(() => AutomationTrigger(type: '   '), throwsArgumentError);
    });

    test('protects configuration from mutation', () {
      final AutomationTrigger trigger = AutomationTrigger(
        type: 'scheduled',
        configuration: <String, Object?>{'cron': '0 8 * * *'},
      );

      expect(
        () => trigger.configuration['cron'] = '0 9 * * *',
        throwsUnsupportedError,
      );
    });
  });
}
