import 'package:cloud_firestore/cloud_firestore.dart';

/// Kompakte Challenge-Daten für Listenansichten.
class ChallengeSummary {
  final String id;
  final String name;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final int segmentCount;

  const ChallengeSummary({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.segmentCount,
  });

  factory ChallengeSummary.fromMap(String id, Map<String, dynamic> data) {
    return ChallengeSummary(
      id: id,
      name: (data['name'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      startDate: _toDate(data['startDate']),
      endDate: _toDate(data['endDate']),
      segmentCount: (data['segmentIds'] as List?)?.length ?? 0,
    );
  }

  bool matchesSearch(String searchText) {
    final query = searchText.toLowerCase().trim();

    if (query.isEmpty) {
      return true;
    }

    return name.toLowerCase().contains(query) ||
        description.toLowerCase().contains(query);
  }

  static DateTime? _toDate(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}
