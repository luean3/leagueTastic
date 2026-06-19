import 'package:flutter/foundation.dart';

import '../models/challenge_state.dart';
import '../models/segment_performance.dart';
import '../repositories/segment_result_repository.dart';
import '../services/auth_service.dart';
import '../services/challenge_functions_service.dart';

/// Coordinates loading a challenge and the signed-in user's current result.
class ChallengeDetailController extends ChangeNotifier {
  final ChallengeFunctionsService _functionsService;
  final SegmentResultRepository _segmentResultRepository;
  final AuthService _authService;

  ChallengeDetailController({
    ChallengeFunctionsService? functionsService,
    SegmentResultRepository? segmentResultRepository,
    AuthService? authService,
  }) : _functionsService = functionsService ?? ChallengeFunctionsService(),
       _segmentResultRepository =
           segmentResultRepository ?? SegmentResultRepository(),
       _authService = authService ?? AuthService();

  bool isLoading = false;
  ChallengeState? state;
  SegmentPerformance? currentPerformance;
  Object? error;
  bool _isDisposed = false;

  /// Loads all data required by the challenge detail page.
  Future<void> load(String challengeId) async {
    isLoading = true;
    error = null;
    currentPerformance = null;
    _notifyListeners();

    try {
      final loadedState = await _functionsService.getCurrentChallengeState(
        challengeId: challengeId,
      );
      state = loadedState;
      isLoading = false;
      _notifyListeners();

      // Personal metrics are optional. A missing Firestore index or result must
      // never hide the challenge segments or block their detail pages.
      final user = _authService.currentUser;
      if (user != null) {
        try {
          currentPerformance = await _segmentResultRepository
              .getCurrentSegmentPerformance(
                firebaseUserId: user.uid,
                challengeId: challengeId,
                currentSegment: loadedState.currentSegment,
              );
        } catch (exception) {
          debugPrint('Error loading current segment performance: $exception');
        }
      }
    } catch (exception) {
      error = exception;
      debugPrint('Error loading challenge state: $exception');
    } finally {
      isLoading = false;
      _notifyListeners();
    }
  }

  void _notifyListeners() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
