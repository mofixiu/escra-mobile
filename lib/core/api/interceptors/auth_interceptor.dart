import 'package:dio/dio.dart';
import '../../secure_storage/secure_storage_service.dart';

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
}
