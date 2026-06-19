import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/value_parser.dart';

/// Stellt User-bezogene Firestore-Daten bereit, die nicht direkt aus Auth kommen.
class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String?> getAthleteId(String firebaseUserId) async {
    final userDoc = await _firestore
        .collection('users')
        .doc(firebaseUserId)
        .get();

    final userData = userDoc.data();

    if (userData == null) {
      return null;
    }

    final athleteId = ValueParser.string(userData['stravaId']);

    return athleteId.isEmpty ? null : athleteId;
  }

  Stream<bool> watchStravaConnection(String firebaseUserId) {
    return _firestore
        .collection('users')
        .doc(firebaseUserId)
        .snapshots()
        .map((userDoc) {
      final userData = userDoc.data();

      if (userData == null) {
        return false;
      }

      final stravaId = ValueParser.string(userData['stravaId']);

      return stravaId.isNotEmpty;
    });
  }
}