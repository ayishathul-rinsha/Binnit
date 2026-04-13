import 'package:flutter/material.dart';

/// Skeleton loader widget — pure Flutter, no external dependencies
class SkeletonLoader extends StatefulWidget {
  final int itemCount;

  const SkeletonLoader({super.key, this.itemCount = 4});

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.itemCount,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return _SkeletonCard(shimmerValue: _animation.value);
          },
        );
      },
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final double shimmerValue;

  const _SkeletonCard({required this.shimmerValue});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row
            Row(
              children: [
                _ShimmerBox(
                  width: 80,
                  height: 28,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  shimmerValue: shimmerValue,
                ),
                const Spacer(),
                _ShimmerBox(
                  width: 100,
                  height: 24,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  shimmerValue: shimmerValue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Avatar + text
            Row(
              children: [
                _ShimmerBox(
                  width: 40,
                  height: 40,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  shimmerValue: shimmerValue,
                  isCircle: true,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBox(
                        width: 140,
                        height: 14,
                        baseColor: baseColor,
                        highlightColor: highlightColor,
                        shimmerValue: shimmerValue,
                      ),
                      const SizedBox(height: 8),
                      _ShimmerBox(
                        width: 200,
                        height: 12,
                        baseColor: baseColor,
                        highlightColor: highlightColor,
                        shimmerValue: shimmerValue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Bottom row
            Row(
              children: [
                _ShimmerBox(
                  width: 60,
                  height: 14,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  shimmerValue: shimmerValue,
                ),
                const SizedBox(width: 16),
                _ShimmerBox(
                  width: 60,
                  height: 14,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  shimmerValue: shimmerValue,
                ),
                const SizedBox(width: 16),
                _ShimmerBox(
                  width: 60,
                  height: 14,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  shimmerValue: shimmerValue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final Color baseColor;
  final Color highlightColor;
  final double shimmerValue;
  final bool isCircle;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.baseColor,
    required this.highlightColor,
    required this.shimmerValue,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: isCircle ? null : BorderRadius.circular(6),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [
            (shimmerValue - 0.3).clamp(0.0, 1.0),
            shimmerValue.clamp(0.0, 1.0),
            (shimmerValue + 0.3).clamp(0.0, 1.0),
          ],
          colors: [
            baseColor,
            highlightColor,
            baseColor,
          ],
        ),
      ),
    );
  }
}
