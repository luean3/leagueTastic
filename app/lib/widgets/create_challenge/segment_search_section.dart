import 'package:flutter/material.dart';
import 'package:leaguetastic/l10n/app_localizations.dart';

import '../../models/explore_segment.dart';
import 'segment_tile.dart';
import 'selected_segments_wrap.dart';

/// Segment-Auswahlbereich mit Umkreissuche, Filterfeld und Auswahlchips.
class SegmentSearchSection extends StatelessWidget {
  final TextEditingController searchController;
  final List<ExploreSegment> availableSegments;
  final List<ExploreSegment> selectedSegments;
  final bool isLoading;
  final VoidCallback onLoadNearbySegments;
  final void Function(String value) onSearchChanged;
  final void Function(ExploreSegment segment) onToggleSegment;

  const SegmentSearchSection({
    super.key,
    required this.searchController,
    required this.availableSegments,
    required this.selectedSegments,
    required this.isLoading,
    required this.onLoadNearbySegments,
    required this.onSearchChanged,
    required this.onToggleSegment,
  });

  bool _isSelected(ExploreSegment segment) {
    return selectedSegments.any((selected) => selected.id == segment.id);
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final query = searchController.text.toLowerCase().trim();

    final filteredSegments = query.isEmpty
        ? availableSegments
        : availableSegments.where((segment) {
      return segment.name.toLowerCase().contains(query) ||
          (segment.city ?? '').toLowerCase().contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                locale.selectSegments,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Text(
              locale.selectedSegmentCount(selectedSegments.length),
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        SelectedSegmentsWrap(
          selectedSegments: selectedSegments,
          onRemove: onToggleSegment,
        ),

        const SizedBox(height: 10),

        ElevatedButton.icon(
          onPressed: isLoading ? null : onLoadNearbySegments,
          icon: isLoading
              ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.onPrimary,
            ),
          )
              : const Icon(Icons.explore),
          label: Text(
            isLoading ? locale.loadingSegments : locale.loadNearbySegments,
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 14),

        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: locale.searchSegment,
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: theme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 14),

        if (availableSegments.isEmpty && !isLoading)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              locale.noSegmentsLoaded,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
          )
        else if (filteredSegments.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              locale.noMatchingSegmentFound,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
          )
        else
          ...filteredSegments.map(
                (segment) => SegmentTile(
              segment: segment,
              selected: _isSelected(segment),
              onTap: () => onToggleSegment(segment),
            ),
          ),
      ],
    );
  }
}
