import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchItem extends StatelessWidget {
  final String title;
  final Function onTap;
  final bool selected;
  final bool allowMultipleChoice;

  const SearchItem({
    Key key,
    @required this.title,
    @required this.onTap,
    this.selected = false,
    this.allowMultipleChoice = false,
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
                    if (allowMultipleChoice && selected)
                      Icon(
                        CupertinoIcons.check_mark_circled_solid,
                        color: Color(0xff3840F7),
                      ),
                    if (allowMultipleChoice && !selected)
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