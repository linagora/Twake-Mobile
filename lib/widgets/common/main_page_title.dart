import 'package:flutter/material.dart';

class MainPageTitle extends StatelessWidget {
  final String title;
  final Function trailingAction;

  const MainPageTitle({
    Key key,
    this.title,
    this.trailingAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headline3,
        ),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: trailingAction?.call(),
        ),
      ],
    );
  }
}