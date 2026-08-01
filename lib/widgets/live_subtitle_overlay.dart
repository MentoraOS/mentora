import 'package:flutter/material.dart';

import 'subtitle_bubble.dart';
import 'subtitle_controller.dart';

/// Where the subtitles sit over the video. Adaptable today, extensible
/// without a redesign.
enum SubtitlePosition { top, center, bottom }

/// The live subtitle overlay — a discreet, reusable projection of the
/// translated flux over the consultation video.
///
/// Pure presentation: it renders what the [SubtitleController] holds,
/// never blocks the video (pointer-transparent), never scrolls (the flux
/// stays alive) and animates softly in and out. Future evolutions —
/// single-language mode, custom size/color, accessibility — are new
/// parameters here, not new architecture.
class LiveSubtitleOverlay extends StatelessWidget {
  const LiveSubtitleOverlay({
    super.key,
    required this.controller,
    this.position = SubtitlePosition.bottom,
  });

  final SubtitleController controller;
  final SubtitlePosition position;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: switch (position) {
          SubtitlePosition.top => Alignment.topCenter,
          SubtitlePosition.center => Alignment.center,
          SubtitlePosition.bottom => Alignment.bottomCenter,
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              final visible = controller.visible;
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: Column(
                  key: ValueKey(
                    visible.map((chunk) => chunk.createdAt).join('|'),
                  ),
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final chunk in visible) SubtitleBubble(chunk: chunk),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
