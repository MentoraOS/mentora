import '../models/auth_tokens.dart';

class TokenService {
  const TokenService();

  bool shouldRefresh(AuthTokens tokens) {
    if (tokens.isRefreshExpired) {
      return false;
    }

    return tokens.accessRemaining.inMinutes <= 5;
  }

  bool canRefresh(AuthTokens tokens) {
    return !tokens.isRefreshExpired;
  }

  bool isAuthenticated(AuthTokens? tokens) {
    if (tokens == null) return false;

    return !tokens.isRefreshExpired;
  }
}
