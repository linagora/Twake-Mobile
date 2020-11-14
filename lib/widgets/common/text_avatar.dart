import 'package:flutter/material.dart';
import 'package:twake_mobile/config/dimensions_config.dart' show Dim;

class TextAvatar extends StatelessWidget {
  final String text;
  TextAvatar(this.text);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        Dim.widthMultiplier * 0.5,
      ),
      child: Container(
        color: Colors.grey[200],
        width: Dim.wm9,
        height: Dim.wm9,
        child: Align(
          alignment: Alignment.center,
          child: Text(
            text,
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
      ),
    );
  }
}
