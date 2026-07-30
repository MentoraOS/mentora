import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/meeting/domains/meeting_domain.dart';
import 'package:mentora/core/meeting/engine/meeting_engine.dart';
import 'package:mentora/core/meeting/models/meeting.dart';
import 'package:mentora/core/meeting/models/meeting_provider.dart';
import 'package:mentora/core/meeting/repositories/memory_meeting_repository.dart';
import 'package:mentora/core/meeting/workflows/create_meeting_workflow.dart';

import 'package:mentora/core/workflow/workflow_context.dart';
import 'package:mentora/core/workflow/workflow_state.dart';

import 'package:mentora/core/meeting/services/meeting_room_service.dart';
import 'package:mentora/core/meeting/services/meeting_token_service.dart';

void main() {
  group('Create Meeting Workflow', () {
    test('should create meeting successfully', () async {
      final repository = MemoryMeetingRepository();

      final domain = MeetingDomain(repository: repository);

      final engine = MeetingEngine(domain: domain);

      final meeting = Meeting(
        id: 'meeting_workflow_001',
        consultationId: 'consultation_001',
        roomId: 'room_001',
        hostToken: 'host_token',
        guestToken: 'guest_token',
        provider: MeetingProvider.agora,
      );

      final workflow = CreateMeetingWorkflow(
        engine: engine,
        roomService: const MeetingRoomService(),
        tokenService: const MeetingTokenService(),
        meetingId: 'meeting_workflow_001',
        consultationId: 'consultation_001',
      );

      final result = await workflow.execute(
        const WorkflowContext(
          userId: 'client_001',
          workspaceId: 'workspace_001',
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(result.state, WorkflowState.completed);
      expect(result.data?.id, 'meeting_workflow_001');
      expect(result.data?.consultationId, 'consultation_001');
      expect(result.data?.roomId.isNotEmpty, isTrue);
      expect(result.data?.hostToken.isNotEmpty, isTrue);
      expect(result.data?.guestToken.isNotEmpty, isTrue);
    });
  });
}
