import 'package:cloud_firestore/cloud_firestore.dart';

import '../repositories/withdrawal_repository_impl.dart';
import '../../domain/repositories/withdrawal_repository.dart';

import '../../features/enterprise/data/repositories/firestore_enterprise_member_repository.dart';
import '../../features/enterprise/domain/usecases/get_enterprise_members_usecase.dart';
import '../../features/enterprise/domain/usecases/invite_enterprise_member_usecase.dart';
import '../../features/enterprise/domain/usecases/remove_enterprise_member_usecase.dart';
import '../../features/enterprise/domain/usecases/update_enterprise_member_role_usecase.dart';

import '../services/logger_service.dart';
import '../services/cache_service.dart';
import '../config/config_service.dart';
import '../services/storage_service.dart';

class ServiceLocator {
  ServiceLocator._();

  static final Map<Type, Object> _services = {};

  static void register<T extends Object>(T service) {
    _services[T] = service;
  }

  static T get<T extends Object>() {
    final service = _services[T];

    if (service == null) {
      throw Exception('Service $T has not been registered.');
    }

    return service as T;
  }

  static void setupForTests() {
    clear();

    register<LoggerService>(LoggerService());
    register<CacheService>(CacheService());
    register<ConfigService>(ConfigService());
    register<StorageService>(StorageService());
  }

  static bool contains<T extends Object>() {
    return _services.containsKey(T);
  }

  static void clear() {
    _services.clear();
  }

  static void setup() {
    register<StorageService>(StorageService());
    register<CacheService>(CacheService());
    register<ConfigService>(ConfigService());
    register<LoggerService>(LoggerService());
    register<LoggerService>(LoggerService());

    register<WithdrawalRepository>(const WithdrawalRepositoryImpl());

    register<FirestoreEnterpriseMemberRepository>(
      FirestoreEnterpriseMemberRepository(
        firestore: FirebaseFirestore.instance,
      ),
    );

    final enterpriseRepo = get<FirestoreEnterpriseMemberRepository>();

    register<GetEnterpriseMembersUseCase>(
      GetEnterpriseMembersUseCase(enterpriseRepo),
    );

    register<InviteEnterpriseMemberUseCase>(
      InviteEnterpriseMemberUseCase(enterpriseRepo),
    );

    register<RemoveEnterpriseMemberUseCase>(
      RemoveEnterpriseMemberUseCase(enterpriseRepo),
    );

    register<UpdateEnterpriseMemberRoleUseCase>(
      UpdateEnterpriseMemberRoleUseCase(enterpriseRepo),
    );
  }
}
