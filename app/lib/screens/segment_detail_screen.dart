import 'package:flutter/material.dart';
import 'package:leaguetastic/l10n/app_localizations.dart';

import '../models/segment_details.dart';
import '../repositories/segment_result_repository.dart';
import '../services/auth_service.dart';
import '../utils/app_formatters.dart';
import '../utils/segment_fields.dart';
import '../utils/value_parser.dart';
import '../widgets/common/section_title.dart';
import '../widgets/common/stat_box.dart';
import '../widgets/leaderboard_entry_tile.dart';
import '../widgets/map_widget.dart';

class SegmentDetailScreen extends StatefulWidget {
  final String challengeId;
  final Map<String, dynamic> segment;

  const SegmentDetailScreen({
    super.key,
    required this.challengeId,
    required this.segment,
  });

  @override
  State<SegmentDetailScreen> createState() => _SegmentDetailScreenState();
}

class _SegmentDetailScreenState extends State<SegmentDetailScreen> {
  final AuthService _authService = AuthService();
  final SegmentResultRepository _segmentResultRepository =
      SegmentResultRepository();

  bool loading = true;
  SegmentDetails segmentDetails = const SegmentDetails.empty();

  @override
  void initState() {
    super.initState();
    loadSegmentDetails();
  }

  String get segmentId => SegmentFields.id(widget.segment);

  String get segmentName =>
      SegmentFields.name(widget.segment, fallback: 'Segment');

  Future<void> loadSegmentDetails() async {
    try {
      final user = _authService.currentUser;

      if (user == null || segmentId.isEmpty) {
        if (!mounted) return;

        setState(() {
          loading = false;
        });

        return;
      }

      final loadedSegmentDetails = await _segmentResultRepository
          .getSegmentDetails(
            firebaseUserId: user.uid,
            challengeId: widget.challengeId,
            segmentId: segmentId,
          );

      if (!mounted) return;

      setState(() {
        segmentDetails = loadedSegmentDetails;
        loading = false;
      });
    } catch (e) {
      debugPrint("Error loading segment details: $e");

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final locale = AppLocalizations.of(context)!;
    final polyline = SegmentFields.polyline(widget.segment);

    final myResult = segmentDetails.myResult;
    final myEfforts = segmentDetails.myEfforts;
    final leaderboard = segmentDetails.leaderboard;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(segmentName),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SectionTitle(title: locale.segment),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        segmentName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${locale.segmentId}: $segmentId",
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      if (widget.segment['weekIndex'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          "${locale.week} ${ValueParser.integer(widget.segment['weekIndex']) + 1}",
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (polyline.isNotEmpty) ...[
                  SectionTitle(title: locale.route),
                  Container(
                    height: 260,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: StravaMapWidget(encodedPolyline: polyline),
                  ),
                  const SizedBox(height: 20),
                ],
                SectionTitle(title: locale.myResult),
                Row(
                  children: [
                    Expanded(
                      child: StatBox(
                        label: locale.bestTime,
                        value: AppFormatters.duration(myResult?['bestTime']),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatBox(
                        label: locale.rank,
                        value: myResult?['rank'] != null
                            ? "#${myResult!['rank']}"
                            : "-",
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatBox(
                        label: locale.points,
                        value: "${myResult?['points'] ?? 0}",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SectionTitle(title: locale.myAttempts),
                if (myEfforts.isEmpty)
                  Text(
                    locale.noSegmentAttempts,
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  )
                else
                  ...myEfforts.map((effort) {
                    return _EffortTile(effort: effort);
                  }),
                const SizedBox(height: 20),
                SectionTitle(title: locale.segmentLeaderboard),
                if (leaderboard.isEmpty)
                  Text(
                    locale.noSegmentLeaderboardEntries,
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  )
                else
                  ...leaderboard.map((entry) {
                    final rank = ValueParser.integer(entry['rank']);
                    final points = ValueParser.integer(entry['points']);
                    final userName = ValueParser.string(entry['userName']);
                    final displayName = ValueParser.string(
                      entry['displayName'],
                    );

                    return LeaderboardEntryTile(
                      rankText: rank > 0 ? "$rank" : "-",
                      title: userName.isNotEmpty
                          ? userName
                          : displayName.isNotEmpty
                          ? displayName
                          : locale.anonymous,
                      subtitle:
                          "$points ${points == 1 ? locale.point : locale.points}",
                      trailingText: AppFormatters.duration(entry['bestTime']),
                    );
                  }),
              ],
            ),
    );
  }
}

class _EffortTile extends StatelessWidget {
  final Map<String, dynamic> effort;

  const _EffortTile({required this.effort});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final activityDate = AppFormatters.parseDate(
      effort['activityStartDateMs'] ??
          effort['activityStartDate'] ??
          effort['createdAt'],
    );

    final dateText = activityDate != null
        ? "${activityDate.day.toString().padLeft(2, '0')}.${activityDate.month.toString().padLeft(2, '0')}.${activityDate.year}"
        : "-";

    final effortTime =
        effort['movingTime'] ??
        effort['elapsedTime'] ??
        effort['time'] ??
        effort['bestTime'];
    final distance = effort['distance'];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          AppFormatters.duration(effortTime),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          dateText,
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
        ),
        trailing: distance != null
            ? Text(
                AppFormatters.distance(distance),
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
              )
            : null,
      ),
    );
  }
}
