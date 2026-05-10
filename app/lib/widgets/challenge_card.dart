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
    return GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => ChallengeDetailScreen(challengeId: id),
          ),
          );
        },
        child: Card(
          color: AppColors.primary.withOpacity(0.15),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  "Start: ${startDate.toLocal()}",
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  "Ende: ${endDate.toLocal()}",
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  "Segmente: ${segments}",
                  style: const TextStyle(
                    color: AppColors.textPrimary,
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