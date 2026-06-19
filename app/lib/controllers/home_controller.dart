import '../models/challenge_summary.dart';
import '../repositories/challenge_repository.dart';
import '../services/auth_service.dart';

/// Provides the signed-in user's joined challenges to the home page.
class HomeController {
  final ChallengeRepository _challengeRepository;
  final AuthService _authService;

  HomeController({
    ChallengeRepository? challengeRepository,
    AuthService? authService,
  }) : _challengeRepository = challengeRepository ?? ChallengeRepository(),
       _authService = authService ?? AuthService();

  /// Emits an empty list for guests and joined challenges for signed-in users.
  Stream<List<ChallengeSummary>> watchJoinedChallenges() {
    final user = _authService.currentUser;
    if (user == null) return Stream.value(const []);
    return _challengeRepository.watchJoinedChallenges(user.uid);
  }
}
