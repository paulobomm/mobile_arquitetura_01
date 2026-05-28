import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:product_app/data/models/user_model.dart';
import 'package:product_app/data/services/auth_service.dart';

class AuthState {
  final bool isAuthenticated;
  final UserModel? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final _authService = AuthService();

  AuthNotifier() : super(AuthState(isLoading: true)) {
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null && token.isNotEmpty) {
        final user = await _authService.getMe(token);
        state = AuthState(isAuthenticated: true, user: user);
        return;
      }
    } catch (_) {}
    state = AuthState();
  }

  Future<void> login(String username, String password) async {
    state = AuthState(isLoading: true);
    try {
      final user = await _authService.login(username, password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', user.token);
      state = AuthState(isAuthenticated: true, user: user);
    } catch (e) {
      state = AuthState(error: e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (_) => AuthNotifier(),
);
