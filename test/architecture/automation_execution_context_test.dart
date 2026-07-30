import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/core/automation/domain/automation.dart';
import 'package:mentora/core/automation/domain/automation_action.dart';
import 'package:mentora/core/automation/domain/automation_id.dart';
import 'package:mentora/core/automation/domain/automation_status.dart';
import 'package:mentora/core/automation/domain/automation_trigger.dart';
import 'package:mentora/core/automation/engine/automation_execution_context.dart';

void main() {
  group('AutomationExecutionContext', () {
    late Automation automation;
    late DateTime startedAt;

    setUp(() {
      startedAt = DateTime.utc(2026, 7, 24, 18, 30);

      automation = Automation(
        id: AutomationId('automation-booking-reminder'),
        name: 'Booking reminder',
        version: 1,
        status: AutomationStatus.active,
        trigger: AutomationTrigger(type: 'booking.created'),
        actions: <AutomationAction>[
          AutomationAction(type: 'notification.send'),
        ],
        createdAt: DateTime.utc(2026, 7, 1),
        updatedAt: DateTime.utc(2026, 7, 1),
      );
    });

    test('creates a valid execution context', () {
      final context = AutomationExecutionContext(
        executionId: 'execution-001',
        automation: automation,
        startedAt: startedAt,
      );

      expect(context.executionId, 'execution-001');
      expect(context.automation, same(automation));
      expect(context.startedAt, startedAt);
      expect(context.attempt, 1);
      expect(context.input, isEmpty);
      expect(context.metadata, isEmpty);
    });

    test('trims the execution identifier', () {
      final context = AutomationExecutionContext(
        executionId: '  execution-001  ',
        automation: automation,
        startedAt: startedAt,
      );

      expect(context.executionId, 'execution-001');
    });

    test('throws when the execution identifier is empty', () {
      expect(
        () => AutomationExecutionContext(
          executionId: '',
          automation: automation,
          startedAt: startedAt,
        ),
        throwsA(
          isA<ArgumentError>()
              .having((error) => error.name, 'name', 'executionId')
              .having((error) => error.invalidValue, 'invalidValue', ''),
        ),
      );
    });

    test('throws when the execution identifier contains only whitespace', () {
      expect(
        () => AutomationExecutionContext(
          executionId: '   ',
          automation: automation,
          startedAt: startedAt,
        ),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.name,
            'name',
            'executionId',
          ),
        ),
      );
    });

    test('throws when attempt is lower than one', () {
      expect(
        () => AutomationExecutionContext(
          executionId: 'execution-001',
          automation: automation,
          startedAt: startedAt,
          attempt: 0,
        ),
        throwsA(
          isA<ArgumentError>()
              .having((error) => error.name, 'name', 'attempt')
              .having((error) => error.invalidValue, 'invalidValue', 0),
        ),
      );
    });

    test('accepts an attempt greater than one', () {
      final context = AutomationExecutionContext(
        executionId: 'execution-001',
        automation: automation,
        startedAt: startedAt,
        attempt: 3,
      );

      expect(context.attempt, 3);
    });

    test('converts startedAt to UTC', () {
      final localStartedAt = DateTime(2026, 7, 24, 18, 30);

      final context = AutomationExecutionContext(
        executionId: 'execution-001',
        automation: automation,
        startedAt: localStartedAt,
      );

      expect(context.startedAt.isUtc, isTrue);
      expect(context.startedAt, localStartedAt.toUtc());
    });

    test('stores input as an unmodifiable map', () {
      final input = <String, Object?>{
        'bookingId': 'booking-001',
        'customerId': 'customer-001',
      };

      final context = AutomationExecutionContext(
        executionId: 'execution-001',
        automation: automation,
        startedAt: startedAt,
        input: input,
      );

      expect(
        () => context.input['bookingId'] = 'booking-002',
        throwsUnsupportedError,
      );
    });

    test('stores metadata as an unmodifiable map', () {
      final metadata = <String, Object?>{
        'source': 'mobile',
        'correlationId': 'correlation-001',
      };

      final context = AutomationExecutionContext(
        executionId: 'execution-001',
        automation: automation,
        startedAt: startedAt,
        metadata: metadata,
      );

      expect(() => context.metadata['source'] = 'web', throwsUnsupportedError);
    });

    test('creates defensive copies of input and metadata', () {
      final input = <String, Object?>{'bookingId': 'booking-001'};

      final metadata = <String, Object?>{'source': 'mobile'};

      final context = AutomationExecutionContext(
        executionId: 'execution-001',
        automation: automation,
        startedAt: startedAt,
        input: input,
        metadata: metadata,
      );

      input['bookingId'] = 'booking-002';
      metadata['source'] = 'web';

      expect(context.input['bookingId'], 'booking-001');
      expect(context.metadata['source'], 'mobile');
    });

    group('copyWith', () {
      test('returns a new context preserving unchanged values', () {
        final original = AutomationExecutionContext(
          executionId: 'execution-001',
          automation: automation,
          startedAt: startedAt,
          attempt: 2,
          input: const <String, Object?>{'bookingId': 'booking-001'},
          metadata: const <String, Object?>{'source': 'mobile'},
        );

        final copy = original.copyWith();

        expect(copy, isNot(same(original)));
        expect(copy.executionId, original.executionId);
        expect(copy.automation, same(original.automation));
        expect(copy.startedAt, original.startedAt);
        expect(copy.attempt, original.attempt);
        expect(copy.input, original.input);
        expect(copy.metadata, original.metadata);
      });

      test('replaces only the attempt', () {
        final original = AutomationExecutionContext(
          executionId: 'execution-001',
          automation: automation,
          startedAt: startedAt,
          attempt: 1,
          input: const <String, Object?>{'bookingId': 'booking-001'},
          metadata: const <String, Object?>{'source': 'mobile'},
        );

        final copy = original.copyWith(attempt: 2);

        expect(copy.attempt, 2);
        expect(copy.executionId, original.executionId);
        expect(copy.automation, same(original.automation));
        expect(copy.startedAt, original.startedAt);
        expect(copy.input, original.input);
        expect(copy.metadata, original.metadata);
      });

      test('replaces only the input', () {
        final original = AutomationExecutionContext(
          executionId: 'execution-001',
          automation: automation,
          startedAt: startedAt,
          input: const <String, Object?>{'bookingId': 'booking-001'},
        );

        final copy = original.copyWith(
          input: const <String, Object?>{
            'bookingId': 'booking-002',
            'customerId': 'customer-001',
          },
        );

        expect(copy.input, <String, Object?>{
          'bookingId': 'booking-002',
          'customerId': 'customer-001',
        });

        expect(copy.executionId, original.executionId);
        expect(copy.automation, same(original.automation));
        expect(copy.startedAt, original.startedAt);
        expect(copy.attempt, original.attempt);
        expect(copy.metadata, original.metadata);
      });

      test('replaces only the metadata', () {
        final original = AutomationExecutionContext(
          executionId: 'execution-001',
          automation: automation,
          startedAt: startedAt,
          metadata: const <String, Object?>{'source': 'mobile'},
        );

        final copy = original.copyWith(
          metadata: const <String, Object?>{
            'source': 'web',
            'correlationId': 'correlation-002',
          },
        );

        expect(copy.metadata, <String, Object?>{
          'source': 'web',
          'correlationId': 'correlation-002',
        });

        expect(copy.executionId, original.executionId);
        expect(copy.automation, same(original.automation));
        expect(copy.startedAt, original.startedAt);
        expect(copy.attempt, original.attempt);
        expect(copy.input, original.input);
      });

      test('replaces attempt, input and metadata together', () {
        final original = AutomationExecutionContext(
          executionId: 'execution-001',
          automation: automation,
          startedAt: startedAt,
        );

        final copy = original.copyWith(
          attempt: 4,
          input: const <String, Object?>{'bookingId': 'booking-004'},
          metadata: const <String, Object?>{'source': 'scheduler'},
        );

        expect(copy.attempt, 4);
        expect(copy.input['bookingId'], 'booking-004');
        expect(copy.metadata['source'], 'scheduler');

        expect(copy.executionId, original.executionId);
        expect(copy.automation, same(original.automation));
        expect(copy.startedAt, original.startedAt);
      });

      test('keeps copied input and metadata unmodifiable', () {
        final original = AutomationExecutionContext(
          executionId: 'execution-001',
          automation: automation,
          startedAt: startedAt,
        );

        final copy = original.copyWith(
          input: const <String, Object?>{'bookingId': 'booking-001'},
          metadata: const <String, Object?>{'source': 'mobile'},
        );

        expect(
          () => copy.input['bookingId'] = 'booking-002',
          throwsUnsupportedError,
        );

        expect(() => copy.metadata['source'] = 'web', throwsUnsupportedError);
      });

      test('validates the replacement attempt', () {
        final original = AutomationExecutionContext(
          executionId: 'execution-001',
          automation: automation,
          startedAt: startedAt,
        );

        expect(
          () => original.copyWith(attempt: 0),
          throwsA(
            isA<ArgumentError>().having(
              (error) => error.name,
              'name',
              'attempt',
            ),
          ),
        );
      });
    });
  });
}
