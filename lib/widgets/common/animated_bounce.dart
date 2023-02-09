import 'dart:async';

import 'package:flutter/material.dart';

class Bounce extends StatefulWidget {
  final VoidCallback onLongPress;
  final Widget child;
  final Duration duration;

  Bounce({
    required this.child,
    required this.duration,
    required this.onLongPress,
  });

  @override
  BounceState createState() => BounceState();
}

class BounceState extends State<Bounce> with SingleTickerProviderStateMixin {
  late double _scale;
  Timer? _timer;

  late AnimationController _animate;

  VoidCallback get onLongPress => widget.onLongPress;

  Duration get userDuration => widget.duration;

  @override
  void initState() {
    _animate = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _animate.value;
    return GestureDetector(
        onPanCancel: () => _timer?.cancel(),
        onPanDown: (_) {
          _timer = Timer(
            Duration(milliseconds: 400),
            () {
              _onLongPress();
            },
          );
        },
        child: Transform.scale(
          scale: _scale,
          child: widget.child,
        ));
  }

  void _onLongPress() {
    _animate.forward();

    Future.delayed(userDuration, () {
      _animate.reverse().then((_) {
        onLongPress();
      });
    });
  }
}
