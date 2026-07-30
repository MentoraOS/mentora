import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/core/automation/domain/automation_id.dart';

void main() {
  group('AutomationId', () {
    test('normalizes surrounding whitespace', () {
      final AutomationId id = AutomationId('  automation-001  ');

      expect(id.value, 'automation-001');
      expect(id.toString(), 'automation-001');
    });

    test('rejects an empty identifier', () {
      expect(() => AutomationId('   '), throwsArgumentError);
    });

    test('supports value equality', () {
      final AutomationId first = AutomationId('automation-001');
      final AutomationId second = AutomationId('automation-001');

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('distinguishes different identifiers', () {
      expect(
        AutomationId('automation-001'),
        isNot(AutomationId('automation-002')),
      );
    });
  });
}
