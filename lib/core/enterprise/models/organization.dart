class Organization {
  final String id;

  final String name;

  final String legalName;

  final String logoUrl;

  final String industry;

  final String country;

  final String city;

  final String timezone;

  final String currency;

  final String emailDomain;

  final int employeeCount;

  final bool verified;

  final DateTime createdAt;

  const Organization({
    required this.id,
    required this.name,
    required this.legalName,
    required this.logoUrl,
    required this.industry,
    required this.country,
    required this.city,
    required this.timezone,
    required this.currency,
    required this.emailDomain,
    this.employeeCount = 0,
    this.verified = false,
    required this.createdAt,
  });
}
