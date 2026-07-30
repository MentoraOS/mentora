import '../models/identity.dart';

class IdentityDomain {
  Identity? _currentIdentity;

  Identity? get currentIdentity => _currentIdentity;

  bool get hasIdentity => _currentIdentity != null;

  void setIdentity(Identity identity) {
    _currentIdentity = identity;
  }

  void clearIdentity() {
    _currentIdentity = null;
  }
}
