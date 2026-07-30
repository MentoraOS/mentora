/// Public API for the Mentora Identity module.
///
/// External modules should import this file instead of importing
/// implementation files from this module directly.
///
/// Sprint -1.2 / Lot C — Public Module Boundaries.
export 'domains/authentication_domain.dart';
export 'domains/identity_domain.dart';
export 'engine/authentication_engine.dart';
export 'engine/identity_engine.dart';
export 'entities/identity.dart';
export 'entities/membership.dart';
export 'entities/permission.dart';
export 'entities/role.dart' hide IdentityPermission;
export 'models/account.dart';
export 'models/auth_tokens.dart';
export 'models/session.dart';
export 'repositories/authentication_repository.dart';
export 'services/token_service.dart';
export '../../domain/authentication/authentication_service.dart';
export 'services/authentication_failure.dart';
