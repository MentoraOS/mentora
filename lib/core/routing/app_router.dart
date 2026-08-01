import 'package:flutter/material.dart';
import '../../application/scheduling/civil_selection.dart';
import '../../domain/expert_catalog/consultation_offer.dart';
import '../../domain/expert_catalog/expert_catalog_entry.dart';
import 'package:provider/provider.dart';
import '../../application/authentication/authentication_session.dart';
import '../../screens/financial_history_screen.dart';
import '../../screens/admin_dashboard_screen.dart';
import '../../screens/financial_center_screen.dart';
import '../../screens/withdrawal_admin_screen.dart';
import '../../screens/withdrawal_request_screen.dart';
import '../../screens/withdrawal_history_screen.dart';
import '../../screens/expert_escrow_list_screen.dart';
import '../../screens/expert_wallet_screen.dart';
import '../../screens/pre_consultation_screen.dart';
import '../../screens/video_call_screen.dart';
import '../../screens/edit_profile_screen.dart';
import '../../screens/my_payments_screen.dart';
import '../../screens/favorite_experts_screen.dart';
import '../../screens/notifications_screen.dart';
import '../../screens/appearance_screen.dart';
import '../../screens/expert_dashboard_screen.dart';
import '../../screens/payment_screen.dart';
import '../../screens/booking_success_screen.dart';
import '../../screens/session_completed_screen.dart';
import '../../screens/expert_detail_screen.dart';
import '../../screens/escrow_screen.dart';
import '../../screens/expert_profile_screen.dart';
import '../../screens/waiting_room_screen.dart';
import '../../domain/booking/booking_overview.dart';
import '../../screens/booking_dashboard_screen.dart';
import '../../screens/consultation_dashboard_screen.dart';
import '../../screens/booking_detail_screen.dart';
import '../../screens/reschedule_booking_screen.dart';
import '../../screens/booking_screen.dart';
import '../../presentation/authentication/authentication_screens.dart';
import 'route_guard.dart';
import 'role_router.dart';
import '../../screens/client_dashboard_screen.dart';
import 'guards/permission_guard.dart';
import 'guards/workspace_guard.dart';

import '../../domain/workspace/workspace_type.dart';
import '../../presentation/onboarding/onboarding_screens.dart';
import '../../features/enterprise/presentation/screens/enterprise_members_screen.dart';
import '../../features/enterprise/presentation/screens/send_enterprise_invitation_screen.dart';
import '../../features/enterprise/presentation/screens/enterprise_invitations_inbox_screen.dart';
import '../experience/engine/experience_engine.dart';
import '../experience/models/experience_type.dart';
import '../../screens/enterprise/employee/employee_training_catalog_screen.dart';
import '../../screens/enterprise/executive_dashboard_screen.dart';
import '../../screens/enterprise/hr_dashboard_screen.dart';
import '../../screens/enterprise/finance_dashboard_screen.dart';
import '../../screens/enterprise/employee_dashboard_screen.dart';
import '../../core/learning/models/course.dart';
import '../../screens/enterprise/employee/employee_course_details_screen.dart';

import '../../screens/enterprise/employee/employee_course_curriculum_screen.dart';
import '../../core/learning/models/lesson.dart';
import '../../screens/enterprise/employee/employee_learning_session_screen.dart';

class AppRouter {
  AppRouter._();

  static Future<T?> push<T>(BuildContext context, Widget screen) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  static Future<void> guardedAdmin(BuildContext context, Widget screen) async {
    final allowed = RouteGuard.isAdmin(context.read<AuthenticationSession>());

    if (!allowed) {
      return RoleRouter.redirectAfterLogin(context);
    }

    return push(context, screen);
  }

  static Future<void> guardedExpert(BuildContext context, Widget screen) async {
    final allowed = RouteGuard.isExpert(context.read<AuthenticationSession>());

    if (!allowed) {
      return RoleRouter.redirectAfterLogin(context);
    }

    return push(context, screen);
  }

  static Future<void> openEmployeeTrainingCatalog(BuildContext context) {
    return push(context, const EmployeeTrainingCatalogScreen());
  }

  static Future<void> guardedClient(BuildContext context, Widget screen) async {
    final allowed = RouteGuard.isClient(context.read<AuthenticationSession>());

    if (!allowed) {
      return RoleRouter.redirectAfterLogin(context);
    }

    return push(context, screen);
  }

  static Future<void> openEmployeeCourseCurriculum(
    BuildContext context,
    Course course,
  ) {
    return push(context, EmployeeCourseCurriculumScreen(course: course));
  }

  static Future<void> openEmployeeLearningSession(
    BuildContext context,
    Lesson lesson,
  ) {
    return push(context, const EmployeeLearningSessionScreen());
  }

  static Future<void> openEmployeeCourseDetails(
    BuildContext context,
    Course course,
  ) {
    return push(context, EmployeeCourseDetailsScreen(course: course));
  }

  static Future<void> openSendEnterpriseInvitation(BuildContext context) {
    return guardedWorkspace(
      context: context,
      type: WorkspaceType.company,
      screen: const SendEnterpriseInvitationScreen(),
    );
  }

  static Future<void> openEnterpriseInvitations(BuildContext context) {
    return push(context, const EnterpriseInvitationsInboxScreen());
  }

  static Future<void> openCompanyDashboard(BuildContext context) {
    Widget screen;

    switch (ExperienceEngine.current) {
      case ExperienceType.executive:
        screen = const ExecutiveDashboardScreen();
        break;

      case ExperienceType.hr:
        screen = const HRDashboardScreen();
        break;

      case ExperienceType.finance:
        screen = const FinanceDashboardScreen();
        break;

      case ExperienceType.employee:
        screen = const EmployeeDashboardScreen();
        break;
    }

    return guardedWorkspace(
      context: context,
      type: WorkspaceType.company,
      screen: screen,
    );
  }

  static Future<void> guardedWorkspace({
    required BuildContext context,
    required WorkspaceType type,
    required Widget screen,
  }) {
    return push(context, WorkspaceGuard(requiredType: type, child: screen));
  }

  static Future<void> openExpertDashboard({
    required BuildContext context,
    required String expertId,
  }) {
    return guardedExpert(context, ExpertDashboardScreen(expertId: expertId));
  }

  static Future<void> openLogin(BuildContext context) {
    return push(context, const LoginScreen());
  }

  static Future<void> openEnterpriseMembers(BuildContext context) {
    return guardedWorkspace(
      context: context,
      type: WorkspaceType.company,
      screen: const EnterpriseMembersScreen(),
    );
  }

  static Future<void> openClientDashboard(BuildContext context) {
    return push(context, const ClientDashboardScreen());
  }

  static Future<void> replaceWithOnboardingOne(BuildContext context) {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingOneScreen()),
    );
  }

  static Future<void> openOnboardingTwo(BuildContext context) {
    return push(context, const OnboardingTwoScreen());
  }

  static Future<void> openOnboardingThree(BuildContext context) {
    return push(context, const OnboardingThreeScreen());
  }

  static Future<void> openOnboardingFour(BuildContext context) {
    return push(context, const OnboardingFourScreen());
  }

  static Future<void> openChooseProfile(BuildContext context) {
    return push(context, const ChooseProfileScreen());
  }

  static Future<void> replaceWithChooseProfile(BuildContext context) {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ChooseProfileScreen()),
    );
  }

  static Future<void> openRegisterClient(BuildContext context) {
    return push(context, const RegisterClientScreen());
  }

  static Future<void> replaceWithLogin(BuildContext context) {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  static Future<void> openBookingDetail({
    required BuildContext context,
    required String bookingId,
    required Map<String, dynamic> booking,
  }) {
    return push(
      context,
      BookingDetailScreen(bookingId: bookingId, booking: booking),
    );
  }

  static Future<bool?> openRescheduleBooking({
    required BuildContext context,
    required String bookingId,
    required Map<String, dynamic> booking,
  }) {
    return push<bool>(
      context,
      RescheduleBookingScreen(bookingId: bookingId, booking: booking),
    );
  }

  static Future<void> openExpertProfile(BuildContext context) {
    return push(context, const ExpertProfileScreen());
  }

  static Future<void> openBooking({
    required BuildContext context,
    required String expertName,
    required int expertRate,
    required String expertId,
  }) {
    return push(
      context,
      BookingScreen(
        expertName: expertName,
        expertRate: expertRate,
        expertId: expertId,
      ),
    );
  }

  static Future<void> openExpertDetails({
    required BuildContext context,
    required ExpertCatalogEntry expert,
  }) {
    return push(context, ExpertDetailScreen(expert: expert));
  }

  static Future<void> replaceWithVideoCall({
    required BuildContext context,
    required String bookingId,
    required String expertName,
  }) {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            VideoCallScreen(bookingId: bookingId, expertName: expertName),
      ),
    );
  }

  static Future<void> replaceWithSessionCompleted({
    required BuildContext context,
    required String bookingId,
  }) {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SessionCompletedScreen(bookingId: bookingId),
      ),
    );
  }

  static Future<void> openPayment({
    required BuildContext context,
    required String bookingId,
    required String expertId,
    required String expertName,
    required String selectedDate,
    required String selectedTime,
    required String aiSummary,
    required int amountMinor,
    required String currency,
  }) {
    return push(
      context,
      PaymentScreen(
        bookingId: bookingId,
        expertId: expertId,
        expertName: expertName,
        selectedDate: selectedDate,
        selectedTime: selectedTime,
        aiSummary: aiSummary,
        amountMinor: amountMinor,
        currency: currency,
      ),
    );
  }

  static Future<void> replaceWithWaitingRoom({
    required BuildContext context,
    required String bookingId,
    required String expertName,
    required String selectedDate,
    required String selectedTime,
    required String aiSummary,
  }) {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WaitingRoomScreen(
          bookingId: bookingId,
          expertName: expertName,
          selectedDate: selectedDate,
          selectedTime: selectedTime,
          aiSummary: aiSummary,
        ),
      ),
    );
  }

  static Future<void> replaceWithBookingSuccess({
    required BuildContext context,
    required String bookingId,
    required String expertName,
    required String selectedDate,
    required String selectedTime,
    required String aiSummary,
  }) {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BookingSuccessScreen(
          bookingId: bookingId,
          expertName: expertName,
          selectedDate: selectedDate,
          selectedTime: selectedTime,
          aiSummary: aiSummary,
        ),
      ),
    );
  }

  /// AD-022 Clarification C: the selected slot travels as a structured
  /// selectable civil occurrence, never as localized display strings.
  static Future<void> openPreConsultation({
    required BuildContext context,
    required String expertName,
    required String expertId,
    required ConsultationOffer offer,
    required CivilSelection occurrence,
  }) {
    return push(
      context,
      PreConsultationScreen(
        expertName: expertName,
        expertId: expertId,
        offer: offer,
        occurrence: occurrence,
      ),
    );
  }

  static Future<void> openEditProfile(BuildContext context) {
    return push(context, const EditProfileScreen());
  }

  static Future<void> openNotifications(BuildContext context) {
    return push(context, const NotificationsScreen());
  }

  static Future<void> openAppearance(BuildContext context) {
    return push(context, const AppearanceScreen());
  }

  /// The Booking Dashboard is the reference bookings screen.
  static Future<void> openMyBookings(BuildContext context) {
    return push(context, const BookingDashboardScreen());
  }

  static Future<void> openConsultationDashboard({
    required BuildContext context,
    required BookingOverview booking,
  }) {
    return push(context, ConsultationDashboardScreen(booking: booking));
  }

  static Future<void> openMyPayments(BuildContext context) {
    return push(context, const MyPaymentsScreen());
  }

  static Future<void> openFavoriteExperts(BuildContext context) {
    return push(context, const FavoriteExpertsScreen());
  }

  static Future<void> openAdminDashboard(BuildContext context) {
    return guardedAdmin(context, const AdminDashboardScreen());
  }

  static Future<void> openVideoCall({
    required BuildContext context,
    required String bookingId,
    required String expertName,
  }) {
    return push(
      context,
      VideoCallScreen(bookingId: bookingId, expertName: expertName),
    );
  }

  static Future<void> openFinancialHistory({
    required BuildContext context,
    required String accountId,
  }) {
    return push(context, FinancialHistoryScreen(accountId: accountId));
  }

  static Future<void> openWithdrawalAdmin(BuildContext context) {
    return guardedAdmin(
      context,
      const PermissionGuard(
        permission: 'managePayments',
        child: WithdrawalAdminScreen(),
      ),
    );
  }

  static Future<void> openFinancialCenter({
    required BuildContext context,
    required String expertId,
    required String currency,
    required String countryCode,
  }) {
    return push(
      context,
      FinancialCenterScreen(
        expertId: expertId,
        currency: currency,
        countryCode: countryCode,
      ),
    );
  }

  static Future<void> openExpertWallet({
    required BuildContext context,
    required String expertId,
    required String currency,
  }) {
    return push(
      context,
      ExpertWalletScreen(expertId: expertId, currency: currency),
    );
  }

  static Future<void> openWithdrawalRequest({
    required BuildContext context,
    required String expertId,
    required String currency,
    required String countryCode,
  }) {
    return push(
      context,
      WithdrawalRequestScreen(
        expertId: expertId,
        currency: currency,
        countryCode: countryCode,
      ),
    );
  }

  static Future<void> openWithdrawalHistory({
    required BuildContext context,
    required String expertId,
  }) {
    return push(context, WithdrawalHistoryScreen(expertId: expertId));
  }

  static Future<void> openEscrow({
    required BuildContext context,
    required String bookingId,
    required String currency,
  }) {
    return push(
      context,
      EscrowScreen(bookingId: bookingId, currency: currency),
    );
  }

  static Future<void> openExpertEscrowList({
    required BuildContext context,
    required String expertId,
    required String currency,
  }) {
    return push(
      context,
      ExpertEscrowListScreen(expertId: expertId, currency: currency),
    );
  }
}
