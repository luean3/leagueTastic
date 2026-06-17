import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/segment_details.dart';
import '../models/segment_performance.dart';
import '../utils/segment_fields.dart';
import '../utils/value_parser.dart';
import 'user_repository.dart';

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

    final efforts = effortsSnap.docs.map((doc) {
      return {'id': doc.id, ...doc.data()};
    }).toList();

    efforts.sort((a, b) {
      final aTime = ValueParser.integer(a['activityStartDateMs']);
      final bTime = ValueParser.integer(b['activityStartDateMs']);
      return bTime.compareTo(aTime);
    });

    final leaderboard = leaderboardSnap.docs.map((doc) {
      return {'id': doc.id, ...doc.data()};
    }).toList();

    return SegmentDetails(
      athleteId: athleteId,
      myResult: myLeaderboardDoc.data(),
      myEfforts: efforts,
      leaderboard: leaderboard,
    );
  }

  Future<SegmentPerformance?> getCurrentSegmentPerformance({
    required String firebaseUserId,
    required String challengeId,
    required Map<String, dynamic>? currentSegment,
  }) async {
    if (currentSegment == null) {
      return null;
    }

    final athleteId = await _userRepository.getAthleteId(firebaseUserId);

    if (athleteId == null) {
      return null;
    }

    final segmentId = SegmentFields.id(currentSegment);

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
      bestTime: leaderboardData?['bestTime'],
      rank: leaderboardData?['rank'],
      points: leaderboardData?['points'] ?? 0,
    );
  }
}
