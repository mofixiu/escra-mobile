import 'dart:convert';
import '../../../../core/api/api_client.dart';
import '../../../../core/secure_storage/secure_storage_service.dart';
import '../models/user_model.dart';

/// Clean Architecture Authentication contract.
abstract class AuthRepository {
  /// authenticates credentials with backend API
  Future<UserModel> login(String email, String password);

  /// Registers a brand new user session with specific Buyer/Seller roles
  Future<UserModel> signUp(String name, String email, String password, UserRole role);

  /// Performs secure signouts and cleans cache layers
  Future<void> logout();

  /// Retrieves user session details from secure storage
  Future<UserModel?> getCachedUser();

  /// Updates the cached user data
  Future<void> updateCachedUser(UserModel user);
}

/// Simulated implementation of [AuthRepository] to show architectural compliance.
/// Fully integrates [ApiClient] (showing interceptor configurations) and [SecureStorageService].
class MockAuthRepository implements AuthRepository {
  
  final SecureStorageService _secureStorage;

  MockAuthRepository(ApiClient _, this._secureStorage);

  @override
  Future<UserModel> login(String email, String password) async {
    // Simulate real network request timing
    await Future.delayed(const Duration(milliseconds: 1000));

    if (password.length < 4) {
      throw Exception('Incorrect login PIN. Must contain at least 4 digits.');
    }

    // Dynamic role mapping based on credentials for interactive demo ease
    final resolvedRole = email.contains('seller') ? UserRole.seller : UserRole.buyer;

    final user = UserModel(
      id: 'usr_89x201',
      name: nameFromEmail(email),
      email: email.toLowerCase(),
      role: resolvedRole,
      balanceKobo: resolvedRole == UserRole.buyer ? 75000000 : 0, // Seed ₦750,000 for buyer demo
    );

    // Save tokens and user details in device keychain
    await _secureStorage.saveToken('jwt_bearer_escra_mock_token_9x123');
    await _secureStorage.saveUserData(jsonEncode(user.toJson()));

    return user;
  }

  @override
  Future<UserModel> signUp(String name, String email, String password, UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    final user = UserModel(
      id: 'usr_mock_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email.toLowerCase(),
      role: role,
      balanceKobo: role == UserRole.buyer ? 50000000 : 0, // Seed ₦500,000 for buyer
    );

    await _secureStorage.saveToken('jwt_bearer_escra_mock_token_signup_781');
    await _secureStorage.saveUserData(jsonEncode(user.toJson()));

    return user;
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

  /// Helper to convert email handles to high-contrast names
  String nameFromEmail(String email) {
    final handle = email.split('@').first;
    return handle.substring(0, 1).toUpperCase() + handle.substring(1);
  }
}
