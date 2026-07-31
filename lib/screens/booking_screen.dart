import 'package:flutter/material.dart';
import 'payment_screen.dart';
import 'pre_consultation_screen.dart';

class BookingScreen extends StatefulWidget {
  final String expertName;
  final int expertRate;
  final String expertId;

  const BookingScreen({
    super.key,
    required this.expertName,
    required this.expertRate,
    required this.expertId,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int selectedDuration = 60;
  String selectedTime = '11:00';

  static const navy = Color(0xFF061A3D);
  static const gold = Color(0xFFF5A400);

  int get totalPrice {
    if (selectedDuration == 30) {
      return (widget.expertRate / 2).round();
    } else if (selectedDuration == 60) {
      return widget.expertRate;
    } else {
      return (widget.expertRate * 1.5).round();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
              const SizedBox(height: 12),
              const Text(
                'Réserver une\nconsultation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Choisissez la durée, la date et l’heure de votre session avec ${widget.expertName}.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              const Text('Durée', style: _sectionTitle),
              const SizedBox(height: 12),
              Row(
                children: [
                  _durationCard(
                    30,
                    '30 min',
                    '${(widget.expertRate / 2).round()} FCFA',
                  ),
                  _durationCard(60, '60 min', '${widget.expertRate} FCFA'),
                  _durationCard(
                    90,
                    '90 min',
                    '${(widget.expertRate * 1.5).round()} FCFA',
                  ),
                ],
              ),

              const SizedBox(height: 26),
              const Text('Date', style: _sectionTitle),
              const SizedBox(height: 12),
              _infoBox(Icons.calendar_month, 'Mercredi 25 Juin 2026'),

              const SizedBox(height: 26),
              const Text('Créneaux disponibles', style: _sectionTitle),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  '09:00',
                  '11:00',
                  '14:00',
                  '16:00',
                ].map((time) => _timeChip(time)).toList(),
              ),

              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const Spacer(),
                    Text(
                      '$totalPrice FCFA',
                      style: const TextStyle(
                        color: gold,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
        child: SizedBox(
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              // AD-021: this legacy screen carries no authoritative
              // Consultation Offer, and an offer must never be synthesised.
              // The client selects one on the expert profile instead.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Choisissez une offre de consultation sur le profil de '
                    'l’expert pour continuer.',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: navy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              'Continuer vers le paiement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }

  Widget _durationCard(int value, String title, String price) {
    final selected = selectedDuration == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedDuration = value),
        child: Container(
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? gold : Colors.white10,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: selected ? navy : Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                price,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? navy : Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeChip(String time) {
    final selected = selectedTime == time;

    return GestureDetector(
      onTap: () => setState(() => selectedTime = time),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? gold : Colors.white10,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          time,
          style: TextStyle(
            color: selected ? navy : Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _infoBox(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: gold),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

const _sectionTitle = TextStyle(
  color: Colors.white,
  fontSize: 20,
  fontWeight: FontWeight.w900,
);
