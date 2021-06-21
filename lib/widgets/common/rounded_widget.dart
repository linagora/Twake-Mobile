import 'package:flutter/material.dart';

class RoundedWidget extends StatelessWidget {
  final Widget child;
  final bool useSafeArea;
  final double borderRadius;
  final bool roundedTopOnly;

  const RoundedWidget(
      {required this.child,
      this.useSafeArea = false,
      this.borderRadius = 10,
      this.roundedTopOnly = false})
      : super();

  @override
  Widget build(BuildContext context) {
    if (useSafeArea) {
      return SafeArea(
          child: ClipRRect(
        borderRadius: _getBorderRadius(),
        child: child,
      ));
    }
    return ClipRRect(
      borderRadius: _getBorderRadius(),
      child: child,
    );
  }

  BorderRadius _getBorderRadius() => roundedTopOnly
      ? BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius))
      : BorderRadius.circular(borderRadius);
}
