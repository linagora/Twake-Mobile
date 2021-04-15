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
      decoration: BoxDecoration(
        color: Color(0xfff6f6f6),
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32.0,
            height: 32.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xff4838b7),
                  Color(0xff3840f7),
                ],
              ),
            ),
            alignment: Alignment.center,
            child: Image.asset('assets/images/twake.png'),
          ),
          Text(
            'There are no messages in\nthis channel! Start conversation by\nsending some text, image or document',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          )
        ],
      ),
    );
  }
}
