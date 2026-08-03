import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';

/// The playground's own state: locale under preview and a motion
/// replay counter. Appearance toggles go straight to the official
/// AppearanceEngine — the playground exercises the real engines, it
/// never duplicates them.
final class PlaygroundController extends ChangeNotifier {
  Locale _locale = const Locale('en');
  int _motionReplays = 0;

  Locale get locale => _locale;
  int get motionReplays => _motionReplays;

  void selectLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  void replayMotion() {
    _motionReplays++;
    notifyListeners();
  }
}
