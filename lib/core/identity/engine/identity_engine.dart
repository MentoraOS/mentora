import '../entities/identity.dart';
import '../entities/membership.dart';
import '../../experience/engine/experience_engine.dart';
import '../../../core/identity/models/session.dart';
import '../../../core/identity/models/device.dart';
import '../../../core/identity/models/locale_preferences.dart';
import '../domains/session_domain.dart';
import '../domains/device_domain.dart';
import '../domains/locale_domain.dart';

class IdentityEngine {
  IdentityEngine._();

  static Identity? _currentIdentity;
  static Membership? _currentMembership;
  static final List<Membership> _memberships = [];

  static Session? _currentSession;

  static Device? _currentDevice;

  static final SessionDomain _sessionDomain = SessionDomain();
  static final DeviceDomain _deviceDomain = DeviceDomain();

  static final LocaleDomain _localeDomain = LocaleDomain();

  static LocalePreferences? _localePreferences;

  static Identity? get currentIdentity => _currentIdentity;
  static Membership? get currentMembership => _currentMembership;

  static List<Membership> get memberships => List.unmodifiable(_memberships);

  static bool get hasIdentity => _currentIdentity != null;
  static bool get hasMembership => _currentMembership != null;

  static String? get identityId => _currentIdentity?.id;
  static String? get email => _currentIdentity?.email;
  static String get fullName => _currentIdentity?.fullName ?? '';

  static String? get workspaceId => _currentMembership?.workspaceId;
  static String? get workspaceType => _currentMembership?.workspaceType;
  static String? get role => _currentMembership?.role;
  static String? get departmentId => _currentMembership?.departmentId;
  static String? get teamId => _currentMembership?.teamId;

  static Session? get currentSession => _sessionDomain.currentSession;

  static bool get isSessionValid => _sessionDomain.isSessionValid;

  static bool get isSessionExpired => _sessionDomain.isSessionExpired;

  static Device? get currentDevice => _deviceDomain.currentDevice;

  static bool get hasDevice => _deviceDomain.hasDevice;

  static LocalePreferences? get localePreferences => _localeDomain.preferences;

  static bool get hasLocalePreferences => _localeDomain.hasPreferences;

  static bool get isAuthenticated =>
      _currentIdentity != null && _currentSession != null;

  static List<String> get permissions => _currentMembership?.permissions ?? [];

  static bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  static bool hasRole(String requiredRole) {
    return role == requiredRole;
  }

  static void setIdentity(Identity identity) {
    _currentIdentity = identity;
  }

  static void startSession(Session session) {
    _sessionDomain.start(session);
    _currentSession = session;
  }

  static void setDevice(Device device) {
    _deviceDomain.register(device);
    _currentDevice = device;
  }

  static void updatePushToken(String pushToken) {
    _deviceDomain.updatePushToken(pushToken);
    _currentDevice = _deviceDomain.currentDevice;
  }

  static void markDeviceTrusted() {
    _deviceDomain.markTrusted();
    _currentDevice = _deviceDomain.currentDevice;
  }

  static void setLocalePreferences(LocalePreferences preferences) {
    _localeDomain.setPreferences(preferences);
    _localePreferences = preferences;
  }

  static void endSession() {
    _sessionDomain.end();
    _deviceDomain.clear();
    _localeDomain.clear();
    _currentSession = null;
    _currentDevice = null;
  }

  static void refreshActivity() {
    _sessionDomain.refreshActivity();
    _currentSession = _sessionDomain.currentSession;
  }

  static void setMemberships(List<Membership> memberships) {
    _memberships
      ..clear()
      ..addAll(memberships);
  }

  static bool switchMembership(String workspaceId) {
    for (final membership in _memberships) {
      if (membership.workspaceId == workspaceId && membership.active) {
        _currentMembership = membership;
        ExperienceEngine.resolveFromRole(membership.role);
        return true;
      }
    }

    return false;
  }

  static void clear() {
    _currentIdentity = null;
    _currentMembership = null;
    _memberships.clear();
    _localeDomain.clear();

    _currentSession = null;
    _currentDevice = null;
    _localePreferences = null;
  }
}
