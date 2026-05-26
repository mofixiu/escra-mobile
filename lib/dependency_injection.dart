import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import 'core/api/api_client.dart';
import 'core/api/interceptors/auth_interceptor.dart';
import 'core/api/interceptors/idempotency_interceptor.dart';
import 'core/secure_storage/secure_storage_service.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/domain/auth_controller.dart';
import 'features/escrow/data/repositories/escrow_repository.dart';
import 'features/escrow/domain/controllers/escrow_controller.dart';
import 'features/wallet/data/repositories/wallet_repository.dart';

final GetIt sl = GetIt.instance;

/// Bootstraps the dependency injection container.
/// All registrations are singletons so that a single source of truth
/// is shared across the entire widget tree.
void setupDependencies() {
  // ─── Core Layer ────────────────────────────────────────────────────────────

  // Secure Storage (Platform Keychain / Keystore)
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );

  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(sl<FlutterSecureStorage>()),
  );

  // Network Interceptors
  sl.registerLazySingleton<IdempotencyInterceptor>(() => IdempotencyInterceptor());

  sl.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(sl<SecureStorageService>()),
  );

  // Dio HTTP Client
  sl.registerLazySingleton<Dio>(() => Dio());

  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      sl<Dio>(),
      sl<AuthInterceptor>(),
      sl<IdempotencyInterceptor>(),
    ),
  );

  // ─── Auth Feature ──────────────────────────────────────────────────────────

  sl.registerLazySingleton<AuthRepository>(
    () => MockAuthRepository(sl<ApiClient>(), sl<SecureStorageService>()),
  );

  sl.registerLazySingleton<AuthController>(
    () => AuthController(sl<AuthRepository>()),
  );

  // ─── Wallet Feature ────────────────────────────────────────────────────────

  sl.registerLazySingleton<WalletRepository>(
    () => MockWalletRepository(sl<ApiClient>()),
  );

  // ─── Escrow Feature ────────────────────────────────────────────────────────

  sl.registerLazySingleton<EscrowRepository>(
    () => MockEscrowRepository(sl<ApiClient>()),
  );

  sl.registerLazySingleton<EscrowController>(
    () => EscrowController(sl<EscrowRepository>(), sl<AuthController>()),
  );
}
