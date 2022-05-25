import 'package:flutter/material.dart';

class HighlightComponent extends StatefulWidget {
  final Widget component;
  final Color highlightColor;
  final bool highlightWhen;

  HighlightComponent(
      {required this.component,
      required this.highlightColor,
      this.highlightWhen = true});

  @override
  State<HighlightComponent> createState() => _HighlightComponentState();
}

class _HighlightComponentState extends State<HighlightComponent>
    with SingleTickerProviderStateMixin {
  late Animation animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    animation = TweenSequence<Color?>(<TweenSequenceItem<Color?>>[
      TweenSequenceItem(
          tween:
              ColorTween(begin: Colors.transparent, end: widget.highlightColor),
          weight: 50),
      TweenSequenceItem(
          tween:
              ColorTween(begin: widget.highlightColor, end: Colors.transparent),
          weight: 50),
    ]).animate(controller)
      ..addListener(() {
        setState(() {});
      });

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void triggerAnimation() {
    controller.reset();
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return widget.highlightWhen
        ? ColoredBox(color: animation.value, child: widget.component)
        : widget.component;
  }
}
