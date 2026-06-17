class ChallengeState {
  final Map<String, dynamic> challenge;
  final Map<String, dynamic>? currentSegment;
  final List<Map<String, dynamic>> segments;
  final List<Map<String, dynamic>> leaderboard;

  const ChallengeState({
    required this.challenge,
    required this.currentSegment,
    required this.segments,
    required this.leaderboard,
  });

  factory ChallengeState.fromMap(Map<String, dynamic> data) {
    return ChallengeState(
      challenge: Map<String, dynamic>.from(data['challenge'] ?? {}),
      currentSegment: data['currentSegment'] != null
          ? Map<String, dynamic>.from(data['currentSegment'] as Map)
          : null,
      segments: (data['segments'] as List? ?? [])
          .map((segment) => Map<String, dynamic>.from(segment as Map))
          .toList(),
      leaderboard: (data['leaderboard'] as List? ?? [])
          .map((entry) => Map<String, dynamic>.from(entry as Map))
          .toList(),
    );
  }
}
