import 'package:flutter/material.dart';
import 'package:leaguetastic/l10n/app_localizations.dart';

import '../controllers/home_controller.dart';
import '../models/challenge_summary.dart';
import '../widgets/app_header.dart';
import '../widgets/challenge_card.dart';

/// Startseite mit den Challenges, denen der aktuelle User beigetreten ist.
class HomeScreen extends StatelessWidget {
  HomeScreen({super.key, HomeController? controller})
    : _controller = controller ?? HomeController();

  final HomeController _controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: "LeagueTastic"),

            const SizedBox(height: 20),

            Text(
              locale.rideCompeteWin,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  locale.myChallenges,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<List<ChallengeSummary>>(
                stream: _controller.watchJoinedChallenges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        locale.errorLoadingChallenges,
                        style: TextStyle(color: colorScheme.error),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        locale.noJoinedChallenges,
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    );
                  }

                  final docs = snapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      return ChallengeCard(challenge: docs[index]);
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
