import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'package:leaguetastic/screens/challenge_detail_screen.dart';

class ChallengeCard extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final int segments;

  const ChallengeCard({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.segments,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChallengeDetailScreen(challengeId: id),
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
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                description,
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                "Start: ${DateFormat('dd.MM.yyyy HH:mm').format(startDate.toLocal())}",
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),

              Text(
                "Ende: ${DateFormat('dd.MM.yyyy HH:mm').format(startDate.toLocal())}",
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),

              Text(
                "Segmente: $segments",
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}