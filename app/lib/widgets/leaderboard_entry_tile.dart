import 'package:flutter/material.dart';

/// Wiederverwendbarer Leaderboard-Eintrag mit Rang, Name und Zusatzwerten.
class LeaderboardEntryTile extends StatelessWidget {
  final String rankText;
  final String title;
  final String subtitle;
  final String? trailingText;
  final Color? backgroundColor;

  const LeaderboardEntryTile({
    super.key,
    required this.rankText,
    required this.title,
    required this.subtitle,
    this.trailingText,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primary,
          child: Text(rankText, style: TextStyle(color: colorScheme.onPrimary)),
        ),
        title: Text(title, style: TextStyle(color: colorScheme.onSurface)),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
        trailing: trailingText == null
            ? null
            : Text(
                trailingText!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
      ),
    );
  }
}
