import 'package:flutter/material.dart';

class TwakeAppBar extends StatelessWidget {
  final Widget leading;
  final Widget actions;
  final Widget title;
  TwakeAppBar({
    this.leading,
    this.actions,
    this.title,
  });
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: title,
      toolbarHeight: 100,
    );
  }
}
