import 'package:flutter/material.dart';

class ParticipantsWidget extends StatelessWidget {
  final String title;
  final Widget trailingWidget;

  const ParticipantsWidget({
    Key key,
    @required this.title,
    @required this.trailingWidget,
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
          SizedBox(width: 15),
          Text(
            title,
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
          Spacer(),
          trailingWidget,
          SizedBox(width: 20),
        ],
      ),
    );
  }
}