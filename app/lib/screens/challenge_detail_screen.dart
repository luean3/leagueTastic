import 'package:flutter/material.dart';
import 'package:leaguetastic/l10n/app_localizations.dart';

import '../controllers/challenge_detail_controller.dart';
import '../models/challenge_state.dart';
import '../widgets/current_segment_card.dart';
import '../widgets/leaderboard_entry_tile.dart';
import '../widgets/segment_card.dart';
import 'segment_detail_screen.dart';

/// Detailseite einer Challenge mit aktuellem Segment, Segmentplan und Rangliste.
class ChallengeDetailScreen extends StatefulWidget {
  final String challengeId;

  const ChallengeDetailScreen({super.key, required this.challengeId});

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  final ChallengeDetailController _controller = ChallengeDetailController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refresh);
    _controller.load(widget.challengeId);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  void _openSegmentDetail(ChallengeSegment segment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SegmentDetailScreen(
          challengeId: widget.challengeId,
          segment: segment,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final locale = AppLocalizations.of(context)!;
    final state = _controller.state;
    final challenge = state?.challenge;
    final currentSegment = state?.currentSegment;
    final segments = state?.segments ?? const <ChallengeSegment>[];
    final leaderboard =
        state?.leaderboard ?? const <ChallengeLeaderboardEntry>[];

    if (_controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(challenge?.name ?? ''),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              challenge?.description ?? '',
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 15,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            locale.currentSegment,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          if (currentSegment == null)
            Text(
              locale.noActiveSegment,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            )
          else
            CurrentSegmentCard(
              segment: currentSegment,
              performance: _controller.currentPerformance,
              onTap: () => _openSegmentDetail(currentSegment),
            ),
          const SizedBox(height: 20),
          Text(
            locale.allSegments,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          ...segments.map((segment) {
            return SegmentCard(
              segment: segment,
              activeLabel: locale.active,
              finishedLabel: locale.finished,
              upcomingLabel: locale.upcoming,
              onTap: () => _openSegmentDetail(segment),
            );
          }),
          const SizedBox(height: 20),
          Text(
            "Leaderboard",
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          if (leaderboard.isEmpty)
            Text(
              locale.noEntries,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            )
          else
            ...leaderboard.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final data = entry.value;
              final userName = data.userName;
              final totalPoints = data.totalPoints;

              return LeaderboardEntryTile(
                rankText: "$rank",
                title: userName.isNotEmpty ? userName : "Anonymous",
                subtitle:
                    "$totalPoints ${totalPoints == 1 ? locale.point : locale.points}",
                backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
              );
            }),
        ],
      ),
    );
  }
}
