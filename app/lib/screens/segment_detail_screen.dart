import 'package:flutter/material.dart';
import 'package:leaguetastic/l10n/app_localizations.dart';

import '../controllers/segment_detail_controller.dart';
import '../models/challenge_state.dart';
import '../models/segment_details.dart';
import '../utils/app_formatters.dart';
import '../widgets/common/section_title.dart';
import '../widgets/common/stat_box.dart';
import '../widgets/leaderboard_entry_tile.dart';
import '../widgets/map_widget.dart';

/// Detailseite eines einzelnen Challenge-Segments samt persönlichem Ergebnis.
class SegmentDetailScreen extends StatefulWidget {
  final String challengeId;
  final ChallengeSegment segment;

  const SegmentDetailScreen({
    super.key,
    required this.challengeId,
    required this.segment,
  });

  @override
  State<SegmentDetailScreen> createState() => _SegmentDetailScreenState();
}

class _SegmentDetailScreenState extends State<SegmentDetailScreen> {
  final SegmentDetailController _controller = SegmentDetailController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refresh);
    _controller.load(challengeId: widget.challengeId, segmentId: segmentId);
  }

  String get segmentId => widget.segment.id;

  String get segmentName =>
      widget.segment.name.isEmpty ? 'Segment' : widget.segment.name;

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final locale = AppLocalizations.of(context)!;
    final polyline = widget.segment.polyline;

    final myResult = _controller.details.myResult;
    final myEfforts = _controller.details.myEfforts;
    final leaderboard = _controller.details.leaderboard;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(segmentName),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: _controller.isLoading
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
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${locale.week} ${widget.segment.weekIndex + 1}",
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
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
                        value: AppFormatters.duration(myResult?.bestTime),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatBox(
                        label: locale.rank,
                        value: myResult?.rank != null
                            ? "#${myResult!.rank}"
                            : "-",
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatBox(
                        label: locale.points,
                        value: "${myResult?.points ?? 0}",
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
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
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
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  )
                else
                  ...leaderboard.map((entry) {
                    final rank = entry.rank;
                    final points = entry.points;
                    final userName = entry.userName;
                    final displayName = entry.displayName;

                    return LeaderboardEntryTile(
                      rankText: rank != null && rank > 0 ? "$rank" : "-",
                      title: userName.isNotEmpty
                          ? userName
                          : displayName.isNotEmpty
                          ? displayName
                          : locale.anonymous,
                      subtitle:
                          "$points ${points == 1 ? locale.point : locale.points}",
                      trailingText: AppFormatters.duration(entry.bestTime),
                    );
                  }),
              ],
            ),
    );
  }
}

class _EffortTile extends StatelessWidget {
  final SegmentEffort effort;

  const _EffortTile({required this.effort});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final formattedDate = AppFormatters.shortDate(effort.activityDate);
    final dateText = formattedDate.isEmpty ? '-' : formattedDate;

    final effortTime = effort.elapsedTime;
    final distance = effort.distance;

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
          style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        trailing: distance != null
            ? Text(
                AppFormatters.distance(distance),
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              )
            : null,
      ),
    );
  }
}
