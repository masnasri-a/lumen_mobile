import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final _authService = AuthService();

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  String? _error;
  bool _loading = false;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  bool get loading => _loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // ── Init: check stored token ─────────────────────────────────────────────────

  Future<void> init() async {
    try {
      final hasToken = await ApiClient.hasToken();
      if (!hasToken) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return;
      }
      _user = await _authService.getMe();
      _status = AuthStatus.authenticated;
    } catch (_) {
      await ApiClient.clearTokens();
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ── Register ─────────────────────────────────────────────────────────────────

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final result = await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      _user = result.user;
      _status = AuthStatus.authenticated;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────────

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final result = await _authService.login(email: email, password: password);
      _user = result.user;
      _status = AuthStatus.authenticated;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Google Login ──────────────────────────────────────────────────────────────

  Future<bool> loginWithGoogle(String idToken) async {
    _setLoading(true);
    try {
      final result = await _authService.loginWithGoogle(idToken);
      _user = result.user;
      _status = AuthStatus.authenticated;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Update Profile ────────────────────────────────────────────────────────────

  Future<bool> updateProfile({required String name}) async {
    _setLoading(true);
    try {
      _user = await _authService.updateProfile(name: name);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
