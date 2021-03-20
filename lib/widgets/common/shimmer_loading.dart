import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

const _shimmerGradient = LinearGradient(
  colors: [
    // Colors.red,
    // Colors.redAccent,
    // Colors.green,
    Color(0xFFEBEBF4),
    Color(0xFFF4F4F4),
    Color(0xFFEBEBF4),
  ],
  stops: [
    0.1,
    0.3,
    0.4,
  ],
  begin: Alignment(-1.0, -0.3),
  end: Alignment(1.0, 0.3),
  tileMode: TileMode.clamp,
);

class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    Key key,
    @required this.isLoading,
    @required this.child,
    @required this.width,
    @required this.height,
  }) : super(key: key);

  final bool isLoading;
  final Widget child;
  final double width;
  final double height;

  @override
  _ShimmerLoadingState createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return _shimmerGradient.createShader(bounds);
      },
      child: Container(
        color: Colors.white,
        width: widget.width,
        height: widget.height,
      ),
    );
  }
}
