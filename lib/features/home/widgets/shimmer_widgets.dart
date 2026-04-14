import 'package:flutter/material.dart';

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class DailyGoalShimmer extends StatelessWidget {
  const DailyGoalShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: 80, height: 16, borderRadius: 8),
              ShimmerBox(width: 60, height: 24, borderRadius: 12),
            ],
          ),
          SizedBox(height: 8),
          ShimmerBox(width: 200, height: 48, borderRadius: 8),
          SizedBox(height: 16),
          ShimmerBox(width: double.infinity, height: 8, borderRadius: 4),
        ],
      ),
    );
  }
}

class StatCardShimmer extends StatelessWidget {
  const StatCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 22, height: 22, borderRadius: 11),
          SizedBox(height: 8),
          ShimmerBox(width: 46, height: 24, borderRadius: 8),
          SizedBox(height: 6),
          ShimmerBox(width: 70, height: 20, borderRadius: 8),
        ],
      ),
    );
  }
}

class LessonItemShimmer extends StatelessWidget {
  const LessonItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          ShimmerBox(width: 46, height: 46, borderRadius: 12),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 140, height: 18, borderRadius: 6),
                SizedBox(height: 6),
                ShimmerBox(width: 120, height: 14, borderRadius: 6),
              ],
            ),
          ),
          SizedBox(width: 12),
          ShimmerBox(width: 46, height: 24, borderRadius: 12),
        ],
      ),
    );
  }
}

class LeaderboardShimmer extends StatelessWidget {
  const LeaderboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          ShimmerBox(width: 28, height: 20, borderRadius: 6),
          SizedBox(width: 10),
          Expanded(
            child:
                ShimmerBox(width: double.infinity, height: 18, borderRadius: 6),
          ),
          SizedBox(width: 10),
          ShimmerBox(width: 56, height: 18, borderRadius: 6),
        ],
      ),
    );
  }
}
