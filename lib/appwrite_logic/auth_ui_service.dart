import 'package:flutter/material.dart';
import 'package:nofliesynck/appwrite_logic/auth_service.dart';

class AuthUIService extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _userData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get userData => _userData;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _setUserData(Map<String, dynamic>? data) {
    _userData = data;
    _isAuthenticated = data != null;
    notifyListeners();
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    _setLoading(true);
    _setError(null);

    final response = await _authService.registerUser(
      email: email,
      password: password,
      name: name,
    );

    _setLoading(false);

    if (!response.success) {
      _setError(response.message);
      return false;
    }

    return true;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    final response = await _authService.login(
      email: email,
      password: password,
    );

    _setLoading(false);

    if (!response.success) {
      _setError(response.message);
      return false;
    }

    _setUserData(response.data);
    return true;
  }

  Future<bool> logout() async {
    _setLoading(true);
    _setError(null);

    final response = await _authService.logout();

    _setLoading(false);

    if (!response.success) {
      _setError(response.message);
      return false;
    }

    _setUserData(null);
    return true;
  }

  Future<void> checkAuthStatus() async {
    _setLoading(true);
    _setError(null);

    final user = await _authService.getCurrentUser();

    if (user != null) {
      _setUserData({
        'userId': user.$id,
        'email': user.email,
        'name': user.name,
      });
    } else {
      _setUserData(null);
    }

    _setLoading(false);
  }

  Future<bool> requestPasswordReset(String email) async {
    _setLoading(true);
    _setError(null);

    final response = await _authService.requestPasswordReset(email);

    _setLoading(false);

    if (!response.success) {
      _setError(response.message);
      return false;
    }

    return true;
  }

  void clearError() {
    _setError(null);
  }
}
