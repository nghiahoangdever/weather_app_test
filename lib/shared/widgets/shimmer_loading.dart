import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/responsive_helper.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class WeatherShimmerHero extends StatelessWidget {
  const WeatherShimmerHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        const ShimmerLoading(width: 150, height: 24),
        const SizedBox(height: 20),
        const ShimmerLoading(width: 120, height: 72),
        const SizedBox(height: 12),
        const ShimmerLoading(width: 180, height: 20),
        const SizedBox(height: 8),
        const ShimmerLoading(width: 100, height: 16),
        const SizedBox(height: 40),
      ],
    );
  }
}

class WeatherShimmerCards extends StatelessWidget {
  const WeatherShimmerCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hourly forecast shimmer
        const ShimmerLoading(height: 120),
        const SizedBox(height: 16),
        // Daily forecast shimmer
        ...List.generate(
          5,
          (i) => const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: ShimmerLoading(height: 56),
          ),
        ),
        const SizedBox(height: 16),
        // Stats grid shimmer
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: ResponsiveHelper.statsGridColumns(context),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: ResponsiveHelper.statsChildAspectRatio(context),
          ),
          itemCount: 6,
          itemBuilder: (context, index) => const ShimmerLoading(height: double.infinity),
        ),
      ],
    );
  }
}
