import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:leaguetastic/l10n/app_localizations.dart';

import '../core/theme/app_colors.dart';
import 'challenge_detail_screen.dart';

class ChallengeSearchScreen extends StatefulWidget {
  const ChallengeSearchScreen({super.key});

  @override
  State<ChallengeSearchScreen> createState() => _ChallengeSearchScreenState();
}

class _ChallengeSearchScreenState extends State<ChallengeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _joinChallenge({
    required BuildContext context,
    required String challengeId,
  }) async {
    final locale = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(locale.notLoggedIn),
        ),
      );
      return;
    }

    final userId = user.uid;

    final existing = await FirebaseFirestore.instance
        .collection('userChallenges')
        .where('userId', isEqualTo: userId)
        .where('challengeId', isEqualTo: challengeId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(locale.alreadyJoinedSnackbar),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('userChallenges').add({
      'userId': userId,
      'challengeId': challengeId,
      'joinedAt': FieldValue.serverTimestamp(),
    });

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(locale.joinedChallenge),
      ),
    );
  }

  String _formatDate(dynamic value) {
    if (value == null || value is! Timestamp) {
      return "";
    }

    final date = value.toDate();

    return "${date.day.toString().padLeft(2, '0')}."
        "${date.month.toString().padLeft(2, '0')}."
        "${date.year}";
  }

  bool _matchesSearch(Map<String, dynamic> data) {
    if (_searchText.trim().isEmpty) {
      return true;
    }

    final query = _searchText.toLowerCase().trim();

    final name = (data['name'] ?? '').toString().toLowerCase();
    final description = (data['description'] ?? '').toString().toLowerCase();

    return name.contains(query) || description.contains(query);
  }

  void _openChallengeDetail({
    required BuildContext context,
    required String challengeId,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChallengeDetailScreen(
          challengeId: challengeId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final locale = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Text(
            locale.notLoggedIn,
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: AppColors.primary,
              child: Text(
                locale.findChallenges,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: locale.searchChallenge,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.onSurface.withOpacity(0.1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.onSurface.withOpacity(0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('challenges')
                    .orderBy('startDate', descending: true)
                    .snapshots(),
                builder: (context, challengeSnapshot) {
                  if (challengeSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    );
                  }

                  if (challengeSnapshot.hasError) {
                    return Center(
                      child: Text(
                        locale.errorLoadingChallenges,
                        style: TextStyle(
                          color: colorScheme.error,
                        ),
                      ),
                    );
                  }

                  if (!challengeSnapshot.hasData ||
                      challengeSnapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        locale.noChallengesAvailable,
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    );
                  }

                  final allChallenges = challengeSnapshot.data!.docs
                      .where((doc) => _matchesSearch(doc.data()))
                      .toList();

                  if (allChallenges.isEmpty) {
                    return Center(
                      child: Text(
                        locale.noMatchingChallengeFound,
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    );
                  }

                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('userChallenges')
                        .where('userId', isEqualTo: user.uid)
                        .snapshots(),
                    builder: (context, userChallengeSnapshot) {
                      final joinedChallengeIds =
                          userChallengeSnapshot.data?.docs
                              .map(
                                (doc) =>
                            doc.data()['challengeId'] as String?,
                          )
                              .whereType<String>()
                              .toSet() ??
                              <String>{};

                      return ListView.builder(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 16,
                        ),
                        itemCount: allChallenges.length,
                        itemBuilder: (context, index) {
                          final doc = allChallenges[index];
                          final data = doc.data();

                          final challengeId = doc.id;
                          final alreadyJoined =
                          joinedChallengeIds.contains(challengeId);

                          final name = data['name'] ?? '';
                          final description = data['description'] ?? '';
                          final segmentCount =
                              (data['segmentIds'] as List?)?.length ?? 0;

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                _openChallengeDetail(
                                  context: context,
                                  challengeId: challengeId,
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                    colorScheme.onSurface.withOpacity(0.08),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            name.toString(),
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                        ),
                                        if (alreadyJoined)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withOpacity(0.12),
                                              borderRadius:
                                              BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              locale.alreadyJoined,
                                              style: const TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    if (description.toString().isNotEmpty)
                                      Text(
                                        description.toString(),
                                        style: TextStyle(
                                          color: colorScheme.onSurface
                                              .withOpacity(0.7),
                                        ),
                                      ),

                                    const SizedBox(height: 12),

                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: colorScheme.onSurface
                                              .withOpacity(0.6),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "${_formatDate(data['startDate'])} - ${_formatDate(data['endDate'])}",
                                          style: TextStyle(
                                            color: colorScheme.onSurface
                                                .withOpacity(0.6),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    Row(
                                      children: [
                                        Icon(
                                          Icons.route,
                                          size: 16,
                                          color: colorScheme.onSurface
                                              .withOpacity(0.6),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          locale.segments(segmentCount),
                                          style: TextStyle(
                                            color: colorScheme.onSurface
                                                .withOpacity(0.6),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 14),

                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: alreadyJoined
                                            ? null
                                            : () {
                                          _joinChallenge(
                                            context: context,
                                            challengeId: challengeId,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor: colorScheme
                                              .onSurface
                                              .withOpacity(0.12),
                                          disabledForegroundColor: colorScheme
                                              .onSurface
                                              .withOpacity(0.45),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Text(
                                          alreadyJoined
                                              ? locale.alreadyJoinedChallenge
                                              : locale.joinChallenge,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}