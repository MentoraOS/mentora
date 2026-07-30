import '../../engines/base_engine.dart';
import '../../services/logger_service.dart';
import '../../di/service_locater.dart';

import '../domains/authentication_domain.dart';
import '../models/auth_tokens.dart';
import '../models/identity.dart';
import '../services/token_service.dart';

class AuthenticationEngine extends BaseEngine {
  AuthenticationEngine._();

  static final AuthenticationEngine _instance = AuthenticationEngine._();

  static AuthenticationEngine get instance => _instance;

  AuthenticationDomain? _domain;

  final TokenService _tokenService = const TokenService();

  AuthTokens? _tokens;

  bool _initialized = false;

  Future<void> configure({required AuthenticationDomain domain}) async {
    _domain = domain;
  }

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    ServiceLocator.get<LoggerService>().info(
      'Authentication Engine initialized',
    );

    _initialized = true;

    await super.initialize();
  }

  bool get isConfigured => _domain != null;

  bool get isAuthenticated => _tokenService.isAuthenticated(_tokens);

  AuthTokens? get tokens => _tokens;

  Future<Identity?> currentIdentity() async {
    if (_domain == null) return null;

    return _domain!.currentIdentity();
  }

  Future<void> signOut() async {
    if (_domain == null) return;

    await _domain!.signOut();

    _tokens = null;
  }

  Future<void> updateTokens(AuthTokens tokens) async {
    _tokens = tokens;
  }

  Future<void> refreshIfNeeded() async {
    if (_domain == null) return;
    if (_tokens == null) return;

    if (!_tokenService.shouldRefresh(_tokens!)) {
      return;
    }

    _tokens = await _domain!.refreshTokens(refreshToken: _tokens!.refreshToken);
  }
}
