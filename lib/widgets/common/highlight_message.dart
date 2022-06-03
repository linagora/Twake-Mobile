
import 'package:flutter/material.dart';

class HighlightComponent extends StatefulWidget {
  final Widget component;

  HighlightComponent({required this.component});

  @override
  State<HighlightComponent> createState() => _HighlightComponentState();
  
}

class _HighlightComponentState extends State<HighlightComponent> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(seconds: 1),
      color: Theme.of(context).highlightColor,
      child: widget.component,
    );
  }

}