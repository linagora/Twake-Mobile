import 'package:flutter/material.dart';
import 'package:twake/widgets/common/shimmer_loading.dart';

class RoundedShimmer extends StatelessWidget {
  final double size;

  RoundedShimmer({this.size = 30});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: ShimmerLoading(
        isLoading: true,
        width: size,
        height: size,
        child: Container(),
      ),
    );
  }
}
