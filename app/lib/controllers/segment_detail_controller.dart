import 'package:flutter/foundation.dart';

import '../models/segment_details.dart';
import '../repositories/segment_result_repository.dart';
import '../services/auth_service.dart';

/// Coordinates personal results and leaderboard data for a segment page.
class SegmentDetailController extends ChangeNotifier {
  final SegmentResultRepository _segmentResultRepository;
  final AuthService _authService;

  SegmentDetailController({
    SegmentResultRepository? segmentResultRepository,
    AuthService? authService,
  }) : _segmentResultRepository =
           segmentResultRepository ?? SegmentResultRepository(),
       _authService = authService ?? AuthService();

  bool isLoading = false;
  SegmentDetails details = const SegmentDetails.empty();
  Object? error;
  bool _isDisposed = false;

  /// Loads the signed-in athlete's data for one challenge segment.
  Future<void> load({
    required String challengeId,
    required String segmentId,
  }) async {
    isLoading = true;
    error = null;
    _notifyListeners();

    try {
      final user = _authService.currentUser;

      if (user == null || segmentId.isEmpty) {
        details = const SegmentDetails.empty();
        return;
      }

      details = await _segmentResultRepository.getSegmentDetails(
        firebaseUserId: user.uid,
        challengeId: challengeId,
        segmentId: segmentId,
      );
    } catch (exception) {
      error = exception;
      debugPrint('Error loading segment details: $exception');
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
