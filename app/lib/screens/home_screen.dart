import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/challenge_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: AppColors.primary,
              child: const Text(
                "LeagueTastic",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Ride. Compete. Win.",
              style: TextStyle(color: AppColors.textPrimary),
            ),

            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Aktuelle Challenges",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // FIREBASE STREAM
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('challenges')
                    .orderBy('startDate', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "Keine Challenges vorhanden",
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data =
                      docs[index].data() as Map<String, dynamic>;

                      return ChallengeCard(
                        id: data['id'],
                        title: data['name'] ?? '',
                        description: data['description'] ?? '',
                        startDate:
                        (data['startDate'] as Timestamp).toDate(),
                        endDate:
                        (data['endDate'] as Timestamp).toDate(),
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