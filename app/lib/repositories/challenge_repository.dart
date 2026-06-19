import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/challenge_summary.dart';

/// Result of an idempotent challenge membership request.
enum JoinChallengeResult { joined, alreadyJoined }

/// Kapselt Firestore-Zugriffe rund um Challenges und Mitgliedschaften.
///
/// Screens sollen damit nur noch Streams/Ergebnisse konsumieren und keine
/// Collection-Namen oder Join-Regeln kennen müssen.
class ChallengeRepository {
  final FirebaseFirestore _firestore;

  ChallengeRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<ChallengeSummary>> watchChallenges() {
    return _firestore
        .collection('challenges')
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChallengeSummary.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  Stream<Set<String>> watchJoinedChallengeIds(String userId) {
    return _firestore
        .collection('userChallenges')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => doc.data()['challengeId'] as String?)
              .whereType<String>()
              .toSet();
        });
  }

  Stream<List<ChallengeSummary>> watchJoinedChallenges(String userId) {
    return watchJoinedChallengeIds(userId).asyncMap((challengeIds) async {
      if (challengeIds.isEmpty) {
        return [];
      }

      final challenges = <ChallengeSummary>[];
      final ids = challengeIds.toList();

      // Firestore erlaubt bei whereIn maximal 10 Dokument-IDs pro Query.
      for (var index = 0; index < ids.length; index += 10) {
        final chunk = ids.skip(index).take(10).toList();

        final snapshot = await _firestore
            .collection('challenges')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        challenges.addAll(
          snapshot.docs.map(
            (doc) => ChallengeSummary.fromMap(doc.id, doc.data()),
          ),
        );
      }

      challenges.sort((a, b) {
        final aDate = a.startDate;
        final bDate = b.startDate;

        if (aDate == null || bDate == null) {
          return 0;
        }

        return bDate.compareTo(aDate);
      });

      return challenges;
    });
  }

  Future<JoinChallengeResult> joinChallenge({
    required String userId,
    required String challengeId,
  }) async {
    final existing = await _firestore
        .collection('userChallenges')
        .where('userId', isEqualTo: userId)
        .where('challengeId', isEqualTo: challengeId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return JoinChallengeResult.alreadyJoined;
    }

    await _firestore.collection('userChallenges').add({
      'userId': userId,
      'challengeId': challengeId,
      'joinedAt': FieldValue.serverTimestamp(),
    });

    return JoinChallengeResult.joined;
  }
}
