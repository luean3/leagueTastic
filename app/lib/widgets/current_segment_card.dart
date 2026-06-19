import 'package:flutter/material.dart';
import 'package:leaguetastic/l10n/app_localizations.dart';

import '../models/challenge_state.dart';
import '../models/segment_performance.dart';
import '../utils/app_formatters.dart';
import 'common/stat_box.dart';

/// Karte für das aktuell aktive Segment mit den persönlichen Kennzahlen.
class CurrentSegmentCard extends StatelessWidget {
  final ChallengeSegment segment;
  final SegmentPerformance? performance;
  final VoidCallback onTap;

  const CurrentSegmentCard({
    super.key,
    required this.segment,
    required this.performance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final locale = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              segment.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${locale.week} ${segment.weekIndex + 1}",
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: StatBox(
                    label: locale.my_time,
                    value: AppFormatters.duration(performance?.bestTime),
                    backgroundColor: colorScheme.surface.withValues(
                      alpha: 0.75,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    borderRadius: 10,
                    valueFontSize: 15,
                    labelFontSize: 11,
                    spacing: 2,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatBox(
                    label: locale.attempts,
                    value: '${performance?.attempts ?? 0}',
                    backgroundColor: colorScheme.surface.withValues(
                      alpha: 0.75,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    borderRadius: 10,
                    valueFontSize: 15,
                    labelFontSize: 11,
                    spacing: 2,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatBox(
                    label: locale.rank,
                    value: performance?.rank != null
                        ? '#${performance!.rank}'
                        : '-',
                    backgroundColor: colorScheme.surface.withValues(
                      alpha: 0.75,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    borderRadius: 10,
                    valueFontSize: 15,
                    labelFontSize: 11,
                    spacing: 2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
