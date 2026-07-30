import '../application/authentication/authentication_session.dart';
import '../application/booking/expert_booking_occupancy_application_service.dart';
import '../application/expert_availability/expert_availability_application_service.dart';
import '../application/expert_catalog/expert_catalog_application_service.dart';
import '../application/favorites/favorite_experts_application_service.dart';
import '../application/profile/profile_application_service.dart';
import '../application/startup/mentora_startup.dart';
import '../application/workspace/workspace_state.dart';

import '../domain/workspace/workspace_member_repository.dart';
import '../domain/workspace/workspace_repository.dart';

final class MentoraDependencies {
  const MentoraDependencies({
    required this.authenticationSession,
    required this.expertBookingOccupancy,
    required this.expertAvailability,
    required this.expertCatalog,
    required this.favoriteExperts,
    required this.profile,
    required this.startup,
    required this.workspaceState,
    required this.workspaceMemberRepository,
    required this.workspaceRepository,
  });

  final AuthenticationSession authenticationSession;
  final ExpertBookingOccupancyApplicationService expertBookingOccupancy;
  final ExpertAvailabilityApplicationService expertAvailability;
  final ExpertCatalogApplicationService expertCatalog;
  final FavoriteExpertsApplicationService favoriteExperts;
  final ProfileApplicationService profile;
  final MentoraStartup startup;
  final WorkspaceState workspaceState;
  final WorkspaceMemberRepository workspaceMemberRepository;
  final WorkspaceRepository workspaceRepository;
}
