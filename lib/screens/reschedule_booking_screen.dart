import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../application/booking/booking_reschedule_application_service.dart';
import '../application/booking/booking_reschedule_failure.dart';
import '../application/notification/booking_notification_application_service.dart';
import '../application/scheduling/civil_selection.dart';
import '../application/scheduling/selectable_occurrence_failure.dart';
import '../theme/mentora_theme.dart';

/// Reschedule flow: the client picks a new structured civil start from the
/// expert's authoritative availability, materialized with the reservation's
/// snapshotted duration through the C2/C3 Application path. Presentation
/// displays candidates and reports intent only; device time picks the
/// initially visible month page and never validates anything.
class RescheduleBookingScreen extends StatefulWidget {
  final String bookingId;
  final Map<String, dynamic> booking;

  const RescheduleBookingScreen({
    super.key,
    required this.bookingId,
    required this.booking,
  });

  @override
  State<RescheduleBookingScreen> createState() =>
      _RescheduleBookingScreenState();
}

enum _CalendarState { loading, loaded, failed }

const Map<int, String> _weekdayLabels = {
  DateTime.monday: 'Lundi',
  DateTime.tuesday: 'Mardi',
  DateTime.wednesday: 'Mercredi',
  DateTime.thursday: 'Jeudi',
  DateTime.friday: 'Vendredi',
  DateTime.saturday: 'Samedi',
  DateTime.sunday: 'Dimanche',
};

const List<String> _monthLabels = [
  '',
  'janvier',
  'février',
  'mars',
  'avril',
  'mai',
  'juin',
  'juillet',
  'août',
  'septembre',
  'octobre',
  'novembre',
  'décembre',
];

String _two(int value) => value.toString().padLeft(2, '0');

String _timeLabel(CivilSelection start) {
  return '${_two(start.hour)}:${_two(start.minute)}';
}

String _dateKey(CivilSelection start) {
  return '${start.year}-${_two(start.month)}-${_two(start.day)}';
}

String _dateLabel(CivilSelection start) {
  final weekday =
      _weekdayLabels[DateTime.utc(start.year, start.month, start.day).weekday]!;
  return '$weekday ${start.day} ${_monthLabels[start.month]}';
}

class _RescheduleBookingScreenState extends State<RescheduleBookingScreen> {
  late final String _expertId = (widget.booking['expertId'] as String?) ?? '';
  late final String _expertName =
      (widget.booking['expertName'] as String?) ?? 'Expert';

  /// The reservation's snapshotted duration; the new occurrence keeps it.
  late final int? _durationMinutes = widget.booking['duration'] is int
      ? widget.booking['duration'] as int
      : null;

  CivilSelection? _selected;
  List<CivilSelection> _occurrences = const [];
  _CalendarState _state = _CalendarState.loading;
  bool _submitting = false;

  late int _visibleYear;
  late int _visibleMonth;

  @override
  void initState() {
    super.initState();
    // Display-only calendar navigation (AD-022 Clarification C decision 8).
    final deviceToday = DateTime.now();
    _visibleYear = deviceToday.year;
    _visibleMonth = deviceToday.month;
    WidgetsBinding.instance.addPostFrameCallback((_) => _materialize());
  }

  Future<void> _materialize() async {
    final duration = _durationMinutes;
    if (duration == null || _expertId.isEmpty) {
      setState(() => _state = _CalendarState.failed);
      return;
    }

    setState(() {
      _state = _CalendarState.loading;
      _occurrences = const [];
      _selected = null;
    });

    try {
      final occurrences = await context
          .read<BookingRescheduleApplicationService>()
          .materializeMonth(
            expertId: _expertId,
            durationMinutes: duration,
            year: _visibleYear,
            month: _visibleMonth,
          );
      if (!mounted) return;
      setState(() {
        _occurrences = occurrences;
        _state = _CalendarState.loaded;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _state = _CalendarState.failed);
    }
  }

  void _shiftMonth(int delta) {
    setState(() {
      var month = _visibleMonth + delta;
      if (month == 0) {
        month = 12;
        _visibleYear -= 1;
      } else if (month == 13) {
        month = 1;
        _visibleYear += 1;
      }
      _visibleMonth = month;
    });
    _materialize();
  }

  Future<void> _confirm() async {
    final selected = _selected;
    final duration = _durationMinutes;
    if (selected == null || duration == null) return;

    setState(() => _submitting = true);
    var message = 'La reprogrammation a échoué. Réessayez plus tard.';
    var success = false;
    try {
      await context.read<BookingRescheduleApplicationService>().reschedule(
        bookingId: widget.bookingId,
        expertId: _expertId,
        durationMinutes: duration,
        year: selected.year,
        month: selected.month,
        day: selected.day,
        hour: selected.hour,
        minute: selected.minute,
      );
      success = true;
    } on SelectableOccurrenceFailure {
      message = 'Ce créneau n’est plus proposé. Choisissez-en un autre.';
    } on BookingRescheduleInvalidStateFailure {
      message = 'Cette réservation ne peut plus être reprogrammée.';
    } on BookingRescheduleFailure {
      // Keep the generic message.
    } catch (_) {
      // Keep the generic message.
    }

    if (!mounted) return;

    if (!success) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    // Best-effort lifecycle notification; never a condition of the change.
    await context
        .read<BookingNotificationApplicationService>()
        .notifyBookingRescheduled(
          bookingId: widget.bookingId,
          expertId: _expertId,
          expertName: _expertName,
          displayDate:
              '${_two(selected.day)}/${_two(selected.month)}/'
              '${selected.year}',
          displayTime: _timeLabel(selected),
        );

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Réservation reprogrammée')));
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final byDate = <String, List<CivilSelection>>{};
    for (final occurrence in _occurrences) {
      byDate.putIfAbsent(_dateKey(occurrence), () => []).add(occurrence);
    }

    return Scaffold(
      backgroundColor: MentoraColors.navy,
      appBar: AppBar(
        backgroundColor: MentoraColors.navy,
        elevation: 0,
        title: const Text('Reprogrammer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choisissez un nouveau créneau avec $_expertName',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Créneau actuel : '
              '${widget.booking['bookingDate'] ?? ''} • '
              '${widget.booking['bookingTime'] ?? ''}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 18),

            if (_selected case final selected?) ...[
              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.greenAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_dateLabel(selected)} à ${_timeLabel(selected)}',
                      style: const TextStyle(
                        color: MentoraColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],

            Row(
              children: [
                IconButton(
                  onPressed: () => _shiftMonth(-1),
                  icon: const Icon(
                    Icons.chevron_left,
                    color: MentoraColors.gold,
                  ),
                ),
                Expanded(
                  child: Text(
                    '${_monthLabels[_visibleMonth]} $_visibleYear',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _shiftMonth(1),
                  icon: const Icon(
                    Icons.chevron_right,
                    color: MentoraColors.gold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            switch (_state) {
              _CalendarState.loading => const LinearProgressIndicator(
                color: MentoraColors.gold,
                backgroundColor: Colors.white12,
              ),
              _CalendarState.failed => const Text(
                'Impossible de charger les disponibilités. '
                'La reprogrammation est temporairement indisponible.',
                style: TextStyle(color: Colors.redAccent),
              ),
              _CalendarState.loaded when _occurrences.isEmpty => const Text(
                'Aucune disponibilité pour ce mois.',
                style: TextStyle(color: Colors.white70),
              ),
              _CalendarState.loaded => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: byDate.values.map((dayOccurrences) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _dateLabel(dayOccurrences.first),
                          style: const TextStyle(
                            color: MentoraColors.gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: dayOccurrences.map((occurrence) {
                            final selected = _selected == occurrence;
                            return GestureDetector(
                              onTap: () {
                                setState(() => _selected = occurrence);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? MentoraColors.gold
                                      : Colors.white.withValues(alpha: .08),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: MentoraColors.gold),
                                ),
                                child: Text(
                                  _timeLabel(occurrence),
                                  style: TextStyle(
                                    color: selected
                                        ? MentoraColors.navy
                                        : MentoraColors.gold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            },

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _selected == null || _submitting ? null : _confirm,
                icon: const Icon(Icons.event_repeat),
                label: Text(
                  _submitting
                      ? 'Reprogrammation...'
                      : 'Confirmer le nouveau créneau',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
