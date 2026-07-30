import '../models/organization.dart';

class OrganizationRepository {
  OrganizationRepository._();

  static final List<Organization> organizations = [
    Organization(
      id: 'mentora_demo',

      name: 'Mentora Technologies',

      legalName: 'Mentora Technologies SARL',

      logoUrl: '',

      industry: 'Technology',

      country: 'Mali',

      city: 'Bamako',

      timezone: 'Africa/Bamako',

      currency: 'XOF',

      emailDomain: 'mentora.ai',

      employeeCount: 126,

      verified: true,

      createdAt: DateTime(2025),
    ),
  ];

  static Organization? findById(String id) {
    try {
      return organizations.firstWhere((organization) => organization.id == id);
    } catch (_) {
      return null;
    }
  }
}
