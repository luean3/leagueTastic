import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leaguetastic/screens/challenge_detail_screen.dart';

import '../models/challenge_summary.dart';

/// Karte für eine Challenge in der persönlichen Startseitenliste.
class ChallengeCard extends StatelessWidget {
  final ChallengeSummary challenge;

  const ChallengeCard({super.key, required this.challenge});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChallengeDetailScreen(challengeId: challenge.id),
          ),
        );
      },
      child: Card(
        color: theme.cardColor,
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                challenge.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                challenge.description,
                style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)),
              ),

              const SizedBox(height: 6),

              Text(
                "Start: ${_formatDateTime(challenge.startDate)}",
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),

              Text(
                "Ende: ${_formatDateTime(challenge.endDate)}",
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),

              Text(
                "Segmente: ${challenge.segmentCount}",
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) {
      return '';
    }

    return DateFormat('dd.MM.yyyy HH:mm').format(date.toLocal());
  }
}
