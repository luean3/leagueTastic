import '../utils/app_formatters.dart';
import '../utils/value_parser.dart';

/// The signed-in athlete's best result for one challenge segment.
class SegmentResult {
  final int? bestTime;
  final int? rank;
  final int points;

  const SegmentResult({
    required this.bestTime,
    required this.rank,
    required this.points,
  });

  factory SegmentResult.fromMap(Map<String, dynamic> data) {
    return SegmentResult(
      bestTime: ValueParser.nullableInteger(data['bestTime']),
      rank: ValueParser.nullableInteger(data['rank']),
      points: ValueParser.integer(data['points']),
    );
  }
}

/// One recorded attempt at a Strava segment.
class SegmentEffort {
  final DateTime? activityDate;
  final int? elapsedTime;
  final double? distance;

  const SegmentEffort({
    required this.activityDate,
    required this.elapsedTime,
    required this.distance,
  });

  factory SegmentEffort.fromMap(Map<String, dynamic> data) {
    return SegmentEffort(
      activityDate: AppFormatters.parseDate(
        data['activityStartDateMs'] ??
            data['activityStartDate'] ??
            data['createdAt'],
      ),
      elapsedTime: ValueParser.nullableInteger(
        data['movingTime'] ??
            data['elapsedTime'] ??
            data['time'] ??
            data['bestTime'],
      ),
      distance: ValueParser.nullableDecimal(data['distance']),
    );
  }
}

/// Ranked athlete result for one challenge segment.
class SegmentLeaderboardEntry {
  final int? rank;
  final int points;
  final String userName;
  final String displayName;
  final int? bestTime;

  const SegmentLeaderboardEntry({
    required this.rank,
    required this.points,
    required this.userName,
    required this.displayName,
    required this.bestTime,
  });

  factory SegmentLeaderboardEntry.fromMap(Map<String, dynamic> data) {
    return SegmentLeaderboardEntry(
      rank: ValueParser.nullableInteger(data['rank']),
      points: ValueParser.integer(data['points']),
      userName: ValueParser.string(data['userName']),
      displayName: ValueParser.string(data['displayName']),
      bestTime: ValueParser.nullableInteger(data['bestTime']),
    );
  }
}

/// All personal and leaderboard data required by the segment detail page.
class SegmentDetails {
  final String? athleteId;
  final SegmentResult? myResult;
  final List<SegmentEffort> myEfforts;
  final List<SegmentLeaderboardEntry> leaderboard;

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
