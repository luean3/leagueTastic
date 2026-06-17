import 'package:flutter/material.dart';
import 'package:leaguetastic/l10n/app_localizations.dart';

import '../models/segment_performance.dart';
import '../repositories/segment_result_repository.dart';
import '../services/auth_service.dart';
import '../services/challenge_functions_service.dart';
import '../utils/value_parser.dart';
import '../widgets/current_segment_card.dart';
import '../widgets/leaderboard_entry_tile.dart';
import '../widgets/segment_card.dart';
import 'segment_detail_screen.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final String challengeId;

  const ChallengeDetailScreen({super.key, required this.challengeId});

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  final ChallengeFunctionsService _functionsService =
      ChallengeFunctionsService();
  final SegmentResultRepository _segmentResultRepository =
      SegmentResultRepository();
  final AuthService _authService = AuthService();

  bool loading = true;

  Map<String, dynamic>? challenge;
  Map<String, dynamic>? currentSegment;
  SegmentPerformance? myCurrentSegmentResult;

  List<Map<String, dynamic>> segments = [];
  List<Map<String, dynamic>> leaderboard = [];

  @override
  void initState() {
    super.initState();
    loadChallengeState();
  }

  Future<void> loadChallengeState() async {
    try {
      final loadedState = await _functionsService.getCurrentChallengeState(
        challengeId: widget.challengeId,
      );

      final user = _authService.currentUser;
      final loadedMyCurrentSegmentResult = user == null
          ? null
          : await _segmentResultRepository.getCurrentSegmentPerformance(
              firebaseUserId: user.uid,
              challengeId: widget.challengeId,
              currentSegment: loadedState.currentSegment,
            );

      if (!mounted) return;

      setState(() {
        challenge = loadedState.challenge;
        currentSegment = loadedState.currentSegment;
        segments = loadedState.segments;
        leaderboard = loadedState.leaderboard;
        myCurrentSegmentResult = loadedMyCurrentSegmentResult;
        loading = false;
      });
    } catch (e) {
      debugPrint("Error loading challenge state: $e");

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  void _openSegmentDetail(Map<String, dynamic> segment) {
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

    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(ValueParser.string(challenge?['name'])),
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
              color: colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              ValueParser.string(challenge?['description']),
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
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
            )
          else
            CurrentSegmentCard(
              segment: currentSegment!,
              performance: myCurrentSegmentResult,
              onTap: () => _openSegmentDetail(currentSegment!),
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
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
            )
          else
            ...leaderboard.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final data = entry.value;
              final userName = ValueParser.string(data['userName']);
              final totalPoints = data['totalPoints'];

              return LeaderboardEntryTile(
                rankText: "$rank",
                title: userName.isNotEmpty ? userName : "Anonymous",
                subtitle:
                    "${totalPoints?.toInt() ?? 0} ${totalPoints == 1 ? locale.point : locale.points}",
                backgroundColor: colorScheme.primary.withOpacity(0.12),
              );
            }),
        ],
      ),
    );
  }
}
