/// Persönliche Kennzahlen für das aktuell aktive Segment einer Challenge.
class SegmentPerformance {
  final String segmentId;
  final int attempts;
  final bool hasResult;
  final dynamic bestTime;
  final dynamic rank;
  final dynamic points;

  const SegmentPerformance({
    required this.segmentId,
    required this.attempts,
    required this.hasResult,
    required this.bestTime,
    required this.rank,
    required this.points,
  });
}
