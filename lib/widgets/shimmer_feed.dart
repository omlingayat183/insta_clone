
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerFeed extends StatelessWidget {
  const ShimmerFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
     
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 3, 
      itemBuilder: (context, index) => const _ShimmerPost(),
    );
  }
}

class _ShimmerPost extends StatelessWidget {
  const _ShimmerPost();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF262626),
      highlightColor: const Color(0xFF3A3A3A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const _ShimmerBox(width: 36, height: 36, isCircle: true),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerBox(width: 120, height: 12, borderRadius: 4),
                    const SizedBox(height: 4),
                    _ShimmerBox(width: 80, height: 10, borderRadius: 4),
                  ],
                ),
                const Spacer(),
                const _ShimmerBox(width: 24, height: 6, isCircle: true),
              ],
            ),
          ),

          const _ShimmerBox(
            width: double.infinity,
            height: 375,
            borderRadius: 0,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _ShimmerBox(width: 24, height: 24, borderRadius: 4),
                const SizedBox(width: 16),
                _ShimmerBox(width: 24, height: 24, borderRadius: 4),
                const SizedBox(width: 16),
                _ShimmerBox(width: 24, height: 24, borderRadius: 4),
                const Spacer(),
                _ShimmerBox(width: 24, height: 24, borderRadius: 4),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _ShimmerBox(width: 100, height: 12, borderRadius: 4),
          ),
          const SizedBox(height: 6),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(width: double.infinity, height: 12, borderRadius: 4),
                const SizedBox(height: 4),
                _ShimmerBox(width: 200, height: 12, borderRadius: 4),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}


class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool isCircle;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius = 0,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isCircle
            ? BorderRadius.circular(height / 2)
            : BorderRadius.circular(borderRadius),
      ),
    );
  }
}
