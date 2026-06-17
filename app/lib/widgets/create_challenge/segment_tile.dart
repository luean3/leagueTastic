import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/explore_segment.dart';

class SegmentTile extends StatelessWidget {
  final ExploreSegment segment;
  final bool selected;
  final VoidCallback onTap;

  const SegmentTile({
    super.key,
    required this.segment,
    required this.selected,
    required this.onTap,
  });

  String _subtitle() {
    final parts = <String>[];

    if (segment.city != null && segment.city!.isNotEmpty) {
      parts.add(segment.city!);
    }

    if (segment.distance != null) {
      parts.add("${(segment.distance! / 1000).toStringAsFixed(1)} km");
    }

    if (segment.avgGrade != null) {
      parts.add("${segment.avgGrade!.toStringAsFixed(1)}%");
    }

    return parts.join(" · ");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.12)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : colorScheme.onSurface.withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected
                  ? AppColors.primary
                  : colorScheme.onSurface.withOpacity(0.5),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    segment.name.isEmpty ? segment.id : segment.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 4),

                  if (_subtitle().isNotEmpty)
                    Text(
                      _subtitle(),
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.65),
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}