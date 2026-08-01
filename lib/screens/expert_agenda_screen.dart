import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../application/expert_availability/expert_availability_application_service.dart';
import '../application/expert_availability/expert_availability_failure.dart';
import '../application/expert_availability_exception/expert_availability_exception_application_service.dart';
import '../application/expert_availability_exception/expert_availability_exception_failure.dart';
import '../application/expert_timezone/expert_timezone_application_service.dart';
import '../domain/expert_availability_exception/expert_availability_exception.dart';
import '../application/expert_timezone/expert_timezone_failure.dart';
import '../domain/expert_availability/expert_availability.dart';
import '../theme/mentora_theme.dart';

class ExpertAgendaScreen extends StatefulWidget {
  const ExpertAgendaScreen({super.key});

  @override
  State<ExpertAgendaScreen> createState() => _ExpertAgendaScreenState();
}

class _ExpertAgendaScreenState extends State<ExpertAgendaScreen> {
  final List<String> days = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];

  final List<String> hours = [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
  ];

  Map<String, List<String>> availability = <String, List<String>>{};
  String? revision;
  bool loading = true;
  bool saving = false;
  String? failureMessage;

  /// AD-022 Clarification A: the declared authoritative timezone identity.
  /// Without it, none of the expert's slots is reservable (fail closed).
  String? declaredTimezone;
  String? selectedTimezone;
  bool timezoneLoading = true;
  bool timezoneSaving = false;
  bool timezoneLoadFailed = false;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
    _loadTimezone();
  }

  Future<void> _loadTimezone() async {
    setState(() {
      timezoneLoading = true;
      timezoneLoadFailed = false;
    });
    try {
      final timezone = await context
          .read<ExpertTimezoneApplicationService>()
          .loadCurrentTimezone();
      if (!mounted) return;
      setState(() {
        declaredTimezone = timezone;
        selectedTimezone = timezone;
        timezoneLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        timezoneLoading = false;
        timezoneLoadFailed = true;
      });
    }
  }

  Future<void> _confirmTimezone() async {
    final timezone = selectedTimezone;
    if (timezone == null) return;

    setState(() => timezoneSaving = true);
    try {
      await context.read<ExpertTimezoneApplicationService>().declareTimezone(
        timezone,
      );
      if (!mounted) return;
      setState(() => declaredTimezone = timezone);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Fuseau horaire confirmé')));
    } on ExpertTimezoneFailure {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d’enregistrer le fuseau horaire.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d’enregistrer le fuseau horaire.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => timezoneSaving = false);
      }
    }
  }

  Future<void> _loadAvailability() async {
    if (mounted) {
      setState(() {
        loading = true;
        failureMessage = null;
      });
    }

    try {
      final loaded = await context
          .read<ExpertAvailabilityApplicationService>()
          .loadCurrentAvailability();

      if (!mounted) return;
      setState(() {
        availability = _editableCopy(loaded.slotsByDay);
        revision = loaded.revision;
        loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        loading = false;
        failureMessage = _messageFor(error);
      });
    }
  }

  void toggleHour(String day, String hour) {
    setState(() {
      availability.putIfAbsent(day, () => []);

      if (availability[day]!.contains(hour)) {
        availability[day]!.remove(hour);
      } else {
        availability[day]!.add(hour);
      }
    });
  }

  Future<void> saveAvailability() async {
    setState(() => saving = true);

    try {
      final saved = await context
          .read<ExpertAvailabilityApplicationService>()
          .saveCurrentAvailability(
            ExpertAvailability(slotsByDay: availability, revision: revision),
          );

      if (!mounted) return;
      setState(() {
        availability = _editableCopy(saved.slotsByDay);
        revision = saved.revision;
        failureMessage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disponibilités enregistrées')),
      );
    } catch (error) {
      if (!mounted) return;
      final message = _messageFor(error);
      setState(() => failureMessage = message);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }

  Map<String, List<String>> _editableCopy(Map<String, List<String>> source) {
    return <String, List<String>>{
      for (final entry in source.entries)
        entry.key: List<String>.of(entry.value),
    };
  }

  String _messageFor(Object error) {
    if (error is ExpertAvailabilityConcurrencyConflictFailure) {
      return 'La disponibilité a été modifiée depuis un autre appareil. '
          'Rechargez les données avant de réessayer.';
    }
    if (error is ExpertAvailabilityUnauthenticatedFailure) {
      return 'Votre session a expiré. Reconnectez-vous pour continuer.';
    }
    if (error is ExpertAvailabilityForbiddenFailure) {
      return 'Seul un Expert peut modifier cette disponibilité.';
    }
    if (error is ExpertAvailabilityMalformedDataFailure) {
      return 'Les disponibilités enregistrées sont invalides.';
    }
    return 'Impossible de charger ou enregistrer les disponibilités.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MentoraColors.navy,
      appBar: AppBar(
        backgroundColor: MentoraColors.navy,
        elevation: 0,
        title: const Text('Agenda expert'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Définissez vos créneaux disponibles',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Les clients pourront réserver uniquement sur ces créneaux.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 24),

            _TimezoneCard(
              loading: timezoneLoading,
              loadFailed: timezoneLoadFailed,
              declaredTimezone: declaredTimezone,
              selectedTimezone: selectedTimezone,
              saving: timezoneSaving,
              onChanged: (timezone) {
                setState(() => selectedTimezone = timezone);
              },
              onConfirm: timezoneSaving ? null : _confirmTimezone,
              onReload: _loadTimezone,
            ),

            const SizedBox(height: 24),

            const _UnavailabilitySection(),

            const SizedBox(height: 24),

            if (loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: CircularProgressIndicator(color: MentoraColors.gold),
              )
            else ...[
              if (failureMessage case final message?) ...[
                _AvailabilityFailureCard(
                  message: message,
                  onReload: _loadAvailability,
                ),
                const SizedBox(height: 20),
              ],
              ...days.map((day) {
                return _DayAvailabilityCard(
                  day: day,
                  hours: hours,
                  selectedHours: availability[day] ?? [],
                  onTapHour: (hour) => toggleHour(day, hour),
                );
              }),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: saving ? null : saveAvailability,
                  icon: const Icon(Icons.save),
                  label: Text(
                    saving ? 'Enregistrement...' : 'Enregistrer l’agenda',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/// AD-022 Clarification A: the expert EXPLICITLY confirms the timezone
/// identity. The card only offers launch-market identities the platform can
/// interpret; nothing is ever derived from the country or the device.
class _TimezoneCard extends StatelessWidget {
  const _TimezoneCard({
    required this.loading,
    required this.loadFailed,
    required this.declaredTimezone,
    required this.selectedTimezone,
    required this.saving,
    required this.onChanged,
    required this.onConfirm,
    required this.onReload,
  });

  final bool loading;
  final bool loadFailed;
  final String? declaredTimezone;
  final String? selectedTimezone;
  final bool saving;
  final ValueChanged<String?> onChanged;
  final VoidCallback? onConfirm;
  final VoidCallback onReload;

  /// Display labels only; the persisted value is the identity itself.
  static const Map<String, String> _labels = {
    'Africa/Bamako': 'Africa/Bamako (Mali)',
    'Africa/Dakar': 'Africa/Dakar (Sénégal)',
    'Africa/Abidjan': 'Africa/Abidjan (Côte d’Ivoire)',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fuseau horaire',
            style: TextStyle(
              color: MentoraColors.gold,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          if (loading)
            const LinearProgressIndicator(
              color: MentoraColors.gold,
              backgroundColor: Colors.white12,
            )
          else if (loadFailed) ...[
            const Text(
              'Impossible de charger le fuseau horaire.',
              style: TextStyle(color: Colors.redAccent),
            ),
            TextButton.icon(
              onPressed: onReload,
              icon: const Icon(Icons.refresh),
              label: const Text('Recharger'),
            ),
          ] else ...[
            if (declaredTimezone == null)
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Sans fuseau horaire confirmé, vos créneaux ne '
                  'sont pas réservables par les clients.',
                  style: TextStyle(color: Colors.orangeAccent),
                ),
              ),
            DropdownButtonFormField<String>(
              initialValue: selectedTimezone,
              dropdownColor: MentoraColors.navy,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(alpha: .06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Choisissez votre fuseau horaire',
                hintStyle: const TextStyle(color: Colors.white38),
              ),
              items: ExpertTimezoneApplicationService.supportedTimezones
                  .map(
                    (timezone) => DropdownMenuItem<String>(
                      value: timezone,
                      child: Text(_labels[timezone] ?? timezone),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: selectedTimezone == null ? null : onConfirm,
                icon: const Icon(Icons.public),
                label: Text(
                  saving
                      ? 'Enregistrement...'
                      : declaredTimezone == null
                      ? 'Confirmer le fuseau horaire'
                      : 'Mettre à jour le fuseau horaire',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Expert unavailability windows: add, list, delete with confirmation.
/// Exceptions live in their own collection; the recurring availability and
/// the expert document are untouched.
class _UnavailabilitySection extends StatefulWidget {
  const _UnavailabilitySection();

  @override
  State<_UnavailabilitySection> createState() => _UnavailabilitySectionState();
}

enum _ExceptionsState { loading, loaded, failed }

class _UnavailabilitySectionState extends State<_UnavailabilitySection> {
  List<ExpertAvailabilityException> _exceptions = const [];
  _ExceptionsState _state = _ExceptionsState.loading;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _state = _ExceptionsState.loading);
    try {
      final exceptions = await context
          .read<ExpertAvailabilityExceptionApplicationService>()
          .listMine();
      if (!mounted) return;
      setState(() {
        _exceptions = exceptions;
        _state = _ExceptionsState.loaded;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _state = _ExceptionsState.failed);
    }
  }

  Future<void> _add() async {
    // Display-only initial dates from the device calendar page.
    final today = DateTime.now();
    var start = today;
    var end = today;
    final reasonController = TextEditingController();

    String iso(DateTime day) {
      String two(int value) => value.toString().padLeft(2, '0');
      return '${day.year}-${two(day.month)}-${two(day.day)}';
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Ajouter une indisponibilité'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: dialogContext,
                    initialDate: start,
                    firstDate: DateTime(today.year - 1),
                    lastDate: DateTime(today.year + 2),
                  );
                  if (picked != null) {
                    setDialogState(() {
                      start = picked;
                      if (end.isBefore(start)) end = start;
                    });
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text('Du ${iso(start)}'),
              ),
              TextButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: dialogContext,
                    initialDate: end,
                    firstDate: DateTime(today.year - 1),
                    lastDate: DateTime(today.year + 2),
                  );
                  if (picked != null) {
                    setDialogState(() => end = picked);
                  }
                },
                icon: const Icon(Icons.calendar_month),
                label: Text('Au ${iso(end)}'),
              ),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Motif (congé, absence...)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    var message = 'Impossible d’ajouter l’indisponibilité.';
    var success = false;
    try {
      await context
          .read<ExpertAvailabilityExceptionApplicationService>()
          .create(
            startDate: iso(start),
            endDate: iso(end),
            reason: reasonController.text,
          );
      success = true;
    } on ExpertAvailabilityExceptionInvalidFailure {
      message = 'Dates ou motif invalides.';
    } catch (_) {
      // Keep the generic message.
    }

    if (!mounted) return;
    setState(() => _busy = false);
    if (success) {
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Indisponibilité ajoutée')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _delete(ExpertAvailabilityException exception) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer cette indisponibilité ?'),
        content: Text(
          'Du ${exception.startDate} au ${exception.endDate} — '
          '${exception.reason}. Les créneaux de cette période '
          'redeviendront réservables.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Retour'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    var success = false;
    try {
      await context
          .read<ExpertAvailabilityExceptionApplicationService>()
          .delete(exception.id);
      success = true;
    } catch (_) {
      success = false;
    }

    if (!mounted) return;
    setState(() => _busy = false);
    if (success) {
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indisponibilité supprimée')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de supprimer. Réessayez.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Indisponibilités',
            style: TextStyle(
              color: MentoraColors.gold,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Congés et absences : aucun créneau ne sera '
            'réservable sur ces périodes.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          switch (_state) {
            _ExceptionsState.loading => const LinearProgressIndicator(
              color: MentoraColors.gold,
              backgroundColor: Colors.white12,
            ),
            _ExceptionsState.failed => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Impossible de charger les indisponibilités.',
                  style: TextStyle(color: Colors.redAccent),
                ),
                TextButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Recharger'),
                ),
              ],
            ),
            _ExceptionsState.loaded => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_exceptions.isEmpty)
                  const Text(
                    'Aucune indisponibilité.',
                    style: TextStyle(color: Colors.white54),
                  ),
                ..._exceptions.map(
                  (exception) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.event_busy,
                          color: Colors.orangeAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exception.startDate == exception.endDate
                                    ? exception.startDate
                                    : '${exception.startDate} → '
                                          '${exception.endDate}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                exception.reason,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _busy ? null : () => _delete(exception),
                          child: const Text('Supprimer'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _add,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter une indisponibilité'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MentoraColors.gold,
                    side: const BorderSide(color: MentoraColors.gold),
                  ),
                ),
              ],
            ),
          },
        ],
      ),
    );
  }
}

class _AvailabilityFailureCard extends StatelessWidget {
  const _AvailabilityFailureCard({
    required this.message,
    required this.onReload,
  });

  final String message;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withValues(alpha: .4)),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: onReload,
            icon: const Icon(Icons.refresh),
            label: const Text('Recharger'),
          ),
        ],
      ),
    );
  }
}

class _DayAvailabilityCard extends StatelessWidget {
  final String day;
  final List<String> hours;
  final List<String> selectedHours;
  final ValueChanged<String> onTapHour;

  const _DayAvailabilityCard({
    required this.day,
    required this.hours,
    required this.selectedHours,
    required this.onTapHour,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day,
            style: const TextStyle(
              color: MentoraColors.gold,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: hours.map((hour) {
              final selected = selectedHours.contains(hour);

              return GestureDetector(
                onTap: () => onTapHour(hour),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? MentoraColors.gold
                        : Colors.white.withOpacity(.08),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: selected
                          ? MentoraColors.gold
                          : Colors.white.withOpacity(.12),
                    ),
                  ),
                  child: Text(
                    hour,
                    style: TextStyle(
                      color: selected ? MentoraColors.navy : Colors.white70,
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
  }
}
