class SegmentDetails {
  final String? athleteId;
  final Map<String, dynamic>? myResult;
  final List<Map<String, dynamic>> myEfforts;
  final List<Map<String, dynamic>> leaderboard;

  const SegmentDetails({
    required this.athleteId,
    required this.myResult,
    required this.myEfforts,
    required this.leaderboard,
  });

  const SegmentDetails.empty()
    : athleteId = null,
      myResult = null,
      myEfforts = const [],
      leaderboard = const [];
}
