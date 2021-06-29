import 'package:flutter/material.dart';

class TwakeButton extends StatelessWidget {
  final void Function()? onTap;
  final Widget child;

  const TwakeButton({Key? key, required this.onTap, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: child,
      ),
    );
  }
}
