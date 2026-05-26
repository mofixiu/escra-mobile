import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure Storage Service wrapping standard platform keychains/keystores.
/// Used to keep API tokens, private local states, and user sessions safe from memory leaks/snooping.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'cached_user';
  static const String _pinKey = 'user_secure_pin';

  /// Saves the active authentication token (Bearer JWT)
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Retrieves the active authentication token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Removes the active token during Logout
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Saves a secure transaction PIN (e.g., custom numeric pad input)
  Future<void> savePin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
  }

  /// Retrieves the secure transaction PIN
  Future<String?> getPin() async {
    return await _storage.read(key: _pinKey);
  }

  /// Verifies a PIN matches the secure storage
  Future<bool> verifyPin(String pinToVerify) async {
    final savedPin = await getPin();
    if (savedPin == null) {
      // By default, seed "1234" for the demo if none exists
      return pinToVerify == "1234";
    }
    return savedPin == pinToVerify;
  }

  /// Saves user metadata JSON
  Future<void> saveUserData(String jsonStr) async {
    await _storage.write(key: _userKey, value: jsonStr);
  }

  /// Retrieves cached user metadata JSON
  Future<String?> getUserData() async {
    return await _storage.read(key: _userKey);
  }

  /// Completely wipes storage (Logout / Wipe actions)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
