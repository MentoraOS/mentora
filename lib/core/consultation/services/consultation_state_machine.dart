import '../models/consultation_status.dart';

class ConsultationStateMachine {
  const ConsultationStateMachine();

  bool canTransition({
    required ConsultationStatus from,
    required ConsultationStatus to,
  }) {
    return allowedTransitions[from]?.contains(to) ?? false;
  }

  List<ConsultationStatus> nextStates(ConsultationStatus current) {
    return allowedTransitions[current] ?? [];
  }

  static const Map<ConsultationStatus, List<ConsultationStatus>>
  allowedTransitions = {
    ConsultationStatus.draft: [
      ConsultationStatus.scheduled,
      ConsultationStatus.cancelled,
    ],

    ConsultationStatus.scheduled: [
      ConsultationStatus.waitingExpert,
      ConsultationStatus.waitingClient,
      ConsultationStatus.cancelled,
      ConsultationStatus.expired,
    ],

    ConsultationStatus.waitingExpert: [
      ConsultationStatus.waitingClient,
      ConsultationStatus.ready,
      ConsultationStatus.cancelled,
    ],

    ConsultationStatus.waitingClient: [
      ConsultationStatus.waitingExpert,
      ConsultationStatus.ready,
      ConsultationStatus.cancelled,
    ],

    ConsultationStatus.ready: [
      ConsultationStatus.inProgress,
      ConsultationStatus.cancelled,
    ],

    ConsultationStatus.inProgress: [
      ConsultationStatus.paused,
      ConsultationStatus.completed,
    ],

    ConsultationStatus.paused: [
      ConsultationStatus.inProgress,
      ConsultationStatus.completed,
      ConsultationStatus.cancelled,
    ],

    ConsultationStatus.completed: [],

    ConsultationStatus.cancelled: [],

    ConsultationStatus.expired: [],
  };
}
