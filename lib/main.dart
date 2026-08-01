import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'application/authentication/authentication_session.dart';
import 'application/booking/booking_cancellation_application_service.dart';
import 'application/booking/booking_confirmation_application_service.dart';
import 'application/booking/booking_dashboard_application_service.dart';
import 'application/booking/booking_creation_application_service.dart';
import 'application/booking/booking_reschedule_application_service.dart';
import 'application/booking/consultation_completion_application_service.dart';
import 'application/booking/expert_booking_occupancy_application_service.dart';
import 'application/consultation_brief/consultation_brief_application_service.dart';
import 'application/consultation_documents/consultation_document_application_service.dart';
import 'application/consultation_notes/consultation_private_notes_application_service.dart';
import 'application/conversation/conversation_application_service.dart';
import 'application/expert_availability/expert_availability_application_service.dart';
import 'application/expert_availability_exception/expert_availability_exception_application_service.dart';
import 'application/expert_catalog/expert_catalog_application_service.dart';
import 'application/expert_timezone/expert_timezone_application_service.dart';
import 'application/favorites/favorite_experts_application_service.dart';
import 'application/notification/booking_notification_application_service.dart';
import 'application/payment/payment_collection_application_service.dart';
import 'application/profile/profile_application_service.dart';
import 'application/review/review_application_service.dart';
import 'application/scheduling/selectable_occurrence_application_service.dart';
import 'application/startup/mentora_startup.dart';
import 'application/video_session/video_session_application_service.dart';
import 'application/workspace/workspace_state.dart';
import 'domain/video_session/live_consultation_room.dart';
import 'infrastructure/video_session/livekit_video_view.dart';
import 'widgets/video_track_view.dart';
import 'core/bootstrap/mentora_os.dart';

import 'core/routing/app_router.dart';

import 'screens/client_dashboard_screen.dart';
import 'screens/expert_dashboard_screen.dart';
import 'theme/mentora_theme.dart';
import 'theme/theme_provider.dart';
import 'composition/composition.dart';
import 'presentation/authentication/authentication_screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dependencies = await MentoraCompositionRoot.production();

  final startupResult = await dependencies.startup.execute();

  if (startupResult.isFailure) {
    debugPrint('Mentora startup failed: ${startupResult.error}');
  }

  await MentoraOS.initialize();
  await MentoraOS.start();

  runApp(
    MultiProvider(
      providers: [
        Provider<MentoraStartup>.value(value: dependencies.startup),
        Provider<AuthenticationSession>.value(
          value: dependencies.authenticationSession,
        ),
        Provider<BookingCancellationApplicationService>.value(
          value: dependencies.bookingCancellation,
        ),
        Provider<BookingConfirmationApplicationService>.value(
          value: dependencies.bookingConfirmation,
        ),
        Provider<BookingCreationApplicationService>.value(
          value: dependencies.bookingCreation,
        ),
        Provider<BookingDashboardApplicationService>.value(
          value: dependencies.bookingDashboard,
        ),
        Provider<BookingNotificationApplicationService>.value(
          value: dependencies.bookingNotifications,
        ),
        Provider<BookingRescheduleApplicationService>.value(
          value: dependencies.bookingReschedule,
        ),
        Provider<ExpertBookingOccupancyApplicationService>.value(
          value: dependencies.expertBookingOccupancy,
        ),
        Provider<ConsultationBriefApplicationService>.value(
          value: dependencies.consultationBrief,
        ),
        Provider<ConsultationCompletionApplicationService>.value(
          value: dependencies.consultationCompletion,
        ),
        Provider<ReviewApplicationService>.value(
          value: dependencies.reviews,
        ),
        Provider<ConsultationDocumentApplicationService>.value(
          value: dependencies.consultationDocuments,
        ),
        Provider<ConsultationPrivateNotesApplicationService>.value(
          value: dependencies.consultationPrivateNotes,
        ),
        Provider<ConversationApplicationService>.value(
          value: dependencies.conversations,
        ),
        Provider<ExpertAvailabilityApplicationService>.value(
          value: dependencies.expertAvailability,
        ),
        Provider<ExpertAvailabilityExceptionApplicationService>.value(
          value: dependencies.availabilityExceptions,
        ),
        Provider<ExpertCatalogApplicationService>.value(
          value: dependencies.expertCatalog,
        ),
        Provider<ExpertTimezoneApplicationService>.value(
          value: dependencies.expertTimezone,
        ),
        Provider<FavoriteExpertsApplicationService>.value(
          value: dependencies.favoriteExperts,
        ),
        Provider<PaymentCollectionApplicationService>.value(
          value: dependencies.paymentCollection,
        ),
        Provider<ProfileApplicationService>.value(value: dependencies.profile),
        Provider<SelectableOccurrenceApplicationService>.value(
          value: dependencies.selectableOccurrences,
        ),
        Provider<VideoSessionApplicationService>.value(
          value: dependencies.videoSessions,
        ),
        Provider<LiveConsultationRoomProvider>.value(
          value: dependencies.liveConsultationRooms,
        ),
        // The single place where LiveKit rendering meets the widget tree.
        Provider<VideoTrackViewBuilder>.value(value: buildLiveKitVideoView),
        Provider<WorkspaceState>.value(value: dependencies.workspaceState),
        ChangeNotifierProvider(create: (_) => MentoraThemeProvider()),
      ],
      child: const MentoraApp(),
    ),
  );
}

class MentoraApp extends StatelessWidget {
  const MentoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MentoraThemeProvider>(
      builder: (context, theme, child) {
        return MaterialApp(
          title: 'Mentora',
          debugShowCheckedModeBanner: false,
          theme: MentoraTheme.lightTheme,
          darkTheme: MentoraTheme.darkTheme,
          themeMode: theme.themeMode,
          home: const _InitialSessionGate(),
        );
      },
    );
  }
}

class _InitialSessionGate extends StatelessWidget {
  const _InitialSessionGate();

  @override
  Widget build(BuildContext context) {
    final session = context.read<AuthenticationSession>();

    if (session.status == AuthenticationSessionStatus.loading) {
      return const Scaffold(
        backgroundColor: navy,
        body: Center(child: CircularProgressIndicator(color: gold)),
      );
    }

    if (!session.isAuthenticated) {
      return const LoginScreen();
    }

    if (session.isExpert) {
      final expertId = session.currentUserId;

      if (expertId == null || expertId.isEmpty) {
        return const LoginScreen();
      }

      return ExpertDashboardScreen(expertId: expertId);
    }

    return const ClientDashboardScreen();
  }
}

/* SPLASH SCREEN */

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scale = Tween<double>(
      begin: 0.88,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      AppRouter.replaceWithOnboardingOne(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.3,
            colors: [Color(0xFF173A70), Color(0xFF061A3D), Color(0xFF020B1F)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo_mentora.png', width: 240),
                  const SizedBox(height: 28),
                  const Text(
                    'MENTORA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'CONNECTER • ÉCHANGER • RÉUSSIR',
                    style: TextStyle(
                      color: gold,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 44),
                  Container(width: 42, height: 3, color: gold),
                  const SizedBox(height: 28),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 38),
                    child: Text(
                      'La plateforme africaine de référence\n'
                      'pour des consultations privées avec\n'
                      'des experts et des masterclass exclusives.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.55,
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                  const SizedBox(
                    width: 42,
                    height: 42,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(gold),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Chargement...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
