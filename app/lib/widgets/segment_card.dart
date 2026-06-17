import 'package:flutter/material.dart';

import '../utils/value_parser.dart';

class SegmentCard extends StatelessWidget {
  final Map<String, dynamic> segment;
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

    final active = ValueParser.boolean(segment['isActive']);
    final past = ValueParser.boolean(segment['isPast']);
    final upcoming = ValueParser.boolean(segment['isUpcoming']);

    final color = _statusColor(active: active, past: past, upcoming: upcoming);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          ValueParser.string(segment['name']),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          _statusText(active: active, past: past, upcoming: upcoming),
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "W${ValueParser.integer(segment['weekIndex']) + 1}",
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
