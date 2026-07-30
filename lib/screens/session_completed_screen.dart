import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../core/engines/financial/ledger/financial_ledger_factory.dart';
import '../core/engines/financial/ledger/models/ledger_entry.dart';
import '../core/engines/financial/ledger/models/ledger_transaction.dart';
import '../core/engines/financial/ledger/models/ledger_transaction_status.dart';
import '../core/engines/financial/ledger/models/ledger_transaction_type.dart';
import '../core/engines/financial/commissions/commission_engine.dart';

class SessionCompletedScreen extends StatefulWidget {
  final String bookingId;

  const SessionCompletedScreen({super.key, required this.bookingId});

  @override
  State<SessionCompletedScreen> createState() => _SessionCompletedScreenState();
}

class _SessionCompletedScreenState extends State<SessionCompletedScreen> {
  int rating = 0;
  final TextEditingController commentController = TextEditingController();

  static const navy = Color(0xFF061A3D);
  static const gold = Color(0xFFF5A400);

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> downloadReceiptPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(30),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'MENTORA',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 8),

                pw.Text('Reçu de consultation'),

                pw.SizedBox(height: 30),

                pw.Text('Booking ID : ${widget.bookingId}'),
                pw.Text('Expert : Moussa Keita'),
                pw.Text('Durée : 60 minutes'),
                pw.Text('Montant : 50 000 FCFA'),
                pw.Text('Statut : Terminée'),

                pw.SizedBox(height: 30),

                pw.Text(
                  'Résumé Mentora AI',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),

                pw.SizedBox(height: 10),

                pw.Text(
                  'La consultation a permis de clarifier les objectifs, identifier les priorités et définir les prochaines étapes.',
                ),

                pw.SizedBox(height: 30),

                pw.Text('Merci d’avoir utilisé Mentora.'),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Future<void> submitReview() async {
    if (rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir une note')),
      );
      return;
    }

    final bookingDoc = await FirebaseFirestore.instance
        .collection('bookings')
        .doc(widget.bookingId)
        .get();

    final booking = bookingDoc.data() ?? {};

    if (booking['escrowReleased'] == true) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cette consultation a déjà été clôturée financièrement.',
          ),
        ),
      );

      return;
    }

    final amount = booking['amount'] ?? 50000;
    final expertId = booking['expertId'] ?? 'unknown_expert';
    final clientId = booking['clientId'] ?? 'unknown_client';
    final countryCode = booking['countryCode'] ?? 'ML';
    final currency = booking['currency'] ?? 'XOF';

    final commission = CommissionEngine.calculate(
      amount: amount,
      commissionPercent: 20,
    );

    final ledger = FinancialLedgerFactory.firestore();

    await ledger.recordTransaction(
      LedgerTransaction(
        id: 'ledger_release_${widget.bookingId}',
        reference: widget.bookingId,
        transactionType: LedgerTransactionType.escrowRelease,
        status: LedgerTransactionStatus.posted,
        bookingId: widget.bookingId,
        clientId: clientId,
        expertId: expertId,
        countryCode: countryCode,
        currency: currency,
        provider: 'internal',
        createdAt: DateTime.now(),
        entries: [
          LedgerEntry(
            accountId: 'escrow_${widget.bookingId}',
            type: LedgerEntryType.debit,
            amount: amount,
          ),
          LedgerEntry(
            accountId: 'expert_wallet_$expertId',
            type: LedgerEntryType.credit,
            amount: commission.expertAmount,
          ),
          LedgerEntry(
            accountId: 'platform_revenue_$countryCode',
            type: LedgerEntryType.credit,
            amount: commission.platformFee,
          ),
        ],
        metadata: {
          'grossAmount': commission.grossAmount,
          'expertAmount': commission.expertAmount,
          'platformFee': commission.platformFee,
          'commissionPercent': 20,
        },
      ),
    );

    await FirebaseFirestore.instance
        .collection('bookings')
        .doc(widget.bookingId)
        .update({
          'rating': rating,
          'reviewComment': commentController.text.trim(),
          'reviewedAt': FieldValue.serverTimestamp(),
          'status': 'completed',
          'escrowReleased': true,
          'escrowReleasedAt': FieldValue.serverTimestamp(),

          'postConsultationSummary':
              'La consultation a permis de clarifier les objectifs, identifier les priorités et définir les prochaines étapes.',
          'postConsultationActions': [
            'Structurer le plan d’action',
            'Préparer les documents clés',
            'Suivre les recommandations',
            'Planifier une prochaine session',
          ],
          'updatedAt': FieldValue.serverTimestamp(),
          'completedAt': FieldValue.serverTimestamp(),
        });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Merci pour votre évaluation')),
    );

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        title: const Text('Session terminée'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const _SuccessHero(),

            const SizedBox(height: 24),

            const _PremiumCard(
              icon: Icons.receipt_long,
              title: 'Résumé de la session',
              child: Column(
                children: [
                  _InfoRow(label: 'Expert', value: 'Moussa Keita'),
                  _InfoRow(label: 'Durée', value: '60 minutes'),
                  _InfoRow(label: 'Montant', value: '50 000 FCFA'),
                  _InfoRow(label: 'Statut', value: 'Terminée'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const _PremiumCard(
              icon: Icons.auto_awesome,
              title: 'Résumé Mentora AI',
              child: Text(
                'La consultation a permis de clarifier les objectifs, identifier les priorités et définir les prochaines étapes.',
                style: TextStyle(color: Colors.white70, height: 1.5),
              ),
            ),

            const SizedBox(height: 16),

            const _PremiumCard(
              icon: Icons.task_alt,
              title: 'Actions recommandées',
              child: Column(
                children: [
                  _ActionRow(text: 'Structurer le plan d’action'),
                  _ActionRow(text: 'Préparer les documents clés'),
                  _ActionRow(text: 'Suivre les recommandations'),
                  _ActionRow(text: 'Planifier une prochaine session'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _PremiumCard(
              icon: Icons.star,
              title: 'Évaluez votre expert',
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final star = index + 1;
                      return IconButton(
                        onPressed: () => setState(() => rating = star),
                        icon: Icon(
                          rating >= star ? Icons.star : Icons.star_border,
                          color: gold,
                          size: 36,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentController,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Laissez un commentaire...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withOpacity(.07),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: downloadReceiptPdf,
                icon: const Icon(Icons.download),
                label: const Text('Télécharger le résumé PDF'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                icon: const Icon(Icons.home),
                label: const Text('Retour à l’accueil'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: gold,
                  side: const BorderSide(color: gold),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SuccessHero extends StatelessWidget {
  const _SuccessHero();

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFF5A400);
    const navy = Color(0xFF061A3D);

    return Column(
      children: [
        Container(
          width: 105,
          height: 105,
          decoration: BoxDecoration(
            color: gold,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: gold.withOpacity(.35),
                blurRadius: 35,
                spreadRadius: 6,
              ),
            ],
          ),
          child: const Icon(Icons.check_rounded, color: navy, size: 64),
        ),
        const SizedBox(height: 22),
        const Text(
          'Consultation terminée',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Merci d’avoir utilisé Mentora.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}

class _PremiumCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _PremiumCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFF5A400);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: gold),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFF5A400);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(color: gold, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String text;

  const _ActionRow({required this.text});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFF5A400);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: gold, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
