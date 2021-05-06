import 'package:flutter/material.dart';

class EmptyChatContainer extends StatelessWidget {
  final bool isDirect;
  final bool isError;
  final String userName;

  const EmptyChatContainer({
    Key key,
    this.isDirect = false,
    this.isError = false,
    this.userName = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 36.0, top: 16.0, right: 36.0),
            padding: const EdgeInsets.only(top: 16.0, bottom: 12.0),
            decoration: BoxDecoration(
              color: Color(0xfff6f6f6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0),
              ),
            ),
            child: Container(
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
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 36.0),
            padding: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              color: Color(0xfff6f6f6),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(18.0),
                bottomRight: Radius.circular(18.0),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              isError
                  ? 'Couldn\'t load messages'
                  : 'There are no messages in\nthis ${isDirect ? 'chat' : 'channel'}! Start conversation\nwith $userName by sending\nsome text, image or document',
              maxLines: 4,
              textAlign: TextAlign.center,
              softWrap: false,
              style: TextStyle(
                color: Colors.black,
                fontSize: 15.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
