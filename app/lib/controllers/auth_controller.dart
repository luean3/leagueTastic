import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';

/// Coordinates login and registration without exposing Firebase to the screen.
class AuthController {
  final AuthService _authService;

  AuthController({AuthService? authService})
    : _authService = authService ?? AuthService();

  /// Emits the user whenever Firebase authentication changes.
  Stream<User?> get userStatus => _authService.userStatus;

  /// Authenticates with the selected mode and returns `null` on failure.
  Future<User?> authenticate({
    required bool isLogin,
    required String email,
    required String password,
    required String username,
  }) {
    if (isLogin) {
      return _authService.loginWithEmail(email, password);
    }
    return _authService.registerWithEmail(email, password, username);
  }

  /// Requests a password-reset email for the supplied address.
  Future<bool> resetPassword(String email) {
    return _authService.resetPassword(email);
  }
}
