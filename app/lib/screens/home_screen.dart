import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/challenge_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:leaguetastic/l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _getMyChallenges() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    final userId = user.uid;

    return FirebaseFirestore.instance
        .collection('userChallenges')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((userChallengesSnapshot) async {
      final challengeIds = userChallengesSnapshot.docs
          .map((doc) => doc.data()['challengeId'] as String?)
          .whereType<String>()
          .toList();

      if (challengeIds.isEmpty) {
        return [];
      }

      final challengeSnapshot = await FirebaseFirestore.instance
          .collection('challenges')
          .where(FieldPath.documentId, whereIn: challengeIds)
          .get();

      final docs = challengeSnapshot.docs;

      docs.sort((a, b) {
        final aDate = a.data()['startDate'] as Timestamp?;
        final bDate = b.data()['startDate'] as Timestamp?;

        if (aDate == null || bDate == null) {
          return 0;
        }

        return bDate.compareTo(aDate);
      });

      return docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: AppColors.primary,
              child: const Text(
                "LeagueTastic",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              locale.rideCompeteWin,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  locale.myChallenges,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<
                  List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                stream: _getMyChallenges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        locale.errorLoadingChallenges,
                        style: TextStyle(
                          color: colorScheme.error,
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        locale.noJoinedChallenges,
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    );
                  }

                  final docs = snapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data();

                      return ChallengeCard(
                        id: doc.id,
                        title: data['name'] ?? '',
                        description: data['description'] ?? '',
                        startDate: (data['startDate'] as Timestamp).toDate(),
                        endDate: (data['endDate'] as Timestamp).toDate(),
                        segments: (data['segmentIds'] as List?)?.length ?? 0,
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