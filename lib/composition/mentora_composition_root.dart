import 'package:firebase_core/firebase_core.dart';

import '../application/authentication/default_authentication_session.dart';
import '../application/booking/booking_confirmation_application_service.dart';
import '../application/booking/booking_creation_application_service.dart';
import '../application/booking/expert_booking_occupancy_application_service.dart';
import '../application/expert_availability/expert_availability_application_service.dart';
import '../application/expert_catalog/expert_catalog_application_service.dart';
import '../application/expert_timezone/expert_timezone_application_service.dart';
import '../application/favorites/favorite_experts_application_service.dart';
import '../application/notification/booking_notification_application_service.dart';
import '../application/payment/payment_collection_application_service.dart';
import '../application/profile/profile_application_service.dart';
import '../application/scheduling/selectable_occurrence_application_service.dart';
import '../application/startup/mentora_startup.dart';
import '../application/workspace/default_workspace_state.dart';
import '../domain/workspace/workspace_member_repository.dart';
import '../infrastructure/authentication/firebase_authentication_service.dart';
import '../infrastructure/booking/firestore_booking_confirmation_repository.dart';
import '../infrastructure/booking/firestore_booking_creation_repository.dart';
import '../infrastructure/booking/firestore_expert_booking_occupancy_repository.dart';
import '../infrastructure/scheduling/civil_occurrence_interpretation_adapter.dart';
import '../infrastructure/scheduling/civil_occurrence_materialization_adapter.dart';
import '../infrastructure/scheduling/launch_market_timezone_resolver.dart';
import '../infrastructure/firebase/firebase_dependencies.dart';
import '../infrastructure/expert_availability/firestore_expert_availability_repository.dart';
import '../infrastructure/expert_catalog/firestore_expert_catalog_repository.dart';
import '../infrastructure/expert_timezone/firestore_expert_timezone_repository.dart';
import '../infrastructure/favorites/firestore_favorite_experts_repository.dart';
import '../infrastructure/notification/simulated_notification_provider.dart';
import '../infrastructure/payment/simulated_payment_provider.dart';
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

    final expertAvailability = ExpertAvailabilityApplicationService(
      session: authenticationSession,
      repository: expertAvailabilityRepository,
    );

    final expertCatalog = ExpertCatalogApplicationService(
      repository: expertCatalogRepository,
    );

    // AD-022 Clarification A: expert-side explicit timezone declaration,
    // persisted on the Catalog document the funnel already reads.
    final expertTimezone = ExpertTimezoneApplicationService(
      session: authenticationSession,
      repository: FirestoreExpertTimezoneRepository(
        firestore: firebase.firestore,
      ),
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

    // AD-022 C3: Booking creation revalidates the structured selection (C2)
    // and snapshots the Scheduling-interpreted canonical occurrence.
    final bookingCreation = BookingCreationApplicationService(
      session: authenticationSession,
      repository: bookingCreationRepository,
      selectableOccurrences: selectableOccurrences,
      interpretation: const CivilOccurrenceInterpretationAdapter(
        resolver: timezoneResolver,
      ),
    );

    // Booking lifecycle notifications: best-effort, never a workflow
    // condition. The simulated provider is replaced by a real channel later.
    final bookingNotifications = BookingNotificationApplicationService(
      session: authenticationSession,
      provider: SimulatedNotificationProvider(),
    );

    // Product-facing Payment Provider boundary (AD-021 decision 12). The
    // simulated adapter is replaced by a real PSP adapter later; nothing
    // upstream changes.
    const paymentCollection = PaymentCollectionApplicationService(
      provider: SimulatedPaymentProvider(),
    );

    // AD-022 decision 12: Booking consumes the confirmed payment outcome
    // through its own boundary; Payment owns no reservation state.
    final bookingConfirmation = BookingConfirmationApplicationService(
      session: authenticationSession,
      repository: FirestoreBookingConfirmationRepository(
        firestore: firebase.firestore,
      ),
    );

    return MentoraDependencies(
      authenticationSession: authenticationSession,
      bookingConfirmation: bookingConfirmation,
      bookingCreation: bookingCreation,
      bookingNotifications: bookingNotifications,
      expertBookingOccupancy: expertBookingOccupancy,
      expertAvailability: expertAvailability,
      expertCatalog: expertCatalog,
      expertTimezone: expertTimezone,
      favoriteExperts: favoriteExperts,
      paymentCollection: paymentCollection,
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
