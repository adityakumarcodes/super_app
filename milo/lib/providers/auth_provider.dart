import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_better_auth/flutter_better_auth.dart';
import 'package:flutter_better_auth/plugins/email_otp/email_otp_plugin.dart';
import 'package:milo/services/app_config.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._client) {
    _authSubscription = _client.onAuthChange.listen((user) {
      final isAuthenticated = user != null;
      if (_isAuthenticated == isAuthenticated && _user == user) return;
      _user = user;
      _isAuthenticated = isAuthenticated;
      notifyListeners();
    });
  }

  final BetterAuthClient _client;
  late final StreamSubscription<User?> _authSubscription;

  User? _user;
  bool _isAuthenticated = false;
  bool _isRestoring = true;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isRestoring => _isRestoring;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> restoreSession() async {
    try {
      final result = await _client.getSession().timeout(
        AppConfig.requestTimeout,
      );
      _user = result.data?.user;
      _isAuthenticated = _user != null;
      _error = result.error?.message;
    } catch (_) {
      _user = null;
      _isAuthenticated = false;
      _error = 'Could not connect to the server. Check your connection.';
    } finally {
      _isRestoring = false;
      notifyListeners();
    }
  }

  Future<bool> sendOtp(String email) {
    return _runRequest(() async {
      final result = await _client.emailOtp.sendVerification(
        email: email.trim(),
        type: 'sign-in',
      );
      if (result.data != null) return null;
      return result.error?.message ?? 'Could not send the OTP.';
    });
  }

  Future<bool> verifyOtp({required String email, required String otp}) async {
    final succeeded = await _runRequest(() async {
      final result = await _client.emailOtp.signIn(
        email: email.trim(),
        otp: otp,
      );
      final response = result.data;
      if (response == null) {
        return result.error?.message ?? 'Could not sign in with this OTP.';
      }
      _user = response.user;
      return null;
    });

    if (succeeded) {
      _isAuthenticated = true;
      notifyListeners();
    }
    return succeeded;
  }

  Future<bool> signOut() async {
    final succeeded = await _runRequest(() async {
      final result = await _client.signOut();
      return result.error?.message;
    });

    if (succeeded) {
      _user = null;
      _isAuthenticated = false;
      notifyListeners();
    }
    return succeeded;
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  Future<bool> _runRequest(Future<String?> Function() request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _error = await request().timeout(AppConfig.requestTimeout);
      return _error == null;
    } catch (_) {
      _error = 'Could not connect to the server. Try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
