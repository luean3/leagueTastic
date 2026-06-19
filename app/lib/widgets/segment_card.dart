import 'package:flutter/material.dart';

import '../models/challenge_state.dart';

/// Statuskarte für ein Challenge-Segment.
class SegmentCard extends StatelessWidget {
  final ChallengeSegment segment;
  final String activeLabel;
  final String finishedLabel;
  final String upcomingLabel;
  final VoidCallback? onTap;

  const SegmentCard({
    super.key,
    required this.segment,
    required this.activeLabel,
    required this.finishedLabel,
    required this.upcomingLabel,
    this.onTap,
  });

  Color _statusColor({
    required bool active,
    required bool past,
    required bool upcoming,
  }) {
    if (active) return Colors.green;
    if (past) return Colors.grey;
    if (upcoming) return Colors.orange;
    return Colors.blueGrey;
  }

  String _statusText({
    required bool active,
    required bool past,
    required bool upcoming,
  }) {
    if (active) return activeLabel;
    if (past) return finishedLabel;
    return upcomingLabel;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final active = segment.isActive;
    final past = segment.isPast;
    final upcoming = segment.isUpcoming;

    final color = _statusColor(active: active, past: past, upcoming: upcoming);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          segment.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          _statusText(active: active, past: past, upcoming: upcoming),
          style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "W${segment.weekIndex + 1}",
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
