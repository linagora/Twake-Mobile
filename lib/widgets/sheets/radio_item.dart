import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RadioItem extends StatelessWidget {
  final String title;
  final bool selected;
  final Function onTap;

  const RadioItem({
    Key key,
    @required this.title,
    @required this.selected,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    if (selected)
                      Icon(
                        CupertinoIcons.check_mark_circled_solid,
                        color: Color(0xff837cfe),
                      ),
                    if (!selected)
                      Icon(
                        CupertinoIcons.circle,
                        color: Color(0xffaeaeb2),
                      ),
                  ],
                ),
              ),
            ),
            Divider(
              endIndent: 40,
              thickness: 0.5,
              height: 0.5,
              color: Colors.black.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }
}