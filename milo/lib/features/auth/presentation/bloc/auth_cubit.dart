import 'dart:async';

import 'package:flutter_better_auth/plugins/email_otp/email_otp_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_better_auth/flutter_better_auth.dart';
import 'package:milo/services/app_config.dart';

class AuthState {
  const AuthState({
    this.user,
    this.isRestoring = true,
    this.isLoading = false,
    this.error,
  });

  final User? user;
  final bool isRestoring;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isRestoring,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) => AuthState(
    user: user ?? this.user,
    isRestoring: isRestoring ?? this.isRestoring,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : error ?? this.error,
  );
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._client) : super(const AuthState()) {
    _authSubscription = _client.onAuthChange.listen(
      (user) => emit(AuthState(user: user, isRestoring: false)),
    );
  }

  final BetterAuthClient _client;
  late final StreamSubscription<User?> _authSubscription;

  Future<void> restoreSession() async {
    if (state.error != null) emit(const AuthState());
    try {
      final result = await _client.getSession().timeout(
        AppConfig.requestTimeout,
      );
      emit(
        AuthState(
          user: result.data?.user,
          isRestoring: false,
          error: result.error?.message,
        ),
      );
    } catch (_) {
      //stay in restoring state so user can retry instead of being signedout due to unreachable server
      emit(
        const AuthState(
          // isRestoring: false,
          error: 'Could not connect to the server. Check your connection.',
        ),
      );
    }
  }

  Future<bool> sendOtp(String email) => _runRequest(() async {
    final result = await _client.emailOtp.sendVerification(
      email: email.trim(),
      type: 'sign-in',
    );
    return result.data != null
        ? null
        : result.error?.message ?? 'Could not send the OTP.';
  });

  Future<bool> verifyOtp({required String email, required String otp}) async {
    User? signedInUser;
    final succeeded = await _runRequest(() async {
      final result = await _client.emailOtp.signIn(
        email: email.trim(),
        otp: otp,
      );
      signedInUser = result.data?.user;
      return signedInUser == null
          ? result.error?.message ?? 'Could not sign in with this OTP.'
          : null;
    });
    if (succeeded) emit(AuthState(user: signedInUser, isRestoring: false));
    return succeeded;
  }

  Future<bool> signOut() async {
    final succeeded = await _runRequest(
      () async => (await _client.signOut()).error?.message,
    );
    if (succeeded) emit(const AuthState(isRestoring: false));
    return succeeded;
  }

  void clearError() => emit(state.copyWith(clearError: true));

  void sessionExpired() {
    if (!state.isAuthenticated) return;
    emit(
      const AuthState(
        isRestoring: false,
        error: 'Your session expired. Please sign in again.',
      ),
    );
  }

  Future<bool> _runRequest(Future<String?> Function() request) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final error = await request().timeout(AppConfig.requestTimeout);
      if (error != null) emit(state.copyWith(isLoading: false, error: error));
      return error == null;
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Could not connect to the server. Try again.',
        ),
      );
      return false;
    } finally {
      if (state.isLoading) emit(state.copyWith(isLoading: false));
    }
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
