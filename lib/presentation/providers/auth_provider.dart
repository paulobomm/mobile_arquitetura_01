import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auth0_flutter/auth0_flutter.dart';

class AuthState {
  final bool isAuthenticated;
  final UserProfile? user;
  final bool isLoading;

  AuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = false,
  });

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
  late final Auth0 auth0;

  AuthNotifier() : super(AuthState()) {
    auth0 = Auth0('paulobomm.us.auth0.com', 'Cxm0lAYjjPSB7P28ZCI50QF3SaTTcOdU');
    _checkIsLoggedIn();
  }

  Future<void> _checkIsLoggedIn() async {
    state = state.copyWith(isLoading: true);
    try {
      if (await auth0.credentialsManager.hasValidCredentials()) {
        final credentials = await auth0.credentialsManager.credentials();
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
    state = state.copyWith(isLoading: true);
    try {
      final credentials = await auth0.webAuthentication(scheme: 'com.example.productapp').login();
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
    state = state.copyWith(isLoading: true);
    try {
      await auth0.webAuthentication(scheme: 'com.example.productapp').logout();
      await auth0.credentialsManager.clearCredentials();
      state = AuthState(); 
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
