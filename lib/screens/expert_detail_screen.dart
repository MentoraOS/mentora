import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../application/booking/expert_booking_occupancy_application_service.dart';
import '../application/expert_catalog/expert_catalog_failure.dart';
import '../application/scheduling/civil_selection.dart';
import '../application/scheduling/selectable_occurrence_application_service.dart';
import '../application/scheduling/selectable_occurrence_failure.dart';
import '../domain/booking/expert_booking_occupancy.dart';
import '../theme/mentora_theme.dart';
import 'pre_consultation_screen.dart';
import 'package:intl/intl.dart';
import '../core/routing/app_router.dart';
import '../domain/expert_catalog/consultation_offer.dart';
import '../domain/expert_catalog/expert_catalog_entry.dart';
import '../domain/expert_catalog/legacy_rate_offer_adapter.dart';

class ExpertDetailScreen extends StatefulWidget {
  final ExpertCatalogEntry expert;

  const ExpertDetailScreen({super.key, required this.expert});

  @override
  State<ExpertDetailScreen> createState() => _ExpertDetailScreenState();
}

enum _OccupancyLoadState { loading, loaded, failed }

enum _MaterializationState { awaitingOffer, loading, loaded, failed }

/// Display-only French weekday labels for structured civil dates, and the
/// legacy weekday token used by historical occupancy identities. Rendered to
/// the user and compared against legacy read-model keys; never parsed back
/// into temporal truth (AD-022 Clarification C decision 5). Keys follow the
/// `DateTime.monday..sunday` numbering (1..7).
const Map<int, String> _weekdayLabels = {
  DateTime.monday: 'Lundi',
  DateTime.tuesday: 'Mardi',
  DateTime.wednesday: 'Mercredi',
  DateTime.thursday: 'Jeudi',
  DateTime.friday: 'Vendredi',
  DateTime.saturday: 'Samedi',
  DateTime.sunday: 'Dimanche',
};

/// Display-only French month labels, indexed by month number (1..12).
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

/// Display-only weekday of a structured civil date, computed from the
/// explicit components (proleptic Gregorian arithmetic, no clock involved).
String _weekdayLabelOf(CivilSelection start) {
  return _weekdayLabels[DateTime.utc(
    start.year,
    start.month,
    start.day,
  ).weekday]!;
}

String _dateLabel(CivilSelection start) {
  return '${_weekdayLabelOf(start)} ${start.day} ${_monthLabels[start.month]}';
}

class _ExpertDetailScreenState extends State<ExpertDetailScreen> {
  /// The structured civil occurrence the client selected. Selection is only
  /// an intent; Application revalidates it before the funnel continues.
  CivilSelection? _selectedOccurrence;

  List<CivilSelection> _occurrences = const [];
  _MaterializationState _materializationState =
      _MaterializationState.awaitingOffer;

  /// The calendar month page currently displayed. Initialized from device
  /// time for DISPLAY NAVIGATION ONLY (AD-022 Clarification C decision 8):
  /// device time never determines whether a selection is valid.
  late int _visibleYear;
  late int _visibleMonth;

  /// Client-selectable offers exposed by the Expert Catalog (AD-021). The
  /// list is empty when the expert publishes no valid rate; Presentation must
  /// not fabricate one.
  late final List<ConsultationOffer> _offers = const LegacyRateOfferAdapter()
      .offersFor(widget.expert);

  /// The offer the client selected. It is transported to the booking funnel
  /// unchanged; no display index is used as commercial truth.
  ConsultationOffer? _selectedOffer;

  List<ExpertBookingOccupancy> bookedSlots = const [];
  _OccupancyLoadState _occupancyLoadState = _OccupancyLoadState.loading;
  bool _occupancyLoadStarted = false;

  @override
  void initState() {
    super.initState();
    final deviceToday = DateTime.now();
    _visibleYear = deviceToday.year;
    _visibleMonth = deviceToday.month;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_occupancyLoadStarted) return;
    _occupancyLoadStarted = true;
    loadBookedSlots();
  }

  void _selectOffer(ConsultationOffer offer) {
    setState(() => _selectedOffer = offer);
    _materializeVisibleMonth();
  }

  void _showPreviousMonth() {
    setState(() {
      if (_visibleMonth == 1) {
        _visibleMonth = 12;
        _visibleYear -= 1;
      } else {
        _visibleMonth -= 1;
      }
    });
    _materializeVisibleMonth();
  }

  void _showNextMonth() {
    setState(() {
      if (_visibleMonth == 12) {
        _visibleMonth = 1;
        _visibleYear += 1;
      } else {
        _visibleMonth += 1;
      }
    });
    _materializeVisibleMonth();
  }

  /// Asks Application to materialize the visible month's selectable
  /// occurrences. Presentation computes nothing itself: it displays what the
  /// authoritative path offers, and any failure closes the calendar.
  Future<void> _materializeVisibleMonth() async {
    final offer = _selectedOffer;
    if (offer == null) {
      setState(() {
        _occurrences = const [];
        _selectedOccurrence = null;
        _materializationState = _MaterializationState.awaitingOffer;
      });
      return;
    }

    setState(() {
      _occurrences = const [];
      _selectedOccurrence = null;
      _materializationState = _MaterializationState.loading;
    });

    try {
      final occurrences = await context
          .read<SelectableOccurrenceApplicationService>()
          .materializeMonth(
            expertId: widget.expert.id,
            offer: offer,
            year: _visibleYear,
            month: _visibleMonth,
          );
      if (!mounted) return;
      setState(() {
        _occurrences = occurrences;
        _materializationState = _MaterializationState.loaded;
      });
    } catch (_) {
      // Fail closed: unknown availability never becomes selectable
      // availability.
      if (!mounted) return;
      setState(() {
        _occurrences = const [];
        _selectedOccurrence = null;
        _materializationState = _MaterializationState.failed;
      });
    }
  }

  Future<void> loadBookedSlots() async {
    try {
      final slots = await context
          .read<ExpertBookingOccupancyApplicationService>()
          .loadForExpert(widget.expert.id);
      if (!mounted) return;
      setState(() {
        bookedSlots = slots;
        _occupancyLoadState = _OccupancyLoadState.loaded;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        bookedSlots = const [];
        _selectedOccurrence = null;
        _occupancyLoadState = _OccupancyLoadState.failed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final expert = widget.expert;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profil Expert'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 110),
        child: Column(
          children: [
            _HeroSection(expert: expert),
            const SizedBox(height: 16),

            _StatsSection(expert: expert),
            const SizedBox(height: 16),

            _PricingSection(
              offers: _offers,
              selectedOffer: _selectedOffer,
              onOfferSelected: _selectOffer,
            ),
            const SizedBox(height: 16),

            _CalendarSection(
              materializationState: _materializationState,
              occurrences: _occurrences,
              selectedOccurrence: _selectedOccurrence,
              bookedSlots: bookedSlots,
              occupancyLoadState: _occupancyLoadState,
              monthLabel: '${_monthLabels[_visibleMonth]} $_visibleYear',
              onPreviousMonth: _showPreviousMonth,
              onNextMonth: _showNextMonth,
              onOccurrenceSelected: (occurrence) {
                setState(() => _selectedOccurrence = occurrence);
              },
            ),
            const SizedBox(height: 16),

            _AboutSection(expert: expert),
            const SizedBox(height: 16),

            _ChipsSection(
              title: 'Domaines d’expertise',
              items:
                  expert.specialities ?? ['Business', 'Startup', 'Marketing'],
            ),
            const SizedBox(height: 16),

            _ChipsSection(
              title: 'Langues',
              items: expert.languages ?? ['Français', 'Anglais'],
            ),
            const SizedBox(height: 16),

            const _ReviewsSection(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () async {
                final occurrence = _selectedOccurrence;
                if (occurrence == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Choisissez une date et une heure avant de continuer',
                      ),
                    ),
                  );
                  return;
                }

                // AD-021: without an authoritative selected offer there is no
                // commercial truth to carry, so the funnel fails closed.
                final offer = _selectedOffer;
                if (offer == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Choisissez une offre de consultation avant de '
                        'continuer',
                      ),
                    ),
                  );
                  return;
                }

                // AD-022 Clarification C decision 7: a displayed slot is not
                // thereby offered. Application revalidates the structured
                // selection against authoritative inputs before continuing.
                try {
                  final validated = await context
                      .read<SelectableOccurrenceApplicationService>()
                      .revalidate(
                        expertId: expert.id,
                        offer: offer,
                        year: occurrence.year,
                        month: occurrence.month,
                        day: occurrence.day,
                        hour: occurrence.hour,
                        minute: occurrence.minute,
                      );
                  if (!mounted || !context.mounted) return;
                  AppRouter.openPreConsultation(
                    context: context,
                    expertName: expert.name,
                    expertId: expert.id,
                    offer: offer,
                    occurrence: validated,
                  );
                } on SelectableOccurrenceFailure {
                  _showContinueFailure(
                    'Ce créneau n’est plus proposé. Choisissez un autre '
                    'créneau.',
                  );
                } on ExpertCatalogFailure {
                  _showContinueFailure(
                    'Vérification du créneau impossible. Réessayez plus tard.',
                  );
                } catch (_) {
                  _showContinueFailure(
                    'Vérification du créneau impossible. Réessayez plus tard.',
                  );
                }
              },
              icon: const Icon(Icons.calendar_month),
              label: const Text('Préparer votre consultation'),
            ),
          ),
        ),
      ),
    );
  }

  void _showContinueFailure(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _HeroSection extends StatelessWidget {
  final ExpertCatalogEntry expert;

  const _HeroSection({required this.expert});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(MentoraRadius.large),
        boxShadow: MentoraShadows.soft,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 54,
            backgroundColor: MentoraColors.gold,
            backgroundImage:
                expert.photoUrl != null && expert.photoUrl!.isNotEmpty
                ? NetworkImage(expert.photoUrl!)
                : null,
            child: expert.photoUrl == null || expert.photoUrl!.isEmpty
                ? const Icon(Icons.person, size: 58, color: MentoraColors.navy)
                : null,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.circle,
                color: expert.online ? Colors.greenAccent : Colors.grey,
                size: 9,
              ),
              const SizedBox(width: 6),
              Text(
                expert.online ? 'En ligne' : 'Indisponible',
                style: const TextStyle(
                  color: MentoraColors.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            expert.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            expert.job,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(expert.country, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: MentoraColors.gold, size: 18),
              const SizedBox(width: 5),
              Text(
                '${expert.rating} • Mentora Verified',
                style: const TextStyle(
                  color: MentoraColors.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  final ExpertCatalogEntry expert;

  const _StatsSection({required this.expert});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: expert.consultations ?? '0',
            label: 'Consultations',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            value: '${expert.experienceYears ?? '0'} ans',
            label: 'Expérience',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            value: '${expert.satisfactionRate ?? '98'}%',
            label: 'Satisfaction',
          ),
        ),
      ],
    );
  }
}

/// Renders the expert's Consultation Offers and reports the selected one.
///
/// AD-021 decision 15: Presentation displays and transports offer data. It
/// owns no pricing, duration or fallback rule, and never fabricates an offer
/// when the Expert Catalog exposes none.
class _PricingSection extends StatelessWidget {
  final List<ConsultationOffer> offers;
  final ConsultationOffer? selectedOffer;
  final ValueChanged<ConsultationOffer> onOfferSelected;

  const _PricingSection({
    required this.offers,
    required this.selectedOffer,
    required this.onOfferSelected,
  });

  static final NumberFormat _formatter = NumberFormat('#,##0', 'fr_FR');

  static String _title(int durationMinutes) {
    switch (durationMinutes) {
      case 60:
        return '1 heure';
      case 120:
        return '2 heures';
      default:
        return '$durationMinutes minutes';
    }
  }

  static String _subtitle(int durationMinutes) {
    switch (durationMinutes) {
      case 30:
        return 'Conseil rapide';
      case 60:
        return 'Consultation standard';
      case 120:
        return 'Session approfondie';
      default:
        return 'Consultation';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tarif fixé par l'expert",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),

        if (offers.isEmpty)
          Text(
            'Aucune offre de consultation disponible pour cet expert.',
            style: Theme.of(context).textTheme.bodySmall,
          ),

        ...offers.map((offer) {
          final selected = selectedOffer?.offerId == offer.offerId;

          return GestureDetector(
            onTap: () => onOfferSelected(offer),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? MentoraColors.gold
                      : Colors.grey.withOpacity(.20),
                  width: selected ? 1.6 : 1,
                ),
              ),
              child: Row(
                children: [
                  Radio<String>(
                    value: offer.offerId,
                    groupValue: selectedOffer?.offerId,
                    activeColor: MentoraColors.gold,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (value) {
                      if (value == null) return;
                      onOfferSelected(offer);
                    },
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _title(offer.durationMinutes),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                            Text(
                              '${_formatter.format(offer.amountMinor)} '
                              '${offer.currency}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: selected
                                    ? MentoraColors.gold
                                    : Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.color,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 3),

                        Text(
                          _subtitle(offer.durationMinutes),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

/// Structured calendar of selectable civil occurrences.
///
/// Displays what the Application materialization path legitimately offers for
/// the visible month. Presentation renders and reports selection intent only:
/// it computes no availability, interprets no timezone and manufactures no
/// temporal truth. Occupancy display preserves the Wave 2C fail-safe closure:
/// while occupancy is loading or failed, nothing is selectable.
class _CalendarSection extends StatelessWidget {
  final _MaterializationState materializationState;
  final List<CivilSelection> occurrences;
  final CivilSelection? selectedOccurrence;
  final List<ExpertBookingOccupancy> bookedSlots;
  final _OccupancyLoadState occupancyLoadState;
  final String monthLabel;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<CivilSelection> onOccurrenceSelected;

  const _CalendarSection({
    required this.materializationState,
    required this.occurrences,
    required this.selectedOccurrence,
    required this.bookedSlots,
    required this.occupancyLoadState,
    required this.monthLabel,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onOccurrenceSelected,
  });

  /// Whether a legacy or modern occupancy fact claims this occurrence.
  ///
  /// Legacy Booking records identify slots as `Lundi|09:00`; modern records
  /// carry a full civil date. Both remain visible as occupied: legacy display
  /// coexistence per AD-022 Clarification C decision 12.
  bool _isBooked(CivilSelection occurrence) {
    final time = _timeLabel(occurrence);
    final legacyIdentity = '${_weekdayLabelOf(occurrence)}|$time';
    final modernIdentity = '${_dateKey(occurrence)}|$time';
    return bookedSlots.any(
      (occupancy) =>
          occupancy.slotIdentity == legacyIdentity ||
          occupancy.slotIdentity == modernIdentity,
    );
  }

  @override
  Widget build(BuildContext context) {
    final byDate = <String, List<CivilSelection>>{};
    for (final occurrence in occurrences) {
      byDate.putIfAbsent(_dateKey(occurrence), () => []).add(occurrence);
    }

    return _SectionCard(
      title: 'Disponibilit\u00e9s',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedOccurrence != null) ...[
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
                    '${_dateLabel(selectedOccurrence!)} \u00e0 '
                    '${_timeLabel(selectedOccurrence!)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: MentoraColors.gold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          if (occupancyLoadState == _OccupancyLoadState.failed)
            const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: Text(
                'Impossible de v\u00e9rifier les cr\u00e9neaux r\u00e9serv\u00e9s. '
                'La r\u00e9servation est temporairement indisponible.',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),

          Row(
            children: [
              IconButton(
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.chevron_left, color: MentoraColors.gold),
              ),
              Expanded(
                child: Text(
                  monthLabel,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                onPressed: onNextMonth,
                icon: const Icon(
                  Icons.chevron_right,
                  color: MentoraColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          switch (materializationState) {
            _MaterializationState.awaitingOffer => const Text(
              'Choisissez d\u2019abord une offre pour voir les '
              'disponibilit\u00e9s.',
              style: TextStyle(color: Colors.white70),
            ),
            _MaterializationState.loading => const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: LinearProgressIndicator(
                color: MentoraColors.gold,
                backgroundColor: Colors.white12,
              ),
            ),
            _MaterializationState.failed => const Text(
              'Impossible de charger les disponibilit\u00e9s. '
              'La r\u00e9servation est temporairement indisponible.',
              style: TextStyle(color: Colors.redAccent),
            ),
            _MaterializationState.loaded when occurrences.isEmpty => const Text(
              'Aucune disponibilit\u00e9 pour ce mois.',
              style: TextStyle(color: Colors.white70),
            ),
            _MaterializationState.loaded => Column(
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
                          final selected = selectedOccurrence == occurrence;
                          final isBooked = _isBooked(occurrence);
                          final canSelect =
                              occupancyLoadState ==
                                  _OccupancyLoadState.loaded &&
                              !isBooked;
                          final time = _timeLabel(occurrence);

                          return GestureDetector(
                            onTap: canSelect
                                ? () => onOccurrenceSelected(occurrence)
                                : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? MentoraColors.gold
                                    : Colors.white.withOpacity(.08),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: MentoraColors.gold),
                              ),
                              child: Text(
                                isBooked
                                    ? '$time \u2022 R\u00e9serv\u00e9'
                                    : time,
                                style: TextStyle(
                                  color: isBooked
                                      ? Colors.white38
                                      : selected
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
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  final ExpertCatalogEntry expert;

  const _AboutSection({required this.expert});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'À propos',
      child: Text(
        expert.bio ??
            'Expert disponible pour des consultations privées, du mentorat professionnel et de l’accompagnement stratégique.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _ChipsSection extends StatelessWidget {
  final String title;
  final List<String> items;

  const _ChipsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: title,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((item) => _ChipText(text: item)).toList(),
      ),
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection();

  @override
  Widget build(BuildContext context) {
    return const _SectionCard(
      title: 'Avis clients',
      child: Column(
        children: [
          _ReviewItem(
            rating: '5.0',
            comment:
                'Excellent mentor. Ses conseils sont clairs, précis et directement applicables.',
            author: 'Fatou B.',
            country: 'Sénégal',
          ),
          Divider(),
          _ReviewItem(
            rating: '5.0',
            comment:
                'Grâce à cette consultation, j’ai mieux structuré ma stratégie de croissance.',
            author: 'Mohamed D.',
            country: 'Mali',
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(MentoraRadius.large),
        boxShadow: MentoraShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(MentoraRadius.large),
        boxShadow: MentoraShadows.soft,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: MentoraColors.gold,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final String price;
  final String label;

  const _PriceCard({required this.price, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MentoraColors.gold.withOpacity(.12),
        borderRadius: BorderRadius.circular(MentoraRadius.large),
        border: Border.all(color: MentoraColors.gold.withOpacity(.35)),
      ),
      child: Column(
        children: [
          Text(
            price,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: MentoraColors.gold,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ChipText extends StatelessWidget {
  final String text;

  const _ChipText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? MentoraColors.gold.withOpacity(.12)
            : MentoraColors.navy,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: MentoraColors.gold.withOpacity(.35),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: MentoraColors.gold,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: .2,
        ),
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final String rating;
  final String comment;
  final String author;
  final String country;

  const _ReviewItem({
    required this.rating,
    required this.comment,
    required this.author,
    required this.country,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: MentoraColors.gold, size: 16),
              const SizedBox(width: 4),
              Text(
                rating,
                style: const TextStyle(
                  color: MentoraColors.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            '— $author, $country',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _EmptyAvailabilityCard extends StatelessWidget {
  const _EmptyAvailabilityCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        'Aucune disponibilité définie pour le moment.',
        style: TextStyle(color: Colors.white70),
      ),
    );
  }
}
