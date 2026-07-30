class Device {
  final String id;
  final String name;
  final String platform;
  final String osVersion;
  final String appVersion;
  final String? pushToken;
  final bool trusted;
  final DateTime lastActiveAt;

  const Device({
    required this.id,
    required this.name,
    required this.platform,
    required this.osVersion,
    required this.appVersion,
    this.pushToken,
    this.trusted = false,
    required this.lastActiveAt,
  });
}
