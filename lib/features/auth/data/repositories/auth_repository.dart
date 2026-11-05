import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/secure_storage/secure_storage_service.dart';
import '../models/user_model.dart';

/// Clean Architecture Authentication contract.
abstract class AuthRepository {
  /// authenticates credentials with backend API
  Future<UserModel> login(String phone, String password);

  /// Registers a brand new user session with specific Buyer/Seller roles
  Future<UserModel> signUp({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String pin,
    String? email,
    required UserRole role,
  });

  /// Performs secure signouts and cleans cache layers
  Future<void> logout();

  /// Retrieves user session details from secure storage
  Future<UserModel?> getCachedUser();

  /// Updates the cached user data
  Future<void> updateCachedUser(UserModel user);

  /// Fetches latest user profile from server
  Future<Map<String, dynamic>> getProfile();

  /// Checks backend health status
  Future<bool> checkHealth();
}

/// Real HTTP implementation of [AuthRepository] interacting with the ESCRA backend.
class HttpAuthRepository implements AuthRepository {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  HttpAuthRepository(this._apiClient, this._secureStorage);

  @override
  Future<UserModel> login(String phone, String password) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'phone': phone,
          'password': password,
        },
        options: Options(extra: {'requiresAuth': false}),
      );

      final data = response.data!;
      final token = data['access_token'] as String;

      // Save token first so that AuthInterceptor can use it to fetch balance
      await _secureStorage.saveToken(token);

      // Fetch wallet balance
      int balanceKobo = 0;
      try {
        final balanceRes = await _apiClient.get<Map<String, dynamic>>('/wallets/balance');
        balanceKobo = balanceRes.data!['balance_kobo'] as int? ?? 0;
      } catch (_) {
        // Fallback to 0 if balance fails
      }

      final userJson = data['user'] as Map<String, dynamic>;
      final user = UserModel(
        id: userJson['id'] as String,
        name: '${userJson['first_name'] ?? ''} ${userJson['last_name'] ?? ''}'.trim(),
        email: userJson['email'] as String? ?? '',
        role: (userJson['role'] as String? ?? 'buyer').toLowerCase() == 'buyer'
            ? UserRole.buyer
            : UserRole.seller,
        balanceKobo: balanceKobo,
      );

      await _secureStorage.saveUserData(jsonEncode(user.toJson()));
      return user;
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Login failed.';
        throw Exception(errorMsg);
      }
      rethrow;
    }
  }

  @override
  Future<UserModel> signUp({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String pin,
    String? email,
    required UserRole role,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'phone': phone,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'pin': pin,
          'role': role == UserRole.seller ? 'seller' : 'buyer',
          if (email != null && email.isNotEmpty) 'email': email,
        },
        options: Options(extra: {'requiresAuth': false}),
      );

      final data = response.data!;
      final token = data['access_token'] as String;

      await _secureStorage.saveToken(token);

      // Fetch wallet balance (0 for a new user, but good to check)
      int balanceKobo = 0;
      try {
        final balanceRes = await _apiClient.get<Map<String, dynamic>>('/wallets/balance');
        balanceKobo = balanceRes.data!['balance_kobo'] as int? ?? 0;
      } catch (_) {
        // Fallback to 0
      }

      final userJson = data['user'] as Map<String, dynamic>;
      final user = UserModel(
        id: userJson['id'] as String,
        name: '${userJson['first_name'] ?? ''} ${userJson['last_name'] ?? ''}'.trim(),
        email: userJson['email'] as String? ?? '',
        role: role, // Use local requested role since backend might default/not return it
        balanceKobo: balanceKobo,
      );

      await _secureStorage.saveUserData(jsonEncode(user.toJson()));
      return user;
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Registration failed.';
        throw Exception(errorMsg);
      }
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await _secureStorage.deleteToken();
    await _secureStorage.clearAll();
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final cachedStr = await _secureStorage.getUserData();
    if (cachedStr != null) {
      try {
        return UserModel.fromJson(jsonDecode(cachedStr));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> updateCachedUser(UserModel user) async {
    await _secureStorage.saveUserData(jsonEncode(user.toJson()));
  }

  @override
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('/users/profile');
      final data = response.data!;
      final user = UserModel(
        id: data['id'] as String,
        name: '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}'.trim(),
        email: data['email'] as String? ?? '',
        role: (data['role'] as String? ?? 'buyer').toLowerCase() == 'buyer'
            ? UserRole.buyer
            : UserRole.seller,
        balanceKobo: 0,
      );
      final currentCached = await getCachedUser();
      if (currentCached != null) {
        final updatedUser = user.copyWith(balanceKobo: currentCached.balanceKobo);
        await updateCachedUser(updatedUser);
      } else {
        await updateCachedUser(user);
      }
      return data;
    } catch (e) {
      if (e is DioException) {
        final errorMsg = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Failed to load profile.';
        throw Exception(errorMsg);
      }
      rethrow;
    }
  }

  @override
  Future<bool> checkHealth() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('/health', options: Options(extra: {'requiresAuth': false}));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
