import 'package:flutter/material.dart';
import 'package:leaguetastic/l10n/app_localizations.dart';

import '../controllers/create_challenge_controller.dart';
import '../core/theme/app_colors.dart';
import '../models/explore_segment.dart';
import '../widgets/app_header.dart';
import '../widgets/create_challenge/challenge_form_section.dart';
import '../widgets/create_challenge/segment_search_section.dart';

/// Seite zum Erstellen einer neuen Challenge aus Strava-Segmenten.
class CreateScreen extends StatefulWidget {
  /// Wird nach erfolgreichem Speichern ausgelöst, damit der Parent die
  /// bestehende Navigation weiterverwenden kann.
  final VoidCallback? onChallengeCreated;

  const CreateScreen({super.key, this.onChallengeCreated});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _segmentSearchController = TextEditingController();

  final CreateChallengeController _controller = CreateChallengeController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refresh);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _segmentSearchController.dispose();
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _loadNearbySegments() async {
    final locale = AppLocalizations.of(context)!;

    try {
      final loaded = await _controller.loadNearbySegments();

      if (!loaded) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(locale.locationPermissionRequired)),
        );
        return;
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${locale.errorLoadingSegments}: $e")),
      );
    }
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2030),
      initialDate: _controller.startDate ?? now,
    );

    if (picked != null) {
      _controller.selectStartDate(picked);
    }
  }

  void _toggleSegment(ExploreSegment segment) {
    _controller.toggleSegment(segment);
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _descriptionController.clear();
    _segmentSearchController.clear();
    _controller.reset();
  }

  Future<void> _saveChallenge() async {
    final locale = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final result = await _controller.createChallenge(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      if (!mounted) return;

      if (result != CreateChallengeResult.created) {
        final message = switch (result) {
          CreateChallengeResult.notLoggedIn => locale.notLoggedIn,
          CreateChallengeResult.startDateMissing =>
            locale.pleaseSelectStartDate,
          CreateChallengeResult.segmentsMissing => locale.pleaseSelectSegments,
          CreateChallengeResult.created => '',
        };
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(locale.challengeCreated)));

      // Kein eigener HomeScreen-Push: Sonst ginge die Bottom-Navigation verloren.
      _resetForm();
      widget.onChallengeCreated?.call();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${locale.errorCreatingChallenge}: $e")),
      );
    }
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
            const AppHeader(title: "LeagueTastic"),

            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      locale.createChallenge,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      locale.createChallengeSubtitle,
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                    ),

                    const SizedBox(height: 24),

                    ChallengeFormSection(
                      nameController: _nameController,
                      descriptionController: _descriptionController,
                      startDate: _controller.startDate,
                      onPickStartDate: _pickStartDate,
                    ),

                    const SizedBox(height: 28),

                    SegmentSearchSection(
                      searchController: _segmentSearchController,
                      availableSegments: _controller.availableSegments,
                      selectedSegments: _controller.selectedSegments,
                      isLoading: _controller.isLoadingSegments,
                      onLoadNearbySegments: _loadNearbySegments,
                      onSearchChanged: (_) {
                        setState(() {});
                      },
                      onToggleSegment: _toggleSegment,
                    ),

                    const SizedBox(height: 28),

                    ElevatedButton(
                      onPressed: _controller.isSaving ? null : _saveChallenge,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: colorScheme.onSurface
                            .withValues(alpha: 0.12),
                        disabledForegroundColor: colorScheme.onSurface
                            .withValues(alpha: 0.45),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _controller.isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(locale.saveChallenge),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
