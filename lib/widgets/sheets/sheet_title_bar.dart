import 'package:flutter/material.dart';

class SheetTitleBar extends StatelessWidget {
  const SheetTitleBar({
    Key key,
    @required this.title,
    this.leadingTitle,
    this.trailingTitle,
    this.leadingAction,
    this.trailingAction,
  }) : super(key: key);

  final String title;
  final String leadingTitle;
  final String trailingTitle;
  final Function leadingAction;
  final Function trailingAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xfff7f7f7),
      height: 52,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {},
            child: Text(
              leadingTitle ?? '',
              style: TextStyle(
                color: leadingAction != null ? Color(0xff837cfe) : Color(0xffa2a2a2),
                fontSize: 17.0,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 17.0,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              trailingTitle ?? '',
              style: TextStyle(
                color: trailingAction != null ? Color(0xff837cfe) : Color(0xffa2a2a2),
                fontSize: 17.0,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}