import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/explore_segment.dart';

/// Lädt Explore-Segmentdaten aus Firestore für die Challenge-Erstellung.
class SegmentRepository {
  final FirebaseFirestore _firestore;

  SegmentRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<ExploreSegment>> getExploreSegmentsByIds(
    List<String> segmentIds,
  ) async {
    if (segmentIds.isEmpty) {
      return [];
    }

    final segments = <ExploreSegment>[];

    // Firestore erlaubt bei whereIn maximal 10 Dokument-IDs pro Query.
    for (int i = 0; i < segmentIds.length; i += 10) {
      final chunk = segmentIds.skip(i).take(10).toList();

      final snap = await _firestore
          .collection('segment_explore')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (final doc in snap.docs) {
        segments.add(ExploreSegment.fromMap(doc.id, doc.data()));
      }
    }

    segments.sort((a, b) => a.name.compareTo(b.name));

    return segments;
  }
}
