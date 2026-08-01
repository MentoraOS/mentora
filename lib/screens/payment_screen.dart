import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'booking_success_screen.dart';
import 'package:intl/intl.dart';
import '../application/booking/booking_confirmation_application_service.dart';
import '../application/booking/booking_confirmation_failure.dart';
import 'payment_success_animation.dart';
import '../core/engines/country/country_engine.dart';
import '../core/routing/app_router.dart';

class PaymentScreen extends StatefulWidget {
  final String bookingId;
  final String expertName;
  final String selectedDate;
  final String selectedTime;
  final String aiSummary;

  /// Authoritative commercial amount, copied from the Booking commercial
  /// snapshot (AD-021 decision 12). Payment consumes it and never computes it.
  final int amountMinor;

  /// Authoritative ISO 4217 currency of [amountMinor].
  final String currency;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.expertName,
    required this.selectedDate,
    required this.selectedTime,
    required this.aiSummary,
    required this.amountMinor,
    required this.currency,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const navy = Color(0xFF061A3D);
  static const gold = Color(0xFFF5A400);
  bool isProcessing = false;
  String paymentMethod = "wave";
  bool acceptedTerms = false;
  late final int total = widget.amountMinor;

  final NumberFormat money = NumberFormat('#,##0', 'fr_FR');

  final String countryCode = 'ML';

  late final countryConfig = CountryEngine.getByCode(countryCode);
  late final List<String> availablePaymentProviders =
      countryConfig.paymentProviders;

  String _paymentProviderLabel(String provider) {
    switch (provider) {
      case 'wave':
        return 'Wave';
      case 'orange_money':
        return 'Orange Money';
      case 'moov_money':
        return 'Moov Money';
      case 'mtn_money':
        return 'MTN Money';
      case 'paydunya':
        return 'PayDunya';
      case 'cinetpay':
        return 'CinetPay';
      case 'card':
        return 'Carte bancaire';
      default:
        return provider;
    }
  }

  String _paymentProviderSubtitle(String provider) {
    switch (provider) {
      case 'wave':
        return 'Paiement instantané';
      case 'orange_money':
      case 'moov_money':
      case 'mtn_money':
        return 'Mobile Money';
      case 'paydunya':
      case 'cinetpay':
        return 'Passerelle de paiement';
      case 'card':
        return 'Visa • Mastercard';
      default:
        return 'Moyen de paiement';
    }
  }

  IconData _paymentProviderIcon(String provider) {
    switch (provider) {
      case 'wave':
        return Icons.waves;
      case 'orange_money':
      case 'moov_money':
      case 'mtn_money':
        return Icons.account_balance_wallet;
      case 'paydunya':
      case 'cinetpay':
        return Icons.payment;
      case 'card':
        return Icons.credit_card;
      default:
        return Icons.payments;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Paiement sécurisé",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            //------------------------------------
            // Carte Expert
            //------------------------------------
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.08),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 34,
                    backgroundColor: gold,
                    child: Icon(Icons.person, color: navy, size: 34),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.expertName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Expert certifié Mentora",
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: const [
                            Icon(Icons.star, color: gold, size: 16),
                            SizedBox(width: 5),
                            Text(
                              "4.9",
                              style: TextStyle(
                                color: gold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "684 consultations",
                              style: TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            //------------------------------------
            // Réservation
            //------------------------------------
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.08),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.calendar_month, color: gold),
                      SizedBox(width: 10),
                      Text(
                        "Votre réservation",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SummaryRow(title: "Date", value: widget.selectedDate),
                  const SizedBox(height: 12),
                  _SummaryRow(title: "Heure", value: widget.selectedTime),
                  const SizedBox(height: 12),
                  const _SummaryRow(title: "Durée", value: "1 heure"),
                  const SizedBox(height: 12),
                  _SummaryRow(
                    title: "Brief IA",
                    value: widget.aiSummary.isEmpty ? "Aucun" : "Préparé ✓",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            //------------------------------------
            // Moyens de paiement
            //------------------------------------
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.08),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.payment, color: gold),
                      SizedBox(width: 10),
                      Text(
                        "Moyen de paiement",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...availablePaymentProviders.map((provider) {
                    final label = _paymentProviderLabel(provider);
                    final subtitle = _paymentProviderSubtitle(provider);
                    final icon = _paymentProviderIcon(provider);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PaymentMethodCard(
                        title: label,
                        subtitle: subtitle,
                        icon: icon,
                        selected: paymentMethod == provider,
                        onTap: () {
                          setState(() {
                            paymentMethod = provider;
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 22),

            //------------------------------------
            // Récapitulatif
            //------------------------------------
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.08),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.receipt_long, color: gold),
                      SizedBox(width: 10),
                      Text(
                        "Récapitulatif",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _SummaryRow(
                    title: "TOTAL",
                    value: "${money.format(total)} ${widget.currency}",
                    highlight: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            //------------------------------------
            // Conditions
            //------------------------------------
            CheckboxListTile(
              value: acceptedTerms,
              activeColor: gold,
              checkColor: navy,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text(
                "J'accepte les Conditions Générales d'Utilisation",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              onChanged: (value) {
                setState(() {
                  acceptedTerms = value!;
                });
              },
            ),
            const SizedBox(height: 20),

            //------------------------------------
            // Bouton Paiement
            //------------------------------------
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.lock),
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: navy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: acceptedTerms && !isProcessing
                    ? () async {
                        setState(() {
                          isProcessing = true;
                        });

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const _PaymentLoadingDialog(),
                        );

                        // Simulated provider outcome. Only this confirmed
                        // outcome may reach the Booking boundary below.
                        await Future.delayed(const Duration(seconds: 3));

                        // AD-022 decisions 11/12: the reservation is
                        // confirmed by Booking, never by this screen. A
                        // failed confirmation never becomes a success page.
                        var confirmed = false;
                        try {
                          if (context.mounted) {
                            await context
                                .read<BookingConfirmationApplicationService>()
                                .confirmPaid(widget.bookingId);
                            confirmed = true;
                          }
                        } on BookingConfirmationFailure {
                          confirmed = false;
                        } catch (_) {
                          confirmed = false;
                        }

                        if (context.mounted) {
                          Navigator.pop(context);

                          if (confirmed) {
                            AppRouter.replaceWithBookingSuccess(
                              context: context,
                              bookingId: widget.bookingId,
                              expertName: widget.expertName,
                              selectedDate: widget.selectedDate,
                              selectedTime: widget.selectedTime,
                              aiSummary: widget.aiSummary,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'La confirmation de la réservation a '
                                  'échoué. Le paiement sera '
                                  'vérifié ; réessayez ou '
                                  'contactez le support.',
                                ),
                              ),
                            );
                          }
                        }

                        setState(() {
                          isProcessing = false;
                        });
                      }
                    : null,
                label: Text(
                  "Payer ${money.format(total)} ${widget.currency}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user, color: Colors.greenAccent, size: 18),
                SizedBox(width: 8),
                Text(
                  "Paiement 100% sécurisé",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  static const navy = Color(0xFF061A3D);
  static const gold = Color(0xFFF5A400);

  const _PaymentMethodCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? gold.withOpacity(.12)
              : Colors.white.withOpacity(.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? gold : Colors.white12,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: selected ? gold : Colors.white12,
              child: Icon(icon, color: selected ? navy : gold),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(color: Colors.white54)),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: selected
                  ? const Icon(
                      Icons.check_circle,
                      color: gold,
                      key: ValueKey("selected"),
                    )
                  : const Icon(
                      Icons.radio_button_unchecked,
                      color: Colors.white24,
                      key: ValueKey("unselected"),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String title;
  final String value;
  final bool highlight;

  static const gold = Color(0xFFF5A400);

  const _SummaryRow({
    required this.title,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: highlight ? Colors.white : Colors.white70,
              fontSize: highlight ? 17 : 15,
              fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: highlight ? gold : Colors.white,
            fontSize: highlight ? 19 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _PaymentLoadingDialog extends StatelessWidget {
  const _PaymentLoadingDialog();

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFF5A400);

    return Dialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock, size: 70, color: gold),

            const SizedBox(height: 25),

            const Text(
              "Paiement sécurisé",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            const Text(
              "Traitement de votre paiement...",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 28),

            const CircularProgressIndicator(),

            const SizedBox(height: 28),

            Text(
              "Connexion au prestataire...",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
