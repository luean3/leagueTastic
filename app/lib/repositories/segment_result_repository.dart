import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/challenge_state.dart';
import '../models/segment_details.dart';
import '../models/segment_performance.dart';
import '../utils/value_parser.dart';
import 'user_repository.dart';

/// Lädt persönliche Segment-Ergebnisse, Versuche und Leaderboard-Einträge.
///
/// Die Repository-Grenze hält Firestore-Details aus den Detail-Screens heraus.
class SegmentResultRepository {
  final FirebaseFirestore _firestore;
  final UserRepository _userRepository;

  SegmentResultRepository({
    FirebaseFirestore? firestore,
    UserRepository? userRepository,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _userRepository = userRepository ?? UserRepository(firestore: firestore);

  Future<SegmentDetails> getSegmentDetails({
    required String firebaseUserId,
    required String challengeId,
    required String segmentId,
  }) async {
    if (segmentId.isEmpty) {
      return const SegmentDetails.empty();
    }

    final athleteId = await _userRepository.getAthleteId(firebaseUserId);

    if (athleteId == null) {
      return const SegmentDetails.empty();
    }

    final leaderboardDocId = '${challengeId}_$segmentId';

    final myLeaderboardDoc = await _firestore
        .collection('segmentLeaderboards')
        .doc(leaderboardDocId)
        .collection('entries')
        .doc(athleteId)
        .get();

    final effortsSnap = await _firestore
        .collection('segmentEfforts')
        .where('userId', isEqualTo: athleteId)
        .where('segmentId', isEqualTo: segmentId)
        .where('processedChallengeIds', arrayContains: challengeId)
        .get();

    final leaderboardSnap = await _firestore
        .collection('segmentLeaderboards')
        .doc(leaderboardDocId)
        .collection('entries')
        .orderBy('rank')
        .limit(50)
        .get();

    final efforts = effortsSnap.docs
        .map((doc) => SegmentEffort.fromMap(doc.data()))
        .toList();

    // Lokal sortieren, damit kein zusätzlicher Firestore-Index nötig ist.
    efforts.sort((a, b) {
      final aTime = a.activityDate?.millisecondsSinceEpoch ?? 0;
      final bTime = b.activityDate?.millisecondsSinceEpoch ?? 0;
      return bTime.compareTo(aTime);
    });

    final leaderboard = leaderboardSnap.docs
        .map((doc) => SegmentLeaderboardEntry.fromMap(doc.data()))
        .toList();

    return SegmentDetails(
      athleteId: athleteId,
      myResult: myLeaderboardDoc.data() == null
          ? null
          : SegmentResult.fromMap(myLeaderboardDoc.data()!),
      myEfforts: efforts,
      leaderboard: leaderboard,
    );
  }

  Future<SegmentPerformance?> getCurrentSegmentPerformance({
    required String firebaseUserId,
    required String challengeId,
    required ChallengeSegment? currentSegment,
  }) async {
    if (currentSegment == null) {
      return null;
    }

    final athleteId = await _userRepository.getAthleteId(firebaseUserId);

    if (athleteId == null) {
      return null;
    }

    final segmentId = currentSegment.id;

    if (segmentId.isEmpty) {
      return null;
    }

    final leaderboardDoc = await _firestore
        .collection('segmentLeaderboards')
        .doc('${challengeId}_$segmentId')
        .collection('entries')
        .doc(athleteId)
        .get();

    final leaderboardData = leaderboardDoc.data();

    final effortsSnap = await _firestore
        .collection('segmentEfforts')
        .where('userId', isEqualTo: athleteId)
        .where('segmentId', isEqualTo: segmentId)
        .where('processedChallengeIds', arrayContains: challengeId)
        .get();

    return SegmentPerformance(
      segmentId: segmentId,
      attempts: effortsSnap.size,
      hasResult: leaderboardDoc.exists,
      bestTime: ValueParser.nullableInteger(leaderboardData?['bestTime']),
      rank: ValueParser.nullableInteger(leaderboardData?['rank']),
      points: ValueParser.integer(leaderboardData?['points']),
    );
  }
}
