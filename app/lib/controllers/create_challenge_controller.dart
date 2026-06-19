import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../models/explore_segment.dart';
import '../repositories/segment_repository.dart';
import '../services/auth_service.dart';
import '../services/challenge_functions_service.dart';

/// Outcomes that the create screen translates into localized user feedback.
enum CreateChallengeResult {
  created,
  notLoggedIn,
  startDateMissing,
  segmentsMissing,
}

/// Coordinates location lookup, segment discovery and challenge creation.
class CreateChallengeController extends ChangeNotifier {
  final ChallengeFunctionsService _functionsService;
  final SegmentRepository _segmentRepository;
  final AuthService _authService;

  CreateChallengeController({
    ChallengeFunctionsService? functionsService,
    SegmentRepository? segmentRepository,
    AuthService? authService,
  }) : _functionsService = functionsService ?? ChallengeFunctionsService(),
       _segmentRepository = segmentRepository ?? SegmentRepository(),
       _authService = authService ?? AuthService();

  DateTime? startDate;
  bool isLoadingSegments = false;
  bool isSaving = false;
  List<ExploreSegment> availableSegments = [];
  final List<ExploreSegment> selectedSegments = [];
  bool _isDisposed = false;

  /// Updates the first day of the challenge.
  void selectStartDate(DateTime date) {
    startDate = date;
    _notifyListeners();
  }

  /// Adds or removes a segment while preserving the selected order.
  void toggleSegment(ExploreSegment segment) {
    final alreadySelected = selectedSegments.any(
      (selected) => selected.id == segment.id,
    );

    if (alreadySelected) {
      selectedSegments.removeWhere((selected) => selected.id == segment.id);
    } else {
      selectedSegments.add(segment);
    }

    _notifyListeners();
  }

  /// Loads Strava segments around the device's current location.
  ///
  /// Returns `false` when location services or permission are unavailable.
  Future<bool> loadNearbySegments() async {
    isLoadingSegments = true;
    _notifyListeners();

    try {
      if (!await _ensureLocationPermission()) {
        return false;
      }

      final position = await Geolocator.getCurrentPosition();
      final segmentIds = await _functionsService.exploreSegments(
        bounds: _buildBounds(position),
      );

      availableSegments = await _segmentRepository.getExploreSegmentsByIds(
        segmentIds,
      );
      return true;
    } finally {
      isLoadingSegments = false;
      _notifyListeners();
    }
  }

  /// Validates controller-owned state and persists a new challenge.
  Future<CreateChallengeResult> createChallenge({
    required String name,
    required String description,
  }) async {
    if (_authService.currentUser == null) {
      return CreateChallengeResult.notLoggedIn;
    }
    if (startDate == null) {
      return CreateChallengeResult.startDateMissing;
    }
    if (selectedSegments.isEmpty) {
      return CreateChallengeResult.segmentsMissing;
    }

    isSaving = true;
    _notifyListeners();

    try {
      await _functionsService.createChallenge(
        name: name,
        description: description,
        startDate: startDate!,
        segmentIds: selectedSegments.map((segment) => segment.id).toList(),
      );
      return CreateChallengeResult.created;
    } finally {
      isSaving = false;
      _notifyListeners();
    }
  }

  /// Clears all transient state after a successful creation.
  void reset() {
    startDate = null;
    availableSegments = [];
    selectedSegments.clear();
    _notifyListeners();
  }

  Future<bool> _ensureLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  String _buildBounds(Position position) {
    const delta = 0.08;
    return '${position.latitude - delta},${position.longitude - delta},'
        '${position.latitude + delta},${position.longitude + delta}';
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
