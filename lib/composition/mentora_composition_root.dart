import 'package:firebase_core/firebase_core.dart';

import '../application/authentication/default_authentication_session.dart';
import '../application/booking/booking_creation_application_service.dart';
import '../application/booking/expert_booking_occupancy_application_service.dart';
import '../application/expert_availability/expert_availability_application_service.dart';
import '../application/expert_catalog/expert_catalog_application_service.dart';
import '../application/favorites/favorite_experts_application_service.dart';
import '../application/profile/profile_application_service.dart';
import '../application/scheduling/selectable_occurrence_application_service.dart';
import '../application/startup/mentora_startup.dart';
import '../application/workspace/default_workspace_state.dart';
import '../domain/workspace/workspace_member_repository.dart';
import '../infrastructure/authentication/firebase_authentication_service.dart';
import '../infrastructure/booking/firestore_booking_creation_repository.dart';
import '../infrastructure/booking/firestore_expert_booking_occupancy_repository.dart';
import '../infrastructure/scheduling/civil_occurrence_materialization_adapter.dart';
import '../infrastructure/scheduling/launch_market_timezone_resolver.dart';
import '../infrastructure/firebase/firebase_dependencies.dart';
import '../infrastructure/expert_availability/firestore_expert_availability_repository.dart';
import '../infrastructure/expert_catalog/firestore_expert_catalog_repository.dart';
import '../infrastructure/favorites/firestore_favorite_experts_repository.dart';
import '../infrastructure/profile/firestore_profile_repository.dart';
import 'mentora_dependencies.dart';

import '../infrastructure/session/firebase_session_repository.dart';
import '../infrastructure/workspace/firebase_workspace_member_repository.dart';
import '../infrastructure/workspace/firebase_workspace_repository.dart';
import '../infrastructure/workspace/identity_workspace_state_projection.dart';
import '../infrastructure/authentication/identity_authentication_session_projection.dart';

final class MentoraCompositionRoot {
  MentoraCompositionRoot._();

  static Future<MentoraDependencies> production() async {
    await Firebase.initializeApp();

    final firebase = FirebaseDependencies.production();

    final authenticationService = FirebaseAuthenticationService(
      auth: firebase.auth,
      firestore: firebase.firestore,
    );

    final sessionRepository = FirebaseSessionRepository(
      auth: firebase.auth,
      firestore: firebase.firestore,
    );

    final workspaceRepository = FirebaseWorkspaceRepository(
      firestore: firebase.firestore,
    );

    final WorkspaceMemberRepository workspaceMemberRepository =
        FirebaseWorkspaceMemberRepository(firestore: firebase.firestore);

    final workspaceState = DefaultWorkspaceState(
      repository: workspaceRepository,
      projection: const IdentityWorkspaceStateProjection(),
    );

    final authenticationSession = DefaultAuthenticationSession(
      authenticationService: authenticationService,
      sessionRepository: sessionRepository,
      workspaceState: workspaceState,
      projection: const IdentityAuthenticationSessionProjection(),
    );

    final profileRepository = FirestoreProfileRepository(
      firestore: firebase.firestore,
    );

    final expertCatalogRepository = FirestoreExpertCatalogRepository(
      firestore: firebase.firestore,
    );

    final expertAvailabilityRepository = FirestoreExpertAvailabilityRepository(
      firestore: firebase.firestore,
    );

    final expertBookingOccupancyRepository =
        FirestoreExpertBookingOccupancyRepository(
          firestore: firebase.firestore,
        );

    final expertBookingOccupancy = ExpertBookingOccupancyApplicationService(
      repository: expertBookingOccupancyRepository,
    );

    final bookingCreationRepository = FirestoreBookingCreationRepository(
      firestore: firebase.firestore,
    );

    final bookingCreation = BookingCreationApplicationService(
      session: authenticationSession,
      repository: bookingCreationRepository,
    );

    final expertAvailability = ExpertAvailabilityApplicationService(
      session: authenticationSession,
      repository: expertAvailabilityRepository,
    );

    final expertCatalog = ExpertCatalogApplicationService(
      repository: expertCatalogRepository,
    );

    final favoriteExpertsRepository = FirestoreFavoriteExpertsRepository(
      firestore: firebase.firestore,
    );

    final favoriteExperts = FavoriteExpertsApplicationService(
      session: authenticationSession,
      repository: favoriteExpertsRepository,
    );

    final profile = ProfileApplicationService(
      session: authenticationSession,
      repository: profileRepository,
    );

    final startup = MentoraStartup(session: authenticationSession);

    // AD-022 Clarification C decision 7: Application-owned materialization
    // and revalidation of selectable civil occurrences, built on the
    // authoritative Catalog lookup and the Scheduling-owned materialization
    // behind its Application port.
    final selectableOccurrences = SelectableOccurrenceApplicationService(
      expertCatalog: expertCatalog,
      materialization: const CivilOccurrenceMaterializationAdapter(),
    );

    // Scheduling-owned timezone interpretation. The concrete resolver is
    // constructed here and exposed only through its port.
    const timezoneResolver = LaunchMarketTimezoneResolver();

    return MentoraDependencies(
      authenticationSession: authenticationSession,
      bookingCreation: bookingCreation,
      expertBookingOccupancy: expertBookingOccupancy,
      expertAvailability: expertAvailability,
      expertCatalog: expertCatalog,
      favoriteExperts: favoriteExperts,
      profile: profile,
      selectableOccurrences: selectableOccurrences,
      startup: startup,
      timezoneResolver: timezoneResolver,
      workspaceState: workspaceState,
      workspaceMemberRepository: workspaceMemberRepository,
      workspaceRepository: workspaceRepository,
    );
  }
}
