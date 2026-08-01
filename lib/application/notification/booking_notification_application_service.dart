import '../../domain/notification/booking_notification_provider.dart';
import '../authentication/authentication_session.dart';

/// Sends booking lifecycle notifications to the client and the expert.
///
/// Notifications are strictly BEST-EFFORT: they are never a condition of any
/// booking, payment or confirmation workflow, so every failure (provider
/// down, missing session, bad input) is swallowed here and the caller's
/// workflow proceeds unchanged. Nothing in this service owns reservation,
/// payment or scheduling state.
///
/// `notifyBookingCancelled`, `notifyBookingRescheduled` and
/// `notifyConsultationUpcoming` are ready but have no caller yet: cancel and
/// reschedule flows do not exist in the modern funnel, and "upcoming" needs
/// the future scheduling trigger. They are wired the day those flows land.
final class BookingNotificationApplicationService {
  const BookingNotificationApplicationService({
    required AuthenticationSession session,
    required BookingNotificationProvider provider,
  }) : _session = session,
       _provider = provider;

  final AuthenticationSession _session;
  final BookingNotificationProvider _provider;

  Future<void> notifyBookingCreated({
    required String bookingId,
    required String expertId,
    required String expertName,
    required String displayDate,
    required String displayTime,
  }) {
    return _notifyBoth(
      event: BookingNotificationEvent.bookingCreated,
      bookingId: bookingId,
      expertId: expertId,
      clientTitle: 'Réservation créée',
      clientBody:
          'Votre réservation avec $expertName le $displayDate à '
          '$displayTime est créée. Finalisez le paiement pour la confirmer.',
      expertTitle: 'Nouvelle réservation',
      expertBody:
          'Un client a réservé un créneau le $displayDate à $displayTime. '
          'Elle sera confirmée après paiement.',
    );
  }

  Future<void> notifyBookingConfirmed({
    required String bookingId,
    required String expertId,
    required String expertName,
    required String displayDate,
    required String displayTime,
  }) {
    return _notifyBoth(
      event: BookingNotificationEvent.bookingConfirmed,
      bookingId: bookingId,
      expertId: expertId,
      clientTitle: 'Réservation confirmée',
      clientBody:
          'Votre consultation avec $expertName le $displayDate à '
          '$displayTime est confirmée.',
      expertTitle: 'Réservation confirmée',
      expertBody:
          'La réservation du $displayDate à $displayTime est payée et '
          'confirmée.',
    );
  }

  Future<void> notifyBookingCancelled({
    required String bookingId,
    required String expertId,
    required String expertName,
    required String displayDate,
    required String displayTime,
  }) {
    return _notifyBoth(
      event: BookingNotificationEvent.bookingCancelled,
      bookingId: bookingId,
      expertId: expertId,
      clientTitle: 'Réservation annulée',
      clientBody:
          'Votre réservation avec $expertName le $displayDate à '
          '$displayTime a été annulée.',
      expertTitle: 'Réservation annulée',
      expertBody:
          'La réservation du $displayDate à $displayTime a été annulée.',
    );
  }

  Future<void> notifyBookingRescheduled({
    required String bookingId,
    required String expertId,
    required String expertName,
    required String displayDate,
    required String displayTime,
  }) {
    return _notifyBoth(
      event: BookingNotificationEvent.bookingRescheduled,
      bookingId: bookingId,
      expertId: expertId,
      clientTitle: 'Réservation reprogrammée',
      clientBody:
          'Votre réservation avec $expertName est déplacée au $displayDate '
          'à $displayTime.',
      expertTitle: 'Réservation reprogrammée',
      expertBody:
          'Une réservation est déplacée au $displayDate à $displayTime.',
    );
  }

  Future<void> notifyConsultationUpcoming({
    required String bookingId,
    required String expertId,
    required String expertName,
    required String displayDate,
    required String displayTime,
  }) {
    return _notifyBoth(
      event: BookingNotificationEvent.consultationUpcoming,
      bookingId: bookingId,
      expertId: expertId,
      clientTitle: 'Consultation imminente',
      clientBody:
          'Votre consultation avec $expertName commence bientôt '
          '($displayDate à $displayTime).',
      expertTitle: 'Consultation imminente',
      expertBody:
          'Votre consultation du $displayDate à $displayTime commence '
          'bientôt.',
    );
  }

  Future<void> _notifyBoth({
    required BookingNotificationEvent event,
    required String bookingId,
    required String expertId,
    required String clientTitle,
    required String clientBody,
    required String expertTitle,
    required String expertBody,
  }) async {
    final clientId = _session.currentUserId?.trim();

    await _sendBestEffort(() {
      if (clientId == null || clientId.isEmpty) return null;
      return BookingNotification(
        recipientId: clientId,
        audience: BookingNotificationAudience.client,
        event: event,
        bookingId: bookingId,
        title: clientTitle,
        body: clientBody,
      );
    });

    await _sendBestEffort(() {
      if (expertId.trim().isEmpty) return null;
      return BookingNotification(
        recipientId: expertId,
        audience: BookingNotificationAudience.expert,
        event: event,
        bookingId: bookingId,
        title: expertTitle,
        body: expertBody,
      );
    });
  }

  Future<void> _sendBestEffort(BookingNotification? Function() build) async {
    try {
      final notification = build();
      if (notification == null) return;
      await _provider.send(notification);
    } catch (_) {
      // Best-effort by contract: a notification failure never fails the
      // caller's workflow.
    }
  }
}
