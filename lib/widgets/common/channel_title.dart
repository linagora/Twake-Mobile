import 'package:meta/meta.dart';
import 'package:flutter/material.dart';

class ChannelTitle extends StatelessWidget {
  final String name;
  final bool isPrivate;
  final bool hasUnread;

  const ChannelTitle({
    Key key,
    @required this.name,
    @required this.isPrivate,
    this.hasUnread = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        children: [
          TextSpan(text: name),
          WidgetSpan(child: SizedBox(width: 6)),
          if (isPrivate)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(
                Icons.lock_outline,
                size: 16.0,
                color: Color(0xff444444),
              ),
            ),
        ],
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
