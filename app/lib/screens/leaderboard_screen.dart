import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/map_widget.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final leaderboard = [
      {"name": "Nico", "time": "12:34"},
      {"name": "Lukas", "time": "13:02"},
      {"name": "Anna", "time": "13:45"},
      {"name": "Tom", "time": "14:10"},
    ];

    final String polylineString =
        "uwz~Gc~|l@u@e@w@q@_Ao@g@c@eAo@_Au@k@g@qAuAkCiD{KgOyB_DwCmEyEqG_AwAaAsAoByC";

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              "Aktuelles Segment",
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            // MAP
            Container(
              height: 300,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.onSurface.withOpacity(0.1),
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: polylineString.isEmpty
                  ? Center(
                child: Text(
                  "No route",
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              )
                  : StravaMapWidget(
                encodedPolyline: polylineString,
              ),
            ),

            const SizedBox(height: 16),

            // LIST
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
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "#${index + 1}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            user["name"]!,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Text(
                          user["time"]!,
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
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