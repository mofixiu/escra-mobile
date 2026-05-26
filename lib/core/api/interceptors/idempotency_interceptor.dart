import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

/// Network interceptor generating a secure fresh UUID on any POST, PUT or PATCH request.
/// Standardizes idempotency across the application, protecting client funding, transfers
/// or releases from repeated execution during network retries or double clicks.
class IdempotencyInterceptor extends Interceptor {
  final Uuid _uuid = const Uuid();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Generate fresh idempotency keys automatically on modifying requests
    final method = options.method.toUpperCase();
    if (method == 'POST' || method == 'PUT' || method == 'PATCH') {
      if (!options.headers.containsKey('Idempotency-Key')) {
        options.headers['Idempotency-Key'] = _uuid.v4();
      }
    }
    super.onRequest(options, handler);
  }
}
