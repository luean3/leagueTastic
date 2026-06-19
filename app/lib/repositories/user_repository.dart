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

    final athleteId = ValueParser.string(userData['athleteId']);

    return athleteId.isEmpty ? null : athleteId;
  }
}
