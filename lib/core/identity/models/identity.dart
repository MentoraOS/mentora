import 'account.dart';
import 'device.dart';
import 'locale_preferences.dart';

class Identity {
  final Account account;

  /// Workspace actuellement actif
  final String workspaceId;

  /// Organisation actuellement active
  final String organizationId;

  /// Rôle actuel
  final String role;

  /// Préférences internationales
  final LocalePreferences locale;

  /// Appareil actuellement utilisé
  final Device device;

  const Identity({
    required this.account,
    required this.workspaceId,
    required this.organizationId,
    required this.role,
    required this.locale,
    required this.device,
  });
}
