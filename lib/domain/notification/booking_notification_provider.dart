/// Booking notification boundary.
///
/// A real push/SMS/email provider (FCM, OneSignal, …) is integrated by
/// implementing this port in Infrastructure; nothing upstream changes.
/// Recipients are Mentora user identities — token resolution is a concern of
/// the concrete adapter.
abstract interface class BookingNotificationProvider {
  Future<void> send(BookingNotification notification);
}

enum BookingNotificationEvent {
  bookingCreated,
  bookingConfirmed,
  bookingCancelled,
  bookingRescheduled,
  consultationUpcoming,
}

enum BookingNotificationAudience { client, expert }

final class BookingNotification {
  final String recipientId;
  final BookingNotificationAudience audience;
  final BookingNotificationEvent event;
  final String bookingId;
  final String title;
  final String body;

  factory BookingNotification({
    required String recipientId,
    required BookingNotificationAudience audience,
    required BookingNotificationEvent event,
    required String bookingId,
    required String title,
    required String body,
  }) {
    if (recipientId.trim().isEmpty) {
      throw ArgumentError.value(
        recipientId,
        'recipientId',
        'must not be empty',
      );
    }
    if (bookingId.trim().isEmpty) {
      throw ArgumentError.value(bookingId, 'bookingId', 'must not be empty');
    }
    if (title.trim().isEmpty) {
      throw ArgumentError.value(title, 'title', 'must not be empty');
    }

    return BookingNotification._(
      recipientId: recipientId,
      audience: audience,
      event: event,
      bookingId: bookingId,
      title: title,
      body: body,
    );
  }

  const BookingNotification._({
    required this.recipientId,
    required this.audience,
    required this.event,
    required this.bookingId,
    required this.title,
    required this.body,
  });
}
