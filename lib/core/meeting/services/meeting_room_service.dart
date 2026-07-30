import 'dart:math';

class MeetingRoomService {
  const MeetingRoomService();

  String generateRoomId() {
    final random = Random.secure();

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final suffix = random.nextInt(999999);

    return 'room_${timestamp}_$suffix';
  }
}
