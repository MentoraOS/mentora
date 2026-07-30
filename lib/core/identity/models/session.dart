import 'identity.dart';

class Session {
  final String id;

  final Identity identity;

  final DateTime startedAt;

  final DateTime expiresAt;

  final DateTime lastActivityAt;

  final bool active;

  const Session({
    required this.id,
    required this.identity,
    required this.startedAt,
    required this.expiresAt,
    required this.lastActivityAt,
    this.active = true,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get isValid => active && !isExpired;
}
