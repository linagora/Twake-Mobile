import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ButtonField extends StatelessWidget {
  final String title;
  final String trailingTitle;
  final bool hasArrow;
  final Widget trailingWidget;

  const ButtonField({
    Key key,
    @required this.title,
    this.trailingTitle,
    this.hasArrow = false,
    this.trailingWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
          Spacer(),
          if (trailingWidget == null)
            hasArrow
                ? Row(
                    children: [
                      Text(
                        trailingTitle,
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff3840F7),
                        ),
                      ),
                      Icon(
                        CupertinoIcons.forward,
                        color: Color(0xff3840F7),
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.only(right: 9.0),
                    child: Text(
                      trailingTitle,
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff3840F7),
                      ),
                    ),
                  ),
          if (trailingWidget != null)
            trailingWidget,
          SizedBox(width: 14),
        ],
      ),
    );
  }
}
