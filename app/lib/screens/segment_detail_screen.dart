import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:leaguetastic/l10n/app_localizations.dart';

import '../widgets/map_widget.dart';

class SegmentDetailScreen extends StatefulWidget {
  final String challengeId;
  final Map<String, dynamic> segment;

  const SegmentDetailScreen({
    super.key,
    required this.challengeId,
    required this.segment,
  });

  @override
  State<SegmentDetailScreen> createState() => _SegmentDetailScreenState();
}

class _SegmentDetailScreenState extends State<SegmentDetailScreen> {
  bool loading = true;

  String? athleteId;
  Map<String, dynamic>? myResult;
  List<Map<String, dynamic>> myEfforts = [];
  List<Map<String, dynamic>> leaderboard = [];

  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    loadSegmentDetails();
  }

  String s(dynamic v) => v?.toString() ?? '';

  int i(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  double d(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  String formatTime(dynamic value) {
    final totalSeconds = i(value);

    if (totalSeconds <= 0) {
      return "-";
    }

    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  String formatDistance(dynamic value, AppLocalizations locale) {
    final distance = d(value);

    if (distance <= 0) {
      return "-";
    }

    if (distance >= 1000) {
      final km = distance / 1000;
      return "${km.toStringAsFixed(2)} km";
    }

    return "${distance.toStringAsFixed(0)} m";
  }

  String get segmentId {
    return s(
      widget.segment['segmentId'] ??
          widget.segment['id'] ??
          widget.segment['stravaSegmentId'],
    );
  }

  String get segmentName {
    final name = s(widget.segment['name']);

    if (name.isNotEmpty) {
      return name;
    }

    return "Segment";
  }

  Future<String?> loadAthleteId() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return null;
    }

    final userDoc = await db.collection('users').doc(user.uid).get();
    final userData = userDoc.data();

    if (userData == null) {
      return null;
    }

    final id = s(userData['athleteId']);

    if (id.isEmpty) {
      return null;
    }

    return id;
  }

  Future<void> loadSegmentDetails() async {
    try {
      final loadedAthleteId = await loadAthleteId();

      if (loadedAthleteId == null || segmentId.isEmpty) {
        if (!mounted) return;

        setState(() {
          loading = false;
        });

        return;
      }

      final leaderboardDocId = '${widget.challengeId}_$segmentId';

      final myLeaderboardDoc = await db
          .collection('segmentLeaderboards')
          .doc(leaderboardDocId)
          .collection('entries')
          .doc(loadedAthleteId)
          .get();

      // Kein orderBy hier, damit kein zusätzlicher Firestore Index nötig ist.
      final effortsSnap = await db
          .collection('segmentEfforts')
          .where('userId', isEqualTo: loadedAthleteId)
          .where('segmentId', isEqualTo: segmentId)
          .where('processedChallengeIds', arrayContains: widget.challengeId)
          .get();

      final leaderboardSnap = await db
          .collection('segmentLeaderboards')
          .doc(leaderboardDocId)
          .collection('entries')
          .orderBy('rank')
          .limit(50)
          .get();

      final loadedMyResult = myLeaderboardDoc.data();

      final loadedEfforts = effortsSnap.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      // Lokale Sortierung statt Firestore orderBy.
      loadedEfforts.sort((a, b) {
        final aTime = i(a['activityStartDateMs']);
        final bTime = i(b['activityStartDateMs']);
        return bTime.compareTo(aTime);
      });

      final loadedLeaderboard = leaderboardSnap.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      if (!mounted) return;

      setState(() {
        athleteId = loadedAthleteId;
        myResult = loadedMyResult;
        myEfforts = loadedEfforts;
        leaderboard = loadedLeaderboard;
        loading = false;
      });
    } catch (e) {
      debugPrint("Error loading segment details: $e");

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final locale = AppLocalizations.of(context)!;

    final segmentMap = widget.segment['map'] is Map
        ? Map<String, dynamic>.from(widget.segment['map'])
        : <String, dynamic>{};

    final polyline = s(
      widget.segment['polyline'] ??
          widget.segment['mapPolyline'] ??
          widget.segment['encodedPolyline'] ??
          widget.segment['polylineString'] ??
          widget.segment['summaryPolyline'] ??
          widget.segment['summary_polyline'] ??
          segmentMap['polyline'] ??
          segmentMap['summary_polyline'],
    );
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(segmentName),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle(title: locale.segment),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  segmentName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${locale.segmentId}: $segmentId",
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                if (widget.segment['weekIndex'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    "${locale.week} ${i(widget.segment['weekIndex']) + 1}",
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          if (polyline.isNotEmpty) ...[
            _SectionTitle(title: locale.route),
            Container(
              height: 260,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.hardEdge,
              child: StravaMapWidget(
                encodedPolyline: polyline,
              ),
            ),
            const SizedBox(height: 20),
          ],

          _SectionTitle(title: locale.myResult),

          Row(
            children: [
              Expanded(
                child: _StatBox(
                  label: locale.bestTime,
                  value: formatTime(myResult?['bestTime']),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatBox(
                  label: locale.rank,
                  value: myResult?['rank'] != null
                      ? "#${myResult!['rank']}"
                      : "-",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatBox(
                  label: locale.points,
                  value: "${myResult?['points'] ?? 0}",
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _SectionTitle(title: locale.myAttempts),

          if (myEfforts.isEmpty)
            Text(
              locale.noSegmentAttempts,
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            )
          else
            ...myEfforts.map((effort) {
              return _EffortTile(
                effort: effort,
                formatTime: formatTime,
                formatDistance: (value) => formatDistance(value, locale),
              );
            }),

          const SizedBox(height: 20),

          _SectionTitle(title: locale.segmentLeaderboard),

          if (leaderboard.isEmpty)
            Text(
              locale.noSegmentLeaderboardEntries,
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            )
          else
            ...leaderboard.map((entry) {
              final rank = i(entry['rank']);
              final points = i(entry['points']);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primary,
                    child: Text(
                      rank > 0 ? "$rank" : "-",
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  title: Text(
                    s(entry['userName']).isNotEmpty
                        ? s(entry['userName'])
                        : s(entry['displayName']).isNotEmpty
                        ? s(entry['displayName'])
                        : locale.anonymous,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    "$points ${points == 1 ? locale.point : locale.points}",
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  trailing: Text(
                    formatTime(entry['bestTime']),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withOpacity(0.65),
            ),
          ),
        ],
      ),
    );
  }
}

class _EffortTile extends StatelessWidget {
  final Map<String, dynamic> effort;
  final String Function(dynamic value) formatTime;
  final String Function(dynamic value) formatDistance;

  const _EffortTile({
    required this.effort,
    required this.formatTime,
    required this.formatDistance,
  });

  String s(dynamic v) => v?.toString() ?? '';

  DateTime? parseDate(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    return DateTime.tryParse(value.toString());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final activityDate = parseDate(
      effort['activityStartDateMs'] ??
          effort['activityStartDate'] ??
          effort['createdAt'],
    );

    final dateText = activityDate != null
        ? "${activityDate.day.toString().padLeft(2, '0')}.${activityDate.month.toString().padLeft(2, '0')}.${activityDate.year}"
        : "-";

    final effortTime = effort['movingTime'] ??
        effort['elapsedTime'] ??
        effort['time'] ??
        effort['bestTime'];

    final distance = effort['distance'];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          formatTime(effortTime),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          dateText,
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        trailing: distance != null
            ? Text(
          formatDistance(distance),
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        )
            : null,
      ),
    );
  }
}