/// Segment-Vorschau aus der Strava-Explore-Suche.
class ExploreSegment {
  final String id;
  final String name;
  final String? city;
  final double? distance;
  final double? avgGrade;
  final int? climbCategory;

  const ExploreSegment({
    required this.id,
    required this.name,
    this.city,
    this.distance,
    this.avgGrade,
    this.climbCategory,
  });

  factory ExploreSegment.fromMap(String id, Map<String, dynamic> data) {
    return ExploreSegment(
      id: id,
      name: (data['name'] ?? '').toString(),
      city: data['city']?.toString(),
      distance: _toDouble(data['distance']),
      avgGrade: _toDouble(data['avg_grade']),
      climbCategory: _toInt(data['climb_category']),
    );
  }

  static double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int? _toInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
