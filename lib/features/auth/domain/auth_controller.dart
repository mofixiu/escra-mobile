import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

/// Authentication state controller managing local session caching,
/// reactive UI data streams, and core security domain safeguards like Lockout timers.
class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Security Lockout mechanisms (3 failed attempts lock login for 30s)
  int _failedAttempts = 0;
  DateTime? _lockoutEndTime;
  Timer? _lockoutTimer;
  int _lockoutSecondsRemaining = 0;

  AuthController(this._authRepository) {
    _loadSession();
  }

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  /// Checks if security lockout state is active
  bool get isLockedOut {
    if (_lockoutEndTime == null) return false;
    final isLocked = DateTime.now().isBefore(_lockoutEndTime!);
    if (!isLocked) {
      _failedAttempts = 0;
      _lockoutEndTime = null;
    }
    return isLocked;
  }

  int get lockoutSecondsRemaining => _lockoutSecondsRemaining;

  /// Restores cached sessions during app bootstrap
  Future<void> _loadSession() async {
    _isLoading = true;
    notifyListeners();

    _currentUser = await _authRepository.getCachedUser();

    _isLoading = false;
    notifyListeners();
  }

  /// Exposes standard interface to adjust active user balances securely
  void updateBalance(int newBalanceKobo) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(balanceKobo: newBalanceKobo);
      _authRepository.updateCachedUser(_currentUser!);
      notifyListeners();
    }
  }

  /// Authenticates user session
  Future<bool> login(String email, String password) async {
    if (isLockedOut) {
      _errorMessage = 'Locked. Try again in $_lockoutSecondsRemaining seconds.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.login(email, password);
      _failedAttempts = 0;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _failedAttempts++;
      if (_failedAttempts >= 3) {
        _lockoutEndTime = DateTime.now().add(const Duration(seconds: 30));
        _startLockoutCountdown();
      }
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Registers fresh sessions
  Future<bool> signUp(String name, String email, String password, UserRole role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.signUp(name, email, password, role);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Terminate active session and purge caches
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authRepository.logout();
    _currentUser = null;
    _errorMessage = null;

    _isLoading = false;
    notifyListeners();
  }

  /// Lockout countdown trigger
  void _startLockoutCountdown() {
    _lockoutTimer?.cancel();
    _lockoutSecondsRemaining = 30;
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_lockoutSecondsRemaining > 0) {
        _lockoutSecondsRemaining--;
        notifyListeners();
      } else {
        _lockoutTimer?.cancel();
        _failedAttempts = 0;
        _lockoutEndTime = null;
        _errorMessage = null;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }
}
