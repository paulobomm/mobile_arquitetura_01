import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class AuthState {
  final bool isAuthenticated;
  final UserProfile? user;
  final bool isLoading;

  AuthState({this.isAuthenticated = false, this.user, this.isLoading = false});

  AuthState copyWith({
    bool? isAuthenticated,
    UserProfile? user,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  Auth0? auth0;

  AuthNotifier() : super(AuthState()) {
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      auth0 = Auth0(
        'paulobomm.us.auth0.com',
        'Cxm0lAYjjPSB7P28ZCI50QF3SaTTcOdU',
      );
      _checkIsLoggedIn();
    } else {
      state = state.copyWith(isAuthenticated: false, isLoading: false);
    }
  }

  Future<void> _checkIsLoggedIn() async {
    if (auth0 == null) return;
    if (kIsWeb) {
      state = state.copyWith(isAuthenticated: false, isLoading: false);
      return;
    }
    state = state.copyWith(isLoading: true);
    try {
      if (await auth0!.credentialsManager.hasValidCredentials()) {
        final credentials = await auth0!.credentialsManager.credentials();
        state = state.copyWith(
          isAuthenticated: true,
          user: credentials.user,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isAuthenticated: false, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isAuthenticated: false, isLoading: false);
    }
  }

  Future<void> login() async {
    if (auth0 == null) {
      print("Login not supported on this platform - Mocking Login");
      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(
        isAuthenticated: true,
        user: const UserProfile(sub: 'linux_mock_user', name: 'Linux Mock User', nickname: 'linux_mock'),
        isLoading: false,
      );
      return;
    }
    state = state.copyWith(isLoading: true);
    try {
      final credentials = await auth0!.webAuthentication().login();
      state = state.copyWith(
        isAuthenticated: true,
        user: credentials.user,
        isLoading: false,
      );
    } catch (e) {
      print("Login Error: $e");
      state = state.copyWith(isLoading: false);
      // Aqui poderíamos emitir erro via outro provider ou callback
    }
  }

  Future<void> logout() async {
    if (auth0 == null) {
      print("Logout not supported on this platform - Mocking Logout");
      await Future.delayed(const Duration(milliseconds: 500));
      state = AuthState();
      return;
    }
    state = state.copyWith(isLoading: true);
    try {
      await auth0!.webAuthentication().logout();
      if (!kIsWeb) {
        await auth0!.credentialsManager.clearCredentials();
      }
      state = AuthState();
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
