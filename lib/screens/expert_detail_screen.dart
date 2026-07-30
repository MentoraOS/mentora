import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/mentora_theme.dart';
import 'pre_consultation_screen.dart';
import 'package:intl/intl.dart';
import '../core/routing/app_router.dart';
import '../domain/expert_catalog/expert_catalog_entry.dart';

class ExpertDetailScreen extends StatefulWidget {
  final ExpertCatalogEntry expert;

  const ExpertDetailScreen({super.key, required this.expert});

  @override
  State<ExpertDetailScreen> createState() => _ExpertDetailScreenState();
}

class _ExpertDetailScreenState extends State<ExpertDetailScreen> {
  String? selectedDate;
  String? selectedTime;

  List<String> bookedSlots = [];
  bool loadingBookedSlots = false;

  @override
  void initState() {
    super.initState();
    loadBookedSlots();
  }

  Future<void> loadBookedSlots() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('expertId', isEqualTo: widget.expert.id)
        .where('status', whereIn: ['pending', 'confirmed', 'paid'])
        .get();

    final slots = snapshot.docs.map((doc) {
      final data = doc.data();
      return '${data['bookingDate']}|${data['bookingTime']}';
    }).toList();

    if (!mounted) return;

    setState(() {
      bookedSlots = slots;
      loadingBookedSlots = false;
    });
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

            _PricingSection(expert: expert),
            const SizedBox(height: 16),

            _AvailabilitySection(
              expert: expert,
              selectedDate: selectedDate,
              selectedTime: selectedTime,
              bookedSlots: bookedSlots,
              loadingBookedSlots: loadingBookedSlots,
              onSlotSelected: (day, hour) {
                setState(() {
                  selectedDate = day;
                  selectedTime = hour;
                });
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
              onPressed: () {
                if (selectedDate == null || selectedTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Choisissez une date et une heure avant de continuer',
                      ),
                    ),
                  );
                  return;
                }

                AppRouter.openPreConsultation(
                  context: context,
                  expertName: expert.name,
                  selectedDate: selectedDate!,
                  selectedTime: selectedTime!,
                  expertId: expert.id,
                );
              },
              icon: const Icon(Icons.calendar_month),
              label: const Text('Préparer votre consultation'),
            ),
          ),
        ),
      ),
    );
  }

  Future<Map<String, String>?> _showAvailabilityCalendar(BuildContext context) {
    final availableDays = [3, 5, 10, 14, 22, 25, 29];
    int? selectedDay;

    return showModalBottomSheet<Map<String, String>>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: MentoraColors.gold,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Choisir une date',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Juillet 2026',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _WeekDay('L'),
                      _WeekDay('M'),
                      _WeekDay('M'),
                      _WeekDay('J'),
                      _WeekDay('V'),
                      _WeekDay('S'),
                      _WeekDay('D'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 31,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                    itemBuilder: (context, index) {
                      final day = index + 1;
                      final isAvailable = availableDays.contains(day);
                      final isSelected = selectedDay == day;

                      return GestureDetector(
                        onTap: isAvailable
                            ? () {
                                setModalState(() {
                                  selectedDay = day;
                                });
                              }
                            : null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? MentoraColors.gold
                                : isAvailable
                                ? MentoraColors.gold.withOpacity(0.12)
                                : Colors.grey.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$day',
                              style: TextStyle(
                                color: isSelected
                                    ? MentoraColors.navy
                                    : isAvailable
                                    ? Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.color
                                    : Colors.grey,
                                fontWeight: isAvailable
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  if (selectedDay != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Créneaux disponibles le $selectedDay juillet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _TimeSlot(
                              date: '$selectedDay juillet',
                              time: '09:00',
                            ),
                            _TimeSlot(
                              date: '$selectedDay juillet',
                              time: '10:30',
                            ),
                            _TimeSlot(
                              date: '$selectedDay juillet',
                              time: '14:00',
                            ),
                            _TimeSlot(
                              date: '$selectedDay juillet',
                              time: '16:30',
                            ),
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
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

class _PricingSection extends StatefulWidget {
  final ExpertCatalogEntry expert;

  const _PricingSection({super.key, required this.expert});

  @override
  State<_PricingSection> createState() => _PricingSectionState();
}

class _PricingSectionState extends State<_PricingSection> {
  int selectedIndex = 1;
  final formatter = NumberFormat('#,##0', 'fr_FR');

  @override
  Widget build(BuildContext context) {
    final expert = widget.expert;

    final options = [
      {
        "title": "30 minutes",
        "subtitle": "Conseil rapide",
        "price": "${formatter.format(expert.rate30 ?? 25000)} FCFA",
      },
      {
        "title": "1 heure",
        "subtitle": "Consultation standard",
        "price": "${formatter.format(expert.rate60 ?? 50000)} FCFA",
      },
      {
        "title": "2 heures",
        "subtitle": "Session approfondie",
        "price": "${formatter.format(expert.rate120 ?? 100000)} FCFA",
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tarif fixé par l'expert",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),

        ...List.generate(options.length, (index) {
          final item = options[index];
          final selected = selectedIndex == index;

          return GestureDetector(
            onTap: () => setState(() => selectedIndex = index),
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
                  Radio<int>(
                    value: index,
                    groupValue: selectedIndex,
                    activeColor: MentoraColors.gold,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => selectedIndex = value);
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
                                item["title"] as String,
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
                              item["price"] as String,
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
                          item["subtitle"] as String,
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

class _AvailabilitySection extends StatelessWidget {
  final ExpertCatalogEntry expert;
  final String? selectedDate;
  final String? selectedTime;
  final void Function(String day, String hour) onSlotSelected;
  final List<String> bookedSlots;
  final bool loadingBookedSlots;

  const _AvailabilitySection({
    required this.expert,
    required this.selectedDate,
    required this.selectedTime,
    required this.onSlotSelected,
    required this.bookedSlots,
    required this.loadingBookedSlots,
  });

  @override
  Widget build(BuildContext context) {
    final availability = expert.availability;

    return _SectionCard(
      title: 'Disponibilités',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedDate != null && selectedTime != null) ...[
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
                    '$selectedDate à $selectedTime',
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

          if (loadingBookedSlots)
            const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: LinearProgressIndicator(color: MentoraColors.gold),
            ),

          if (availability.isEmpty)
            const Text(
              'Aucune disponibilité définie pour le moment.',
              style: TextStyle(color: Colors.white70),
            )
          else
            ...availability.entries.map((entry) {
              final day = entry.key;
              final hours = entry.value;

              if (hours.isEmpty) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day,
                      style: const TextStyle(
                        color: MentoraColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: hours.map((hour) {
                        final selected =
                            selectedDate == day && selectedTime == hour;
                        final isBooked = bookedSlots.contains('$day|$hour');

                        return GestureDetector(
                          onTap: isBooked
                              ? null
                              : () => onSlotSelected(day, hour),
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
                              isBooked ? '$hour • Réservé' : hour,
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
            }),
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

class _WeekDay extends StatelessWidget {
  final String day;

  const _WeekDay(this.day);

  @override
  Widget build(BuildContext context) {
    return Text(
      day,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _TimeSlot extends StatelessWidget {
  final String date;
  final String time;

  const _TimeSlot({required this.date, required this.time});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context, {'date': date, 'time': time});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: MentoraColors.gold.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: MentoraColors.gold.withOpacity(0.4)),
        ),
        child: Text(
          time,
          style: const TextStyle(
            color: MentoraColors.gold,
            fontWeight: FontWeight.bold,
          ),
        ),
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
