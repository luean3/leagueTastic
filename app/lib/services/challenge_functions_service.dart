import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../models/challenge_state.dart';

/// Dünner Wrapper um Firebase Callable Functions für Challenge-Flows.
///
/// So bleiben Funktionsnamen und Payload-Formate an einer zentralen Stelle.
class ChallengeFunctionsService {
  final FirebaseFunctions _functions;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  ChallengeFunctionsService({FirebaseFunctions? functions})
    : _functions = functions ?? FirebaseFunctions.instance;

  Future<String> createChallenge({
    required String name,
    required String description,
    required DateTime startDate,
    required List<String> segmentIds,
  }) async {
    final callable = _functions.httpsCallable('createChallenge');

    final result = await callable.call({
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'segmentIds': segmentIds,
    });

    final data = Map<String, dynamic>.from(result.data as Map);
    final challengeId = data['challengeId'].toString();

    // Log Analytics Event
    await _analytics.logEvent(
      name: 'create_challenge',
      parameters: {
        'challenge_id': challengeId,
        'challenge_name': name,
        'segments_count': segmentIds.length,
      },
    );

    return challengeId;
  }

  Future<List<String>> exploreSegments({required String bounds}) async {
    final callable = _functions.httpsCallable('exploreSegments');

    final result = await callable.call({
      'bounds': bounds,
      'activityType': 'riding',
    });

    final data = Map<String, dynamic>.from(result.data as Map);

    return (data['segmentIds'] as List).map((id) => id.toString()).toList();
  }

  Future<ChallengeState> getCurrentChallengeState({
    required String challengeId,
  }) async {
    final result = await _functions
        .httpsCallable('getCurrentChallengeState')
        .call({'challengeId': challengeId});

    final data = Map<String, dynamic>.from(result.data as Map);

    return ChallengeState.fromMap(data);
  }
}
