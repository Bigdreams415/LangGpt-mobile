import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository_impl.dart';

// Auth State 

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final bool isNewUser;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.isNewUser = false,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        user = null,
        errorMessage = null,
        isNewUser = false;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    bool? isNewUser,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }
}

// Auth Notifier 

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState.initial()) {
    _checkStoredSession();
  }

  final _repo = AuthRepositoryImpl.instance;

  // Check if user is already logged in from a previous session
  Future<void> _checkStoredSession() async {
    state = state.copyWith(status: AuthStatus.loading);
    final isLoggedIn = await _repo.isLoggedIn();
    if (isLoggedIn) {
      final user = await _repo.getStoredUser();
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  // Login
  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final response = await _repo.login(
        identifier: identifier,
        password: password,
      );
      state = AuthState(
        status: AuthStatus.authenticated,
        user: response.user,
        isNewUser: false,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _parseDioError(e),
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Something went wrong. Please try again.',
      );
    }
  }

  // Signup
  Future<void> signup({
    required String fullName,
    required String username,
    required String email,
    required String password,
    String? dateOfBirth,
    String? country,
    String? selectedLanguage,
    String? level,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final response = await _repo.signup(
        fullName: fullName,
        username: username,
        email: email,
        password: password,
        dateOfBirth: dateOfBirth,
        country: country,
        selectedLanguage: selectedLanguage,
        level: level,
      );
      state = AuthState(
        status: AuthStatus.authenticated,
        user: response.user,
        isNewUser: response.isNewUser,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _parseDioError(e),
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Something went wrong. Please try again.',
      );
    }
  }

  // Google Sign-In
  Future<void> googleSignIn({String? selectedLanguage}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final response = await _repo.googleSignIn(
        selectedLanguage: selectedLanguage,
      );
      state = AuthState(
        status: AuthStatus.authenticated,
        user: response.user,
        isNewUser: response.isNewUser,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _parseDioError(e),
      );
    } catch (e) {
      // User cancelled Google sign-in — go back to unauthenticated quietly
      if (e.toString().contains('cancelled')) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Google sign-in failed. Please try again.',
      );
    }
  }

  // Logout
  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  // Parse Dio errors into human-readable messages
  String _parseDioError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String) return detail;
      // Validation error format
      final errors = data['errors'];
      if (errors is List && errors.isNotEmpty) {
        return errors.first['message'] as String? ?? 'Validation error';
      }
    }
    switch (e.response?.statusCode) {
      case 401:
        return 'Invalid email/username or password';
      case 409:
        return data?['detail'] as String? ?? 'Account already exists';
      case 422:
        return 'Please check your input and try again';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'Connection error. Check your internet and try again.';
    }
  }
}

// Provider

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Convenience providers
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).status == AuthStatus.authenticated;
});