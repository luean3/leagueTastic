import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/strava_service.dart';

/// Exposes profile actions and data without coupling the page to services.
class ProfileController {
  final AuthService _authService;
  final StravaService _stravaService;

  ProfileController({AuthService? authService, StravaService? stravaService})
    : _authService = authService ?? AuthService(),
      _stravaService = stravaService ?? StravaService();

  UserProfile? get profile => _authService.getUserProfile();

  Future<void> connectStrava() => _stravaService.connect();

  Future<void> signOut() => _authService.signOut();
}
