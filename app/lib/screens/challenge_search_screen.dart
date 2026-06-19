import 'package:flutter/material.dart';
import 'package:leaguetastic/l10n/app_localizations.dart';

import '../controllers/challenge_search_controller.dart';
import '../models/challenge_summary.dart';
import '../widgets/app_header.dart';
import '../widgets/challenge_search_result_tile.dart';
import 'challenge_detail_screen.dart';

/// Such- und Beitrittsseite für öffentlich verfügbare Challenges.
class ChallengeSearchScreen extends StatefulWidget {
  const ChallengeSearchScreen({super.key});

  @override
  State<ChallengeSearchScreen> createState() => _ChallengeSearchScreenState();
}

class _ChallengeSearchScreenState extends State<ChallengeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ChallengeSearchController _controller = ChallengeSearchController();

  String _searchText = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _joinChallenge({
    required BuildContext context,
    required String challengeId,
  }) async {
    final locale = AppLocalizations.of(context)!;
    final result = await _controller.joinChallenge(challengeId);

    if (!context.mounted) return;

    switch (result) {
      case ChallengeJoinOutcome.notLoggedIn:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(locale.notLoggedIn)));
      case ChallengeJoinOutcome.alreadyJoined:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(locale.alreadyJoinedSnackbar)));
      case ChallengeJoinOutcome.joined:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(locale.joinedChallenge)));
    }
  }

  void _openChallengeDetail({
    required BuildContext context,
    required String challengeId,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChallengeDetailScreen(challengeId: challengeId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final locale = AppLocalizations.of(context)!;

    if (!_controller.isAuthenticated) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Text(
            locale.notLoggedIn,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: locale.findChallenges),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: locale.searchChallenge,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<ChallengeSummary>>(
                stream: _controller.watchChallenges(),
                builder: (context, challengeSnapshot) {
                  if (challengeSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    );
                  }

                  if (challengeSnapshot.hasError) {
                    return Center(
                      child: Text(
                        locale.errorLoadingChallenges,
                        style: TextStyle(color: colorScheme.error),
                      ),
                    );
                  }

                  final challenges = challengeSnapshot.data ?? [];

                  if (challenges.isEmpty) {
                    return Center(
                      child: Text(
                        locale.noChallengesAvailable,
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    );
                  }

                  final filteredChallenges = challenges
                      .where(
                        (challenge) => challenge.matchesSearch(_searchText),
                      )
                      .toList();

                  if (filteredChallenges.isEmpty) {
                    return Center(
                      child: Text(
                        locale.noMatchingChallengeFound,
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    );
                  }

                  return StreamBuilder<Set<String>>(
                    stream: _controller.watchJoinedChallengeIds(),
                    builder: (context, userChallengeSnapshot) {
                      final joinedChallengeIds =
                          userChallengeSnapshot.data ?? <String>{};

                      return ListView.builder(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 16,
                        ),
                        itemCount: filteredChallenges.length,
                        itemBuilder: (context, index) {
                          final challenge = filteredChallenges[index];

                          return ChallengeSearchResultTile(
                            challenge: challenge,
                            alreadyJoined: joinedChallengeIds.contains(
                              challenge.id,
                            ),
                            onOpen: () {
                              _openChallengeDetail(
                                context: context,
                                challengeId: challenge.id,
                              );
                            },
                            onJoin: () {
                              _joinChallenge(
                                context: context,
                                challengeId: challenge.id,
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
