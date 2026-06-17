import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Einheitlicher Brand-Header für Hauptseiten.
class AppHeader extends StatelessWidget {
  final String title;

  const AppHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: AppColors.primary,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
