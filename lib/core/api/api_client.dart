import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/idempotency_interceptor.dart';

/// Central API Client orchestrating Dio network calls.
/// Houses the interceptors so that features/domain logic are protected 
/// and entirely oblivious to bearer token attachments or idempotency headers.
class ApiClient {
  final Dio dio;

  ApiClient(
    this.dio,
    AuthInterceptor authInterceptor,
    IdempotencyInterceptor idempotencyInterceptor,
  ) {
    dio.options = BaseOptions(
      baseUrl: 'https://escra-payment-backend.onrender.com/api/v1',
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      contentType: Headers.jsonContentType,
    );

    // Attach our interceptors
    dio.interceptors.addAll([
      authInterceptor,
      idempotencyInterceptor,
      // Development logger: debug builds only, and never headers or bodies,
      // which carry bearer tokens, passwords and PINs.
      if (kDebugMode)
        LogInterceptor(
          requestHeader: false,
          requestBody: false,
          responseHeader: false,
          responseBody: false,
          error: true,
        ),
    ]);
  }

  /// GET request wrapper
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  /// POST request wrapper
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  /// PUT request wrapper
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);
  }

  /// DELETE request wrapper
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
  }
}
