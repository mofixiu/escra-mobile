import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../secure_storage/secure_storage_service.dart';
import '../../../features/auth/domain/auth_controller.dart';

/// Network interceptor to automatically fetch and attach the `Authorization: Bearer token` header
/// for all protected HTTP endpoints. Opt-out is possible by setting extra['requiresAuth'] = false.
class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorageService;

  AuthInterceptor(this._secureStorageService);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Allow bypassing auth on public endpoints (e.g. login, sign up)
    final bool requiresAuth = options.extra['requiresAuth'] ?? true;

    if (requiresAuth) {
      final token = await _secureStorageService.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      final bool requiresAuth = err.requestOptions.extra['requiresAuth'] ?? true;
      if (requiresAuth) {
        // Log user out globally if token expired / unauthorized
        try {
          final authController = GetIt.I<AuthController>();
          authController.logout();
        } catch (_) {
          // If GetIt not yet initialized or other error, clear local storage fallback
          _secureStorageService.deleteToken();
          _secureStorageService.clearAll();
        }
      }
    }
    super.onError(err, handler);
  }
}
