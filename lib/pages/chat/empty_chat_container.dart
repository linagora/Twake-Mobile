import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class EmptyChatContainer extends StatelessWidget {
  final bool isDirect;
  final bool isError;
  final String? userName;

  const EmptyChatContainer({
    Key? key,
    this.isDirect = false,
    this.isError = false,
    this.userName = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final message = isDirect
        ? 'There are no messages in\nthis chat! Start conversation\nwith $userName by sending\nsome text, image or document'
        : 'There are no messages in\nthis channel! Start conversation by\nsending some text, image or document';
    return Expanded(
      child: Column(
        children: [
          SizedBox(height: 16.0),
          Container(
            width: MediaQuery.of(context).size.width - 72.0,
            padding: const EdgeInsets.only(top: 16.0),
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
                  tileMode: TileMode.mirror,
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
            padding: const EdgeInsets.only(top: 12.0, bottom: 16.0),
            width: MediaQuery.of(context).size.width - 72.0,
            decoration: BoxDecoration(
              color: Color(0xfff6f6f6),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(18.0),
                bottomRight: Radius.circular(18.0),
              ),
            ),
            child: AutoSizeText(
              isError ? 'Couldn\'t load messages' : message,
              minFontSize: 10.0,
              maxFontSize: 15.0,
              maxLines: 4,
              textAlign: TextAlign.center,
              softWrap: false,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}

class MessagesLoadingAnimation extends StatelessWidget {
  const MessagesLoadingAnimation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 50,),
            SizedBox(
              height: 160,
              width: 160,
              child: Image.asset(
                'assets/animations/messages_loading.gif',
              ),
            ),
            Text(
              'We are loading chat,',
              style: TextStyle(
                  fontSize: 20, color: Colors.black, fontWeight: FontWeight.w900),
            ),
            Text(
              'please, be patient 😊😕',
              style: TextStyle(
                  fontSize: 20, color: Colors.black, fontWeight: FontWeight.w900),
            )
          ],
        ),
      ),
    );
  }
}
