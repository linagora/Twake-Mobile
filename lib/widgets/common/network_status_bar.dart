import 'package:flutter/material.dart';

class NetworkStatusBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 33.0,
      padding: EdgeInsets.symmetric(vertical: 10.0),
      color: Color(0xffffcb63),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              'waiting for internet',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(width: 4),
          Flexible(child: Image.asset("assets/images/clock.png")),
        ],
      ),
    );
  }
}
