import 'dart:math';

class MeetingTokenService {
  const MeetingTokenService();

  String generateHostToken() {
    return _generateToken('host');
  }

  String generateGuestToken() {
    return _generateToken('guest');
  }

  String _generateToken(String prefix) {
    final random = Random.secure();

    final buffer = StringBuffer(prefix);

    for (int i = 0; i < 32; i++) {
      buffer.write(random.nextInt(16).toRadixString(16));
    }

    return buffer.toString();
  }
}
