import '../models/challenge_summary.dart';
import '../repositories/challenge_repository.dart';
import '../services/auth_service.dart';

/// Result of a join attempt, including the guest state handled by the UI.
enum ChallengeJoinOutcome { joined, alreadyJoined, notLoggedIn }

/// Supplies challenge discovery streams and coordinates joining a challenge.
class ChallengeSearchController {
  final ChallengeRepository _challengeRepository;
  final AuthService _authService;

  ChallengeSearchController({
    ChallengeRepository? challengeRepository,
    AuthService? authService,
  }) : _challengeRepository = challengeRepository ?? ChallengeRepository(),
       _authService = authService ?? AuthService();

  bool get isAuthenticated => _authService.currentUser != null;

  Stream<List<ChallengeSummary>> watchChallenges() {
    return _challengeRepository.watchChallenges();
  }

  Stream<Set<String>> watchJoinedChallengeIds() {
    final user = _authService.currentUser;
    if (user == null) return Stream.value(const {});
    return _challengeRepository.watchJoinedChallengeIds(user.uid);
  }

  /// Joins a challenge once and maps repository results to UI-level outcomes.
  Future<ChallengeJoinOutcome> joinChallenge(String challengeId) async {
    final user = _authService.currentUser;
    if (user == null) return ChallengeJoinOutcome.notLoggedIn;

    final result = await _challengeRepository.joinChallenge(
      userId: user.uid,
      challengeId: challengeId,
    );

    return switch (result) {
      JoinChallengeResult.joined => ChallengeJoinOutcome.joined,
      JoinChallengeResult.alreadyJoined => ChallengeJoinOutcome.alreadyJoined,
    };
  }
}
