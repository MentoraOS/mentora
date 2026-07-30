import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../application/expert_availability/expert_availability_application_service.dart';
import '../application/expert_availability/expert_availability_failure.dart';
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

  @override
  void initState() {
    super.initState();
    _loadAvailability();
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
