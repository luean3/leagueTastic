import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:leaguetastic/l10n/app_localizations.dart';
import '../widgets/segment_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'segment_detail_screen.dart';

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
  Map<String, dynamic>? myCurrentSegmentResult;

  List segments = [];
  List leaderboard = [];

  String formatTime(dynamic value) {
    final totalSeconds = i(value);

    if (totalSeconds <= 0) {
      return "-";
    }

    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  Future<Map<String, dynamic>?> loadMyCurrentSegmentResult({
    required String challengeId,
    required Map<String, dynamic>? currentSegment,
  }) async {
    if (currentSegment == null) {
      return null;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return null;
    }

    final firebaseUserId = user.uid;
    final db = FirebaseFirestore.instance;

    // 1. User-Dokument laden
    final userDoc = await db.collection('users').doc(firebaseUserId).get();

    final userData = userDoc.data();

    if (userData == null) {
      return null;
    }

    // athleteId aus users holen
    final athleteId = s(userData['athleteId']);

    if (athleteId.isEmpty) {
      return null;
    }

    final segmentId = s(
      currentSegment['segmentId'] ??
          currentSegment['id'] ??
          currentSegment['stravaSegmentId'],
    );

    if (segmentId.isEmpty) {
      return null;
    }

    // 2. Bestzeit, Rang und Punkte aus Segment-Leaderboard holen
    // Wichtig: Hier athleteId verwenden, falls die entries mit athleteId gespeichert sind
    final leaderboardDoc = await db
        .collection('segmentLeaderboards')
        .doc('${challengeId}_$segmentId')
        .collection('entries')
        .doc(athleteId)
        .get();

    final leaderboardData = leaderboardDoc.data();

    // 3. Anzahl Versuche aus segmentEfforts zählen
    // Wichtig: Hier ebenfalls athleteId verwenden
    final effortsSnap = await db
        .collection('segmentEfforts')
        .where('userId', isEqualTo: athleteId)
        .where('segmentId', isEqualTo: segmentId)
        .where('processedChallengeIds', arrayContains: challengeId)
        .get();

    return {
      'segmentId': segmentId,
      'attempts': effortsSnap.size,
      'hasResult': leaderboardDoc.exists,
      'bestTime': leaderboardData?['bestTime'],
      'rank': leaderboardData?['rank'],
      'points': leaderboardData?['points'] ?? 0,
    };
  }

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

    final loadedChallenge = Map<String, dynamic>.from(data['challenge'] ?? {});

    final loadedCurrentSegment = data['currentSegment'] != null
        ? Map<String, dynamic>.from(data['currentSegment'])
        : null;

    final loadedSegments = (data['segments'] ?? []) as List;
    final loadedLeaderboard = (data['leaderboard'] ?? []) as List;

    final loadedMyCurrentSegmentResult = await loadMyCurrentSegmentResult(
      challengeId: widget.challengeId,
      currentSegment: loadedCurrentSegment,
    );

    if (!mounted) return;

    setState(() {
      challenge = loadedChallenge;
      currentSegment = loadedCurrentSegment;
      segments = loadedSegments;
      leaderboard = loadedLeaderboard;
      myCurrentSegmentResult = loadedMyCurrentSegmentResult;
      loading = false;
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
    final locale = AppLocalizations.of(context)!;

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
            locale.currentSegment,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),

          const SizedBox(height: 10),

          if (currentSegment == null)
            Text(
              locale.noActiveSegment,
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
            )
          else
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SegmentDetailScreen(
                      challengeId: widget.challengeId,
                      segment: Map<String, dynamic>.from(currentSegment!),
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s(currentSegment!['name']),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "${locale.week} ${i(currentSegment!['weekIndex']) + 1}",
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: _SegmentStatBox(
                            label: locale.my_time,
                            value: formatTime(
                              myCurrentSegmentResult?['bestTime'],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SegmentStatBox(
                            label: locale.attempts,
                            value: "${myCurrentSegmentResult?['attempts'] ?? 0}",
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SegmentStatBox(
                            label: locale.rank,
                            value: myCurrentSegmentResult?['rank'] != null
                                ? "#${myCurrentSegmentResult!['rank']}"
                                : "-",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),

          /// SEGMENTS TITLE
          Text(
            locale.allSegments,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),

          const SizedBox(height: 10),

          ...segments.map((segment) {
            final map = Map<String, dynamic>.from(segment);

            return SegmentCard(
              segment: map,
              activeLabel: locale.active,
              finishedLabel: locale.finished,
              upcomingLabel: locale.upcoming,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SegmentDetailScreen(
                      challengeId: widget.challengeId,
                      segment: map,
                    ),
                  ),
                );
              },
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
              locale.noEntries,
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
                    s(data['userName']).isNotEmpty
                        ? s(data['userName'])
                        : "Anonymous",
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  subtitle: Text(
                    "${data['totalPoints']?.toInt() ?? 0} ${data['totalPoints'] == 1 ? locale.point : locale.points}",
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

class _SegmentStatBox extends StatelessWidget {
  final String label;
  final String value;

  const _SegmentStatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.75),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurface.withOpacity(0.65),
            ),
          ),
        ],
      ),
    );
  }
}
