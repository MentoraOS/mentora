import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../application/ai_gateway/ai_gateway_application_service.dart';
import '../application/assistant/consultation_assistant_application_service.dart';
import '../domain/ai_gateway/ai_provider.dart';
import '../application/authentication/default_authentication_session.dart';
import '../application/booking/booking_cancellation_application_service.dart';
import '../application/booking/booking_confirmation_application_service.dart';
import '../application/booking/booking_dashboard_application_service.dart';
import '../application/booking/booking_creation_application_service.dart';
import '../application/booking/booking_reschedule_application_service.dart';
import '../application/booking/consultation_completion_application_service.dart';
import '../application/booking/expert_booking_occupancy_application_service.dart';
import '../application/consultation_brief/consultation_brief_application_service.dart';
import '../application/consultation_documents/consultation_document_application_service.dart';
import '../application/consultation_memory/consultation_memory_application_service.dart';
import '../application/consultation_notes/consultation_private_notes_application_service.dart';
import '../application/consultation_summary/consultation_summary_application_service.dart';
import '../application/conversation/conversation_application_service.dart';
import '../application/expert_availability/expert_availability_application_service.dart';
import '../application/expert_availability_exception/expert_availability_exception_application_service.dart';
import '../application/expert_catalog/expert_catalog_application_service.dart';
import '../application/expert_timezone/expert_timezone_application_service.dart';
import '../application/favorites/favorite_experts_application_service.dart';
import '../application/notification/booking_notification_application_service.dart';
import '../application/payment/payment_collection_application_service.dart';
import '../application/profile/profile_application_service.dart';
import '../application/review/review_application_service.dart';
import '../application/scheduling/selectable_occurrence_application_service.dart';
import '../application/startup/mentora_startup.dart';
import '../application/transcript/realtime_transcript_application_service.dart';
import '../application/translation/realtime_translation_application_service.dart';
import '../application/video_session/video_session_application_service.dart';
import '../application/workspace/default_workspace_state.dart';
import '../domain/workspace/workspace_member_repository.dart';
import '../infrastructure/ai_gateway/deepgram_adapter.dart';
import '../infrastructure/ai_gateway/gemini_adapter.dart';
import '../infrastructure/ai_gateway/openai_ai_provider.dart';
import '../infrastructure/ai_gateway/openai_assistant_adapter.dart';
import '../infrastructure/ai_gateway/simulated_ai_provider.dart';
import '../infrastructure/authentication/firebase_authentication_service.dart';
import '../infrastructure/booking/firestore_booking_cancellation_repository.dart';
import '../infrastructure/booking/firestore_booking_confirmation_repository.dart';
import '../infrastructure/booking/firestore_booking_creation_repository.dart';
import '../infrastructure/booking/firestore_consultation_completion_repository.dart';
import '../infrastructure/booking/firestore_booking_overview_repository.dart';
import '../infrastructure/consultation_brief/firestore_consultation_brief_repository.dart';
import '../infrastructure/consultation_documents/firebase_consultation_document_repository.dart';
import '../infrastructure/consultation_memory/firestore_memory_repository.dart';
import '../infrastructure/consultation_notes/firestore_consultation_private_notes_repository.dart';
import '../infrastructure/consultation_summary/firestore_summary_repository.dart';
import '../infrastructure/consultation_summary/gateway_ai_summary_provider.dart';
import '../infrastructure/conversation/firestore_conversation_repository.dart';
import '../infrastructure/booking/firestore_booking_reschedule_repository.dart';
import '../infrastructure/booking/firestore_expert_booking_occupancy_repository.dart';
import '../infrastructure/scheduling/civil_occurrence_interpretation_adapter.dart';
import '../infrastructure/scheduling/civil_occurrence_materialization_adapter.dart';
import '../infrastructure/scheduling/launch_market_timezone_resolver.dart';
import '../infrastructure/video_session/livekit_cloud_adapter.dart';
import '../infrastructure/video_session/livekit_room_adapter.dart';
import '../infrastructure/firebase/firebase_dependencies.dart';
import '../infrastructure/expert_availability/firestore_expert_availability_repository.dart';
import '../infrastructure/expert_availability_exception/firestore_expert_availability_exception_repository.dart';
import '../infrastructure/expert_catalog/firestore_expert_catalog_repository.dart';
import '../infrastructure/expert_timezone/firestore_expert_timezone_repository.dart';
import '../infrastructure/favorites/firestore_favorite_experts_repository.dart';
import '../infrastructure/notification/simulated_notification_provider.dart';
import '../infrastructure/payment/simulated_payment_provider.dart';
import '../infrastructure/assistant/ai_assistant_provider.dart';
import '../infrastructure/transcript/ai_transcript_provider.dart';
import '../infrastructure/translation/ai_translation_provider.dart';
import '../infrastructure/profile/firestore_profile_repository.dart';
import '../infrastructure/review/firestore_consultation_review_repository.dart';
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

    // Expert unavailability windows: dedicated collection, applied as an
    // additive civil-date filter by the booking funnel.
    final availabilityExceptionRepository =
        FirestoreExpertAvailabilityExceptionRepository(
          firestore: firebase.firestore,
        );

    final availabilityExceptions =
        ExpertAvailabilityExceptionApplicationService(
          session: authenticationSession,
          repository: availabilityExceptionRepository,
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
      availabilityExceptions: availabilityExceptionRepository,
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

    // Consultation memory foundation: one memory per reservation holding
    // durable business facts only — never any engine output (ARC-MEM01).
    final consultationMemory = ConsultationMemoryApplicationService(
      session: authenticationSession,
      repository: FirestoreMemoryRepository(firestore: firebase.firestore),
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
      memory: consultationMemory,
      repository: FirestoreBookingConfirmationRepository(
        firestore: firebase.firestore,
      ),
    );

    // Booking owns cancellation; Payment never decides it. Refund, slot
    // release and rescheduling remain separate future contracts.
    final bookingCancellation = BookingCancellationApplicationService(
      session: authenticationSession,
      memory: consultationMemory,
      repository: FirestoreBookingCancellationRepository(
        firestore: firebase.firestore,
      ),
    );

    // Reschedule reuses the C2/C3 temporal path with the reservation's
    // snapshotted duration; conflict exclusion stays a future contract.
    final bookingReschedule = BookingRescheduleApplicationService(
      session: authenticationSession,
      memory: consultationMemory,
      repository: FirestoreBookingRescheduleRepository(
        firestore: firebase.firestore,
      ),
      expertCatalog: expertCatalog,
      materialization: const CivilOccurrenceMaterializationAdapter(),
      interpretation: const CivilOccurrenceInterpretationAdapter(
        resolver: timezoneResolver,
      ),
      availabilityExceptions: availabilityExceptionRepository,
    );

    // Booking-owned completion: a confirmed/paid consultation officially
    // becomes completed; every other reservation fact is preserved.
    final consultationCompletion = ConsultationCompletionApplicationService(
      session: authenticationSession,
      memory: consultationMemory,
      repository: FirestoreConsultationCompletionRepository(
        firestore: firebase.firestore,
      ),
    );

    // Consultation brief: a plain persistent snapshot keyed by booking.
    final consultationBrief = ConsultationBriefApplicationService(
      session: authenticationSession,
      memory: consultationMemory,
      repository: FirestoreConsultationBriefRepository(
        firestore: firebase.firestore,
      ),
    );

    // Expert-only private consultation notes: plain write/read snapshot.
    final consultationPrivateNotes = ConsultationPrivateNotesApplicationService(
      session: authenticationSession,
      memory: consultationMemory,
      repository: FirestoreConsultationPrivateNotesRepository(
        firestore: firebase.firestore,
      ),
    );

    // Shared consultation documents: upload, list, open — participants only.
    final consultationDocuments = ConsultationDocumentApplicationService(
      session: authenticationSession,
      memory: consultationMemory,
      repository: FirebaseConsultationDocumentRepository(
        firestore: firebase.firestore,
        storage: FirebaseStorage.instance,
      ),
    );

    // Video sessions: LiveKit Cloud exists only in Infrastructure. The
    // session adapter resolves rooms/identities and credentials (fake token
    // provider until the real token backend); the room adapter runs the
    // real RTC connection. Agora's legacy path is untouched.
    final videoSessions = VideoSessionApplicationService(
      session: authenticationSession,
      provider: const LiveKitCloudAdapter(),
    );

    const liveConsultationRooms = LiveKitRoomProvider();

    // AI Gateway: the single doorway every intelligence capability must
    // pass through. Requests route BY TASK; every deployment value of the
    // OpenAI engine is injected from the environment — never hard-coded.
    final aiGateway = AIGatewayApplicationService(
      session: authenticationSession,
      provider: const SimulatedAIProvider(),
      taskProviders: const {
        AITask.summary: OpenAIProvider(
          configuration: OpenAIConfiguration(
            apiKey: String.fromEnvironment('MENTORA_OPENAI_API_KEY'),
            endpoint: String.fromEnvironment(
              'MENTORA_OPENAI_ENDPOINT',
              defaultValue: 'https://api.openai.com/v1/chat/completions',
            ),
            model: String.fromEnvironment(
              'MENTORA_OPENAI_MODEL',
              defaultValue: 'gpt-4o-mini',
            ),
          ),
        ),
        AITask.transcription: DeepgramAdapter(
          configuration: DeepgramConfiguration(
            apiKey: String.fromEnvironment('MENTORA_DEEPGRAM_API_KEY'),
            endpoint: String.fromEnvironment(
              'MENTORA_DEEPGRAM_ENDPOINT',
              defaultValue: 'https://api.deepgram.com/v1/listen',
            ),
            model: String.fromEnvironment(
              'MENTORA_DEEPGRAM_MODEL',
              defaultValue: 'nova-2',
            ),
            language: String.fromEnvironment(
              'MENTORA_DEEPGRAM_LANGUAGE',
              defaultValue: 'fr',
            ),
          ),
        ),
        AITask.translation: GeminiAdapter(
          configuration: GeminiConfiguration(
            apiKey: String.fromEnvironment('MENTORA_GEMINI_API_KEY'),
            endpoint: String.fromEnvironment(
              'MENTORA_GEMINI_ENDPOINT',
              defaultValue:
                  'https://generativelanguage.googleapis.com/v1beta/models',
            ),
            model: String.fromEnvironment(
              'MENTORA_GEMINI_MODEL',
              defaultValue: 'gemini-1.5-flash',
            ),
          ),
        ),
        AITask.assistant: OpenAIAssistantAdapter(
          configuration: OpenAIConfiguration(
            apiKey: String.fromEnvironment('MENTORA_OPENAI_API_KEY'),
            endpoint: String.fromEnvironment(
              'MENTORA_OPENAI_ENDPOINT',
              defaultValue: 'https://api.openai.com/v1/chat/completions',
            ),
            model: String.fromEnvironment(
              'MENTORA_OPENAI_ASSISTANT_MODEL',
              defaultValue: 'gpt-4o-mini',
            ),
          ),
        ),
      },
    );

    // The official summary chain: memory -> summary service -> gateway
    // (task SUMMARY) -> engine adapter. The prompt lives in the summary
    // Infrastructure provider; no other layer knows the engine.
    final consultationSummaries = ConsultationSummaryApplicationService(
      session: authenticationSession,
      memory: consultationMemory,
      provider: GatewayAISummaryProvider(gateway: aiGateway),
      repository: FirestoreSummaryRepository(firestore: firebase.firestore),
    );

    // Real-time transcription: the LiveKit audio bridge feeds the
    // application service, whose provider routes every piece of audio
    // through the gateway to the engine registered for the task. The
    // transcript stays a living stream — no persistence here.
    final transcripts = RealtimeTranscriptApplicationService(
      session: authenticationSession,
      provider: AITranscriptProvider(gateway: aiGateway),
    );

    // Real-time translation: a living projection of the transcript flux,
    // routed through the gateway to the engine registered for the task.
    // The transcript stays the single truth; languages are injected per
    // session. No persistence here.
    final translations = RealtimeTranslationApplicationService(
      session: authenticationSession,
      provider: AITranslationProvider(gateway: aiGateway),
    );

    // Consultation copilot: reads ONLY the memory, proposes only —
    // never decides, never acts, never persists. Routed through the
    // gateway to the engine registered for the assistant task.
    final consultationAssistant = ConsultationAssistantApplicationService(
      session: authenticationSession,
      memory: consultationMemory,
      provider: AIAssistantProvider(gateway: aiGateway),
    );

    // Consultation reviews: one review per completed reservation, plain
    // chronological reads — no ranking, no averages.
    final reviews = ReviewApplicationService(
      session: authenticationSession,
      memory: consultationMemory,
      repository: FirestoreConsultationReviewRepository(
        firestore: firebase.firestore,
      ),
    );

    // Real-time consultation chat: one conversation per reservation,
    // Firestore streams only, the communication foundation for the future
    // intelligence layers.
    final conversations = ConversationApplicationService(
      session: authenticationSession,
      memory: consultationMemory,
      repository: FirestoreConversationRepository(
        firestore: firebase.firestore,
      ),
    );

    // Dashboard read projection: live stream of the user's reservations.
    final bookingDashboard = BookingDashboardApplicationService(
      session: authenticationSession,
      repository: FirestoreBookingOverviewRepository(
        firestore: firebase.firestore,
      ),
    );

    return MentoraDependencies(
      aiGateway: aiGateway,
      authenticationSession: authenticationSession,
      bookingCancellation: bookingCancellation,
      bookingConfirmation: bookingConfirmation,
      bookingCreation: bookingCreation,
      bookingDashboard: bookingDashboard,
      bookingNotifications: bookingNotifications,
      bookingReschedule: bookingReschedule,
      consultationBrief: consultationBrief,
      consultationCompletion: consultationCompletion,
      consultationDocuments: consultationDocuments,
      consultationMemory: consultationMemory,
      consultationSummaries: consultationSummaries,
      consultationPrivateNotes: consultationPrivateNotes,
      conversations: conversations,
      expertBookingOccupancy: expertBookingOccupancy,
      expertAvailability: expertAvailability,
      availabilityExceptions: availabilityExceptions,
      expertCatalog: expertCatalog,
      expertTimezone: expertTimezone,
      favoriteExperts: favoriteExperts,
      paymentCollection: paymentCollection,
      profile: profile,
      reviews: reviews,
      selectableOccurrences: selectableOccurrences,
      startup: startup,
      timezoneResolver: timezoneResolver,
      videoSessions: videoSessions,
      liveConsultationRooms: liveConsultationRooms,
      transcripts: transcripts,
      translations: translations,
      consultationAssistant: consultationAssistant,
      workspaceState: workspaceState,
      workspaceMemberRepository: workspaceMemberRepository,
      workspaceRepository: workspaceRepository,
    );
  }
}
