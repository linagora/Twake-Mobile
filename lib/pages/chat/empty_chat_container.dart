import 'package:flutter/material.dart';

class EmptyChatContainer extends StatelessWidget {
  final bool isDirect;

  const EmptyChatContainer({
    Key key,
    this.isDirect = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 32.0),
      padding: EdgeInsets.fromLTRB(36.0, 16.0, 36.0, 16.0),
      decoration: BoxDecoration(
        color: Color(0xfff6f6f6),
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 32.0,
            height: 32.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                transform: GradientRotation(2.79253), // 160 degrees
                tileMode: TileMode.repeated,
                colors: [
                  Color(0xff4838b7),
                  Color(0xff3840f7),
                ],
              ),
            ),
            alignment: Alignment.center,
            child: Image.asset('assets/images/twake.png'),
          ),
          SizedBox(height: 12.0),
          Text(
            'There are no messages in\nthis ${isDirect ? 'conversation' : 'channel'}! Start conversation by\nsending some text, image or document',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
