import 'package:flutter/material.dart';
import 'package:leaguetastic/l10n/app_localizations.dart';

/// Formularfelder für Name, Beschreibung und Startdatum einer Challenge.
class ChallengeFormSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final DateTime? startDate;
  final VoidCallback onPickStartDate;

  const ChallengeFormSection({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.startDate,
    required this.onPickStartDate,
  });

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}."
        "${date.month.toString().padLeft(2, '0')}."
        "${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: locale.challengeName,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return locale.pleaseEnterChallengeName;
            }
            return null;
          },
        ),

        const SizedBox(height: 14),

        TextFormField(
          controller: descriptionController,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: locale.description,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 14),

        OutlinedButton.icon(
          onPressed: onPickStartDate,
          icon: const Icon(Icons.calendar_today),
          label: Text(
            startDate == null
                ? locale.selectStartDate
                : _formatDate(startDate!),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.onSurface,
            padding: const EdgeInsets.symmetric(vertical: 14),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
