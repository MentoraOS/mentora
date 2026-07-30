import '../../workflow/workflow.dart';
import '../../workflow/workflow_context.dart';
import '../../workflow/workflow_result.dart';

import '../engine/meeting_engine.dart';
import '../models/meeting.dart';
import '../models/meeting_provider.dart';
import '../services/meeting_room_service.dart';
import '../services/meeting_token_service.dart';

class CreateMeetingWorkflow extends Workflow<Meeting> {
  final MeetingEngine engine;

  final MeetingRoomService roomService;
  final MeetingTokenService tokenService;

  final String meetingId;
  final String consultationId;
  final MeetingProvider provider;

  const CreateMeetingWorkflow({
    required this.engine,
    required this.roomService,
    required this.tokenService,
    required this.meetingId,
    required this.consultationId,
    this.provider = MeetingProvider.agora,
  });

  @override
  String get name => 'meeting.create';

  @override
  Future<WorkflowResult<Meeting>> execute(WorkflowContext context) async {
    final roomId = roomService.generateRoomId();

    final hostToken = tokenService.generateHostToken();

    final guestToken = tokenService.generateGuestToken();

    final meeting = Meeting(
      id: meetingId,
      consultationId: consultationId,
      roomId: roomId,
      hostToken: hostToken,
      guestToken: guestToken,
      provider: provider,
    );
    final result = await engine.create(meeting);

    if (!result.success || result.meeting == null) {
      return WorkflowResult.failure(
        message: result.message ?? 'Meeting creation failed',
      );
    }

    return WorkflowResult.success(
      data: result.meeting,
      message: 'Meeting created successfully',
    );
  }
}
