import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

Widget _box(double w, double h, double r) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(r),
      ),
    );

class ExploreUnitCardShimmer extends StatelessWidget {
  const ExploreUnitCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _box(44, 44, 12),
          const Spacer(),
          _box(double.infinity, 14, 6),
          const SizedBox(height: 8),
          _box(80, 12, 6),
          const SizedBox(height: 6),
          _box(60, 10, 6),
        ],
      ),
    );
  }
}

class ExploreGridShimmer extends StatelessWidget {
  const ExploreGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: 8,
      itemBuilder: (_, __) => const ExploreUnitCardShimmer(),
    );
  }
}

class ExploreSubtopicShimmer extends StatelessWidget {
  const ExploreSubtopicShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            _box(36, 36, 10),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(double.infinity, 14, 6),
                  const SizedBox(height: 8),
                  _box(160, 11, 6),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _box(60, 32, 10),
          ],
        ),
      ),
    );
  }
}
