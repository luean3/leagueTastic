import 'package:flutter/material.dart';

class StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double valueFontSize;
  final double labelFontSize;
  final double spacing;

  const StatBox({
    super.key,
    required this.label,
    required this.value,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
    this.borderRadius = 12,
    this.valueFontSize = 16,
    this.labelFontSize = 12,
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: valueFontSize,
              color: colorScheme.primary,
            ),
          ),
          SizedBox(height: spacing),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: labelFontSize,
              color: colorScheme.onSurface.withOpacity(0.65),
            ),
          ),
        ],
      ),
    );
  }
}
