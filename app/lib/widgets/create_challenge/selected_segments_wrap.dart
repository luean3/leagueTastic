import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/explore_segment.dart';

class SelectedSegmentsWrap extends StatelessWidget {
  final List<ExploreSegment> selectedSegments;
  final void Function(ExploreSegment segment) onRemove;

  const SelectedSegmentsWrap({
    super.key,
    required this.selectedSegments,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedSegments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      children: [
        for (int i = 0; i < selectedSegments.length; i++)
          Container(
            margin: const EdgeInsets.only(right: 8, bottom: 8),
            child: InputChip(
              label: Text(
                "${i + 1}. ${selectedSegments[i].name}",
                overflow: TextOverflow.ellipsis,
              ),
              onDeleted: () => onRemove(selectedSegments[i]),
              backgroundColor: AppColors.primary.withOpacity(0.12),
            ),
          ),
      ],
    );
  }
}