import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/meeting/domains/meeting_domain.dart';
import 'package:mentora/core/meeting/models/meeting.dart';
import 'package:mentora/core/meeting/models/meeting_provider.dart';
import 'package:mentora/core/meeting/models/meeting_status.dart';
import 'package:mentora/core/meeting/repositories/memory_meeting_repository.dart';

void main() {
  group('Meeting Domain', () {
    test('should move meeting from waiting to live', () async {
      final repository = MemoryMeetingRepository();

      final domain = MeetingDomain(repository: repository);

      final meeting = Meeting(
        id: 'meeting_002',
        consultationId: 'consultation_002',
        roomId: 'room_002',
        hostToken: 'host_token',
        guestToken: 'guest_token',
        provider: MeetingProvider.agora,
      );

      await domain.create(meeting);

      final waitingResult = await domain.start(
        Meeting(
          id: meeting.id,
          consultationId: meeting.consultationId,
          roomId: meeting.roomId,
          hostToken: meeting.hostToken,
          guestToken: meeting.guestToken,
          provider: meeting.provider,
          status: MeetingStatus.waiting,
        ),
      );

      expect(waitingResult.success, isTrue);
      expect(waitingResult.meeting?.status, MeetingStatus.live);
    });

    test('should reject created to ended transition', () async {
      final repository = MemoryMeetingRepository();

      final domain = MeetingDomain(repository: repository);

      final meeting = Meeting(
        id: 'meeting_invalid_001',
        consultationId: 'consultation_invalid_001',
        roomId: 'room_invalid_001',
        hostToken: 'host_token',
        guestToken: 'guest_token',
        provider: MeetingProvider.agora,
      );

      await domain.create(meeting);

      final result = await domain.end(meeting);

      expect(result.success, isFalse);
    });

    test('should start meeting', () async {
      final repository = MemoryMeetingRepository();

      final domain = MeetingDomain(repository: repository);

      final meeting = Meeting(
        id: 'meeting_002',
        consultationId: 'consultation_002',
        roomId: 'room_002',
        hostToken: 'host_token',
        guestToken: 'guest_token',
        provider: MeetingProvider.agora,
        status: MeetingStatus.waiting,
      );

      await domain.create(meeting);

      final result = await domain.start(meeting);

      expect(result.success, isTrue);
      expect(result.meeting?.status, MeetingStatus.live);
    });

    test('should pause meeting', () async {
      final repository = MemoryMeetingRepository();

      final domain = MeetingDomain(repository: repository);

      final meeting = Meeting(
        id: 'meeting_003',
        consultationId: 'consultation_003',
        roomId: 'room_003',
        hostToken: 'host_token',
        guestToken: 'guest_token',
        provider: MeetingProvider.agora,
        status: MeetingStatus.live,
      );

      await domain.create(meeting);

      final result = await domain.pause(meeting);

      expect(result.success, isTrue);
      expect(result.meeting?.status, MeetingStatus.paused);
    });

    test('should end meeting', () async {
      final repository = MemoryMeetingRepository();

      final domain = MeetingDomain(repository: repository);

      final meeting = Meeting(
        id: 'meeting_004',
        consultationId: 'consultation_004',
        roomId: 'room_004',
        hostToken: 'host_token',
        guestToken: 'guest_token',
        provider: MeetingProvider.agora,
        status: MeetingStatus.live,
      );

      await domain.create(meeting);

      final result = await domain.end(meeting);

      expect(result.success, isTrue);
      expect(result.meeting?.status, MeetingStatus.ended);
    });

    test('should cancel meeting', () async {
      final repository = MemoryMeetingRepository();

      final domain = MeetingDomain(repository: repository);

      final meeting = Meeting(
        id: 'meeting_005',
        consultationId: 'consultation_005',
        roomId: 'room_005',
        hostToken: 'host_token',
        guestToken: 'guest_token',
        provider: MeetingProvider.agora,
      );

      await domain.create(meeting);

      final result = await domain.cancel(meeting);

      expect(result.success, isTrue);
      expect(result.meeting?.status, MeetingStatus.cancelled);
    });
  });
}
