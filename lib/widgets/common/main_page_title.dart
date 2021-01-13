import 'package:flutter/material.dart';
import 'package:twake/config/dimensions_config.dart';

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
          icon: Icon(
            Icons.add,
            size: Dim.tm3(decimal: .3),
            color: Colors.black,
          ),
          onPressed: () => trailingAction?.call(),
        ),
      ],
    );
  }
}
