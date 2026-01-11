import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const LoadingShimmerWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}
