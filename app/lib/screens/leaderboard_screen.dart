import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/map_widget.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final leaderboard = [
      {"name": "Nico", "time": "12:34"},
      {"name": "Lukas", "time": "13:02"},
      {"name": "Anna", "time": "13:45"},
      {"name": "Tom", "time": "14:10"},
    ];

    // TEST POLYLINE (cleaned, no hidden chars)
    final String polylineString =
        "uwz~Gc~|l@u@e@w@q@_Ao@g@c@eAo@_Au@k@g@qAuAkCiD{KgOyB_DwCmEyEqG_AwAaAsAoByC";

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: AppColors.primary,
              child: const Text(
                "Leaderboard",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "Aktuelles Segment",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 16),

            // MAP (SAFE)
            Container(
              height: 300,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              clipBehavior: Clip.hardEdge,
              child: polylineString.isEmpty
                  ? const Center(child: Text("No route"))
                  : StravaMapWidget(encodedPolyline: polylineString),
            ),

            const SizedBox(height: 16),

            // LIST (FIXED OVERFLOW)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: leaderboard.length,
                itemBuilder: (context, index) {
                  final user = leaderboard[index];

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "#${index + 1}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: Text(user["name"]!)),
                        Text(user["time"]!),
                      ],
                    ),
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