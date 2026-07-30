import '../models/locale_preferences.dart';

class LocaleDomain {
  LocalePreferences? _preferences;

  LocalePreferences? get preferences => _preferences;

  bool get hasPreferences => _preferences != null;

  void setPreferences(LocalePreferences preferences) {
    _preferences = preferences;
  }

  void clear() {
    _preferences = null;
  }
}
