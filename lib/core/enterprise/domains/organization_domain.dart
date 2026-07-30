import '../engine/atlas_engine.dart';
import '../models/organization.dart';

class OrganizationDomain {
  final AtlasEngine engine;

  const OrganizationDomain(this.engine);

  Future<void> create({
    required Organization organization,
    required String userId,
  }) async {
    await engine.organizationCreated(
      organization: organization,
      userId: userId,
    );
  }

  Future<void> update({
    required Organization organization,
    required String userId,
  }) async {
    await engine.updateOrganization(organization: organization, userId: userId);
  }
}
