import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/consultation/models/consultation_status.dart';
import 'package:mentora/core/consultation/services/consultation_state_machine.dart';

void main() {
  group('Consultation State Machine', () {
    test('should allow draft to scheduled', () {
      const machine = ConsultationStateMachine();

      expect(
        machine.canTransition(
          from: ConsultationStatus.draft,
          to: ConsultationStatus.scheduled,
        ),
        isTrue,
      );
    });

    test('should deny draft to completed', () {
      const machine = ConsultationStateMachine();

      expect(
        machine.canTransition(
          from: ConsultationStatus.draft,
          to: ConsultationStatus.completed,
        ),
        isFalse,
      );
    });

    test('should allow inProgress to completed', () {
      const machine = ConsultationStateMachine();

      expect(
        machine.canTransition(
          from: ConsultationStatus.inProgress,
          to: ConsultationStatus.completed,
        ),
        isTrue,
      );
    });
  });
}
