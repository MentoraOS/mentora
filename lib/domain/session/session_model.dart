class SessionModel {
  final String id;
  final String email;
  final String name;
  final String photoUrl;
  final String countryCode;
  final String currency;
  final String language;
  final List<String> roles;
  final List<String> permissions;
  final bool isActive;
  final bool isVerified;
  final bool isPremium;

  const SessionModel({
    required this.id,
    required this.email,
    required this.name,
    required this.photoUrl,
    required this.countryCode,
    required this.currency,
    required this.language,
    required this.roles,
    required this.permissions,
    required this.isActive,
    required this.isVerified,
    required this.isPremium,
  });

  factory SessionModel.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return SessionModel(
      id: id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      countryCode: data['countryCode'] ?? 'ML',
      currency: data['currency'] ?? 'XOF',
      language: data['language'] ?? 'fr',
      roles: List<String>.from(data['roles'] ?? ['client']),
      permissions: List<String>.from(data['permissions'] ?? []),
      isActive: data['isActive'] ?? true,
      isVerified: data['isVerified'] ?? false,
      isPremium: data['isPremium'] ?? false,
    );
  }
}
