import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'package:cloud_functions/cloud_functions.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final String challengeId;

  const ChallengeDetailScreen({super.key, required this.challengeId});

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  final functions = FirebaseFunctions.instance;

  bool loading = true;

  Map<String, dynamic>? challenge;
  Map<String, dynamic>? currentSegment;

  List segments = [];
  List leaderboard = [];

  @override
  void initState() {
    super.initState();
    loadChallengeState();
  }

  Future<void> loadChallengeState() async {
    final result = await functions
        .httpsCallable('getCurrentChallengeState')
        .call({'challengeId': widget.challengeId});

    final data = Map<String, dynamic>.from(result.data);

    setState(() {
      challenge = Map<String, dynamic>.from(data['challenge'] ?? {});
      currentSegment = data['currentSegment'] != null
          ? Map<String, dynamic>.from(data['currentSegment'])
          : null;

      segments = (data['segments'] ?? []) as List;
      leaderboard = (data['leaderboard'] ?? []) as List;
      loading = false;
      print(currentSegment);
    });
  }

  String s(dynamic v) => v?.toString() ?? '';

  int i(dynamic v) => (v is int) ? v : int.tryParse(v.toString()) ?? 0;

  double d(dynamic v) => (v is num) ? v.toDouble() : 0.0;

  Color statusColor(bool active, bool past, bool upcoming) {
    if (active) return Colors.green;
    if (past) return Colors.grey;
    if (upcoming) return Colors.orange;
    return Colors.blueGrey;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(s(challenge?['name'])),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// HEADER CARD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              s(challenge?['description']),
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 15,
                color: colorScheme.onSurface,
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// CURRENT SEGMENT
          Text(
            "Aktuelles Segment",
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),

          const SizedBox(height: 10),

          if (currentSegment == null)
            Text(
              "Kein aktives Segment",
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
            )
          else
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  s(currentSegment!['name']),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  "Woche ${i(currentSegment!['weekIndex']) + 1}",
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 20),

          /// SEGMENTS TITLE
          Text(
            "Alle Segmente",
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),

          const SizedBox(height: 10),

          ...segments.map((segment) {
            final map = Map<String, dynamic>.from(segment);

            final active = map['isActive'] ?? false;
            final past = map['isPast'] ?? false;
            final upcoming = map['isUpcoming'] ?? false;

            final color = statusColor(active, past, upcoming);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  s(map['name']),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  active
                      ? "Aktiv"
                      : past
                      ? "Abgeschlossen"
                      : "Kommend",
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "W${i(map['weekIndex']) + 1}",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          /// LEADERBOARD
          Text(
            "Leaderboard",
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),

          const SizedBox(height: 10),

          if (leaderboard.isEmpty)
            Text(
              "Noch keine Einträge",
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
            )
          else
            ...leaderboard.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final data = Map<String, dynamic>.from(entry.value);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primary,
                    child: Text(
                      "$rank",
                      style: TextStyle(color: colorScheme.onPrimary),
                    ),
                  ),
                  title: Text(
                    s(data['userName']),
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  subtitle: Text(
                    "${d(data['bestTime'])} sec",
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
