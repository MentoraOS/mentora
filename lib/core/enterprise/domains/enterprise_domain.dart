import '../engine/atlas_engine.dart';
import '../models/organization.dart';

class EnterpriseDomain {
  final AtlasEngine engine;

  const EnterpriseDomain(this.engine);

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
    await engine.organizationUpdated(
      organization: organization,
      userId: userId,
    );
  }

  Future<void> suspend({
    required Organization organization,
    required String userId,
  }) async {
    await engine.organizationSuspended(
      organization: organization,
      userId: userId,
    );
  }

  Future<void> archive({
    required Organization organization,
    required String userId,
  }) async {
    await engine.organizationArchived(
      organization: organization,
      userId: userId,
    );
  }
}
