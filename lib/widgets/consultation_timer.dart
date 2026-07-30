import 'dart:async';
import 'package:flutter/material.dart';

class ConsultationTimer extends StatefulWidget {
  final int ratePerMinute;
  final Function(String elapsedTime, String amount) onUpdate;

  const ConsultationTimer({
    super.key,
    required this.ratePerMinute,
    required this.onUpdate,
  });

  @override
  State<ConsultationTimer> createState() => _ConsultationTimerState();
}

class _ConsultationTimerState extends State<ConsultationTimer> {
  int seconds = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      seconds++;

      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;

      final elapsed =
          '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';

      final amountValue = (seconds / 60 * widget.ratePerMinute).round();
      final amount = '$amountValue FCFA';

      widget.onUpdate(elapsed, amount);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
