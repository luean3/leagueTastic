import '../utils/value_parser.dart';

/// Name and description displayed on a challenge detail page.
class ChallengeInfo {
  final String name;
  final String description;

  const ChallengeInfo({required this.name, required this.description});

  factory ChallengeInfo.fromMap(Map<String, dynamic> data) {
    return ChallengeInfo(
      name: ValueParser.string(data['name']),
      description: ValueParser.string(data['description']),
    );
  }
}

/// A scheduled segment and its current status within a challenge.
class ChallengeSegment {
  final String id;
  final String name;
  final String polyline;
  final int weekIndex;
  final bool isActive;
  final bool isPast;
  final bool isUpcoming;

  const ChallengeSegment({
    required this.id,
    required this.name,
    required this.polyline,
    required this.weekIndex,
    required this.isActive,
    required this.isPast,
    required this.isUpcoming,
  });

  factory ChallengeSegment.fromMap(Map<String, dynamic> data) {
    final map = data['map'] is Map
        ? Map<String, dynamic>.from(data['map'] as Map)
        : <String, dynamic>{};

    return ChallengeSegment(
      id: ValueParser.string(
        data['segmentId'] ?? data['id'] ?? data['stravaSegmentId'],
      ),
      name: ValueParser.string(data['name']),
      polyline: ValueParser.string(
        data['polyline'] ??
            data['mapPolyline'] ??
            data['encodedPolyline'] ??
            data['polylineString'] ??
            data['summaryPolyline'] ??
            data['summary_polyline'] ??
            map['polyline'] ??
            map['summary_polyline'],
      ),
      weekIndex: ValueParser.integer(data['weekIndex']),
      isActive: ValueParser.boolean(data['isActive']),
      isPast: ValueParser.boolean(data['isPast']),
      isUpcoming: ValueParser.boolean(data['isUpcoming']),
    );
  }
}

/// Aggregated points entry in a challenge-wide leaderboard.
class ChallengeLeaderboardEntry {
  final String userName;
  final int totalPoints;

  const ChallengeLeaderboardEntry({
    required this.userName,
    required this.totalPoints,
  });

  factory ChallengeLeaderboardEntry.fromMap(Map<String, dynamic> data) {
    return ChallengeLeaderboardEntry(
      userName: ValueParser.string(data['userName']),
      totalPoints: ValueParser.integer(data['totalPoints']),
    );
  }
}

/// Typed result of the `getCurrentChallengeState` callable function.
class ChallengeState {
  final ChallengeInfo challenge;
  final ChallengeSegment? currentSegment;
  final List<ChallengeSegment> segments;
  final List<ChallengeLeaderboardEntry> leaderboard;

  const ChallengeState({
    required this.challenge,
    required this.currentSegment,
    required this.segments,
    required this.leaderboard,
  });

  factory ChallengeState.fromMap(Map<String, dynamic> data) {
    final currentSegmentData = data['currentSegment'];

    return ChallengeState(
      challenge: ChallengeInfo.fromMap(
        Map<String, dynamic>.from(data['challenge'] as Map? ?? {}),
      ),
      currentSegment: currentSegmentData is Map
          ? ChallengeSegment.fromMap(
              Map<String, dynamic>.from(currentSegmentData),
            )
          : null,
      segments: (data['segments'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (segment) =>
                ChallengeSegment.fromMap(Map<String, dynamic>.from(segment)),
          )
          .toList(),
      leaderboard: (data['leaderboard'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (entry) => ChallengeLeaderboardEntry.fromMap(
              Map<String, dynamic>.from(entry),
            ),
          )
          .toList(),
    );
  }
}
