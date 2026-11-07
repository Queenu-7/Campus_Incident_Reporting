import 'dart:async';

import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

/// Holds the login state. Screens listen to this class and rebuild
/// automatically when notifyListeners() is called.
class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();
  StreamSubscription? _subscription;

  AppUser? appUser; // null means nobody is logged in
  bool initializing = true; // true until we know if someone is logged in
  bool busy = false; // true while a request is running (show spinner)
  String? error; // message to show on screen
  bool needsVerification = false; // true if the user must verify email

  bool get isLoggedIn => appUser != null;
  bool get isStaff => appUser?.role == 'staff';

  AuthProvider() {
    // Listen for login/logout events from Firebase.
    _subscription = _service.authChanges.listen((user) async {
      if (user == null || !user.emailVerified) {
        appUser = null;
      } else {
        appUser = await _service.fetchUser(user.uid);
      }
      initializing = false;
      notifyListeners();
    });
  }

  // ---------- small helpers ----------

  void _startLoading() {
    busy = true;
    error = null;
    needsVerification = false;
    notifyListeners();
  }

  void _stopLoading() {
    busy = false;
    notifyListeners();
  }

  void _showError(Object e) {
    debugPrint('AUTH ERROR type: ${e.runtimeType}');
    debugPrint('AUTH ERROR value: $e');

    error = e.toString().replaceFirst('Exception: ', '');
    busy = false;
    notifyListeners();
  }

  void clearError() {
    error = null;
    needsVerification = false;
    notifyListeners();
  }

  // ---------- actions the screens can call ----------

  Future<bool> register(String name, String email, String password) async {
    _startLoading();
    try {
      await _service.register(name, email, password);
      _stopLoading();
      return true;
    } catch (e) {
      _showError(e);
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _startLoading();
    try {
      await _service.login(email, password);
      _stopLoading();
      return true;
    } on NotVerifiedException catch (e) {
      needsVerification = true;
      error = e.message;
      busy = false;
      notifyListeners();
      return false;
    } catch (e) {
      _showError(e);
      return false;
    }
  }

  Future<bool> resendVerification(String email, String password) async {
    _startLoading();
    try {
      await _service.resendVerification(email, password);
      _stopLoading();
      return true;
    } catch (e) {
      _showError(e);
      return false;
    }
  }

  Future<void> logout() => _service.logout();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
