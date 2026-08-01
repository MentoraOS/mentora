import '../application/authentication/authentication_session.dart';
import '../application/booking/booking_cancellation_application_service.dart';
import '../application/booking/booking_confirmation_application_service.dart';
import '../application/booking/booking_dashboard_application_service.dart';
import '../application/booking/booking_creation_application_service.dart';
import '../application/booking/booking_reschedule_application_service.dart';
import '../application/booking/expert_booking_occupancy_application_service.dart';
import '../application/consultation_brief/consultation_brief_application_service.dart';
import '../application/consultation_notes/consultation_private_notes_application_service.dart';
import '../application/expert_availability/expert_availability_application_service.dart';
import '../application/expert_catalog/expert_catalog_application_service.dart';
import '../application/expert_timezone/expert_timezone_application_service.dart';
import '../application/favorites/favorite_experts_application_service.dart';
import '../application/notification/booking_notification_application_service.dart';
import '../application/payment/payment_collection_application_service.dart';
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
    required this.bookingCancellation,
    required this.bookingConfirmation,
    required this.bookingCreation,
    required this.bookingDashboard,
    required this.bookingNotifications,
    required this.bookingReschedule,
    required this.consultationBrief,
    required this.consultationPrivateNotes,
    required this.expertBookingOccupancy,
    required this.expertAvailability,
    required this.expertCatalog,
    required this.expertTimezone,
    required this.favoriteExperts,
    required this.paymentCollection,
    required this.profile,
    required this.selectableOccurrences,
    required this.startup,
    required this.timezoneResolver,
    required this.workspaceState,
    required this.workspaceMemberRepository,
    required this.workspaceRepository,
  });

  final AuthenticationSession authenticationSession;

  /// Booking-owned cancellation of a client reservation.
  final BookingCancellationApplicationService bookingCancellation;

  /// AD-022 decision 12: Booking-owned confirmation of a paid reservation.
  final BookingConfirmationApplicationService bookingConfirmation;

  final BookingCreationApplicationService bookingCreation;

  /// Live read projection of the user's reservations for the dashboard.
  final BookingDashboardApplicationService bookingDashboard;

  /// Best-effort booking lifecycle notifications; never a workflow condition.
  final BookingNotificationApplicationService bookingNotifications;

  /// Booking-owned reschedule through the C2/C3 temporal path.
  final BookingRescheduleApplicationService bookingReschedule;

  /// The client's consultation brief: a plain persistent snapshot.
  final ConsultationBriefApplicationService consultationBrief;

  /// Expert-only private consultation notes.
  final ConsultationPrivateNotesApplicationService consultationPrivateNotes;

  final ExpertBookingOccupancyApplicationService expertBookingOccupancy;
  final ExpertAvailabilityApplicationService expertAvailability;
  final ExpertCatalogApplicationService expertCatalog;

  /// AD-022 Clarification A: expert-side explicit timezone declaration.
  final ExpertTimezoneApplicationService expertTimezone;

  final FavoriteExpertsApplicationService favoriteExperts;

  /// Product-facing Payment Provider boundary (AD-021 decision 12).
  final PaymentCollectionApplicationService paymentCollection;

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
