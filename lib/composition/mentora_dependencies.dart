import '../application/authentication/authentication_session.dart';
import '../application/booking/booking_creation_application_service.dart';
import '../application/booking/expert_booking_occupancy_application_service.dart';
import '../application/expert_availability/expert_availability_application_service.dart';
import '../application/expert_catalog/expert_catalog_application_service.dart';
import '../application/expert_timezone/expert_timezone_application_service.dart';
import '../application/favorites/favorite_experts_application_service.dart';
import '../application/profile/profile_application_service.dart';
import '../application/scheduling/selectable_occurrence_application_service.dart';
import '../application/startup/mentora_startup.dart';
import '../application/workspace/workspace_state.dart';

import '../core/scheduling/scheduling.dart';
import '../domain/workspace/workspace_member_repository.dart';
import '../domain/workspace/workspace_repository.dart';

final class MentoraDependencies {
  const MentoraDependencies({
    required this.authenticationSession,
    required this.bookingCreation,
    required this.expertBookingOccupancy,
    required this.expertAvailability,
    required this.expertCatalog,
    required this.expertTimezone,
    required this.favoriteExperts,
    required this.profile,
    required this.selectableOccurrences,
    required this.startup,
    required this.timezoneResolver,
    required this.workspaceState,
    required this.workspaceMemberRepository,
    required this.workspaceRepository,
  });

  final AuthenticationSession authenticationSession;
  final BookingCreationApplicationService bookingCreation;
  final ExpertBookingOccupancyApplicationService expertBookingOccupancy;
  final ExpertAvailabilityApplicationService expertAvailability;
  final ExpertCatalogApplicationService expertCatalog;

  /// AD-022 Clarification A: expert-side explicit timezone declaration.
  final ExpertTimezoneApplicationService expertTimezone;

  final FavoriteExpertsApplicationService favoriteExperts;
  final ProfileApplicationService profile;

  /// AD-022 Clarification C: Application-owned selectable occurrence
  /// materialization and revalidation.
  final SelectableOccurrenceApplicationService selectableOccurrences;

  final MentoraStartup startup;

  /// Scheduling-owned timezone interpretation port (AD-020 Clarification).
  ///
  /// Exposed as the port, never as the concrete implementation. It is not
  /// provided to Presentation: Presentation must not interpret timezones.
  final TimezoneResolver timezoneResolver;

  final WorkspaceState workspaceState;
  final WorkspaceMemberRepository workspaceMemberRepository;
  final WorkspaceRepository workspaceRepository;
}
