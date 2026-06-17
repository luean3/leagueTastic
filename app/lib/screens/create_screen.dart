import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:leaguetastic/l10n/app_localizations.dart';

import '../core/theme/app_colors.dart';
import '../models/explore_segment.dart';
import '../repositories/segment_repository.dart';
import '../services/challenge_functions_service.dart';
import '../widgets/create_challenge/challenge_form_section.dart';
import '../widgets/create_challenge/segment_search_section.dart';
import 'home_screen.dart';
class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _segmentSearchController = TextEditingController();

  final _functionsService = ChallengeFunctionsService();
  final _segmentRepository = SegmentRepository();

  DateTime? _startDate;

  bool _isLoadingSegments = false;
  bool _isSaving = false;

  List<ExploreSegment> _availableSegments = [];
  final List<ExploreSegment> _selectedSegments = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _segmentSearchController.dispose();
    super.dispose();
  }

  Future<bool> _ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return false;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  String _buildBounds(Position position) {
    const delta = 0.08;

    final southWestLat = position.latitude - delta;
    final southWestLng = position.longitude - delta;
    final northEastLat = position.latitude + delta;
    final northEastLng = position.longitude + delta;

    return "$southWestLat,$southWestLng,$northEastLat,$northEastLng";
  }

  Future<void> _loadNearbySegments() async {
    final locale = AppLocalizations.of(context)!;

    setState(() {
      _isLoadingSegments = true;
    });

    try {
      final hasPermission = await _ensureLocationPermission();

      if (!hasPermission) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(locale.locationPermissionRequired)),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final bounds = _buildBounds(position);

      final segmentIds = await _functionsService.exploreSegments(
        bounds: bounds,
      );

      final segments = await _segmentRepository.getExploreSegmentsByIds(
        segmentIds,
      );

      setState(() {
        _availableSegments = segments;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${locale.errorLoadingSegments}: $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSegments = false;
        });
      }
    }
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2030),
      initialDate: _startDate ?? now,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _toggleSegment(ExploreSegment segment) {
    setState(() {
      final alreadySelected = _selectedSegments.any(
            (selected) => selected.id == segment.id,
      );

      if (alreadySelected) {
        _selectedSegments.removeWhere(
              (selected) => selected.id == segment.id,
        );
      } else {
        _selectedSegments.add(segment);
      }
    });
  }

  Future<void> _saveChallenge() async {
    final locale = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(locale.notLoggedIn)),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(locale.pleaseSelectStartDate)),
      );
      return;
    }

    if (_selectedSegments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(locale.pleaseSelectSegments)),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _functionsService.createChallenge(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        startDate: _startDate!,
        segmentIds: _selectedSegments.map((segment) => segment.id).toList(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(locale.challengeCreated)),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${locale.errorCreatingChallenge}: $e"),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
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
                        color: colorScheme.onSurface.withOpacity(0.65),
                      ),
                    ),

                    const SizedBox(height: 24),

                    ChallengeFormSection(
                      nameController: _nameController,
                      descriptionController: _descriptionController,
                      startDate: _startDate,
                      onPickStartDate: _pickStartDate,
                    ),

                    const SizedBox(height: 28),

                    SegmentSearchSection(
                      searchController: _segmentSearchController,
                      availableSegments: _availableSegments,
                      selectedSegments: _selectedSegments,
                      isLoading: _isLoadingSegments,
                      onLoadNearbySegments: _loadNearbySegments,
                      onSearchChanged: (_) {
                        setState(() {});
                      },
                      onToggleSegment: _toggleSegment,
                    ),

                    const SizedBox(height: 28),

                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveChallenge,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                        colorScheme.onSurface.withOpacity(0.12),
                        disabledForegroundColor:
                        colorScheme.onSurface.withOpacity(0.45),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _isSaving
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