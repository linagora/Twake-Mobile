import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ServerConfiguration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10.0),
            Image.asset('assets/images/server.png'),
            SizedBox(height: 12.0),
            Text(
              'Server connection preference',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 36.0),
            Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(
                'Before you can proceed, please, choose a default server connection',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.normal,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 0),
              child: CupertinoTextField(
                placeholder: "Enter server address",
              ),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                'Tap “Connect” if you don’t know exactly what is this all about',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 22.0),
              child: TextButton(
                onPressed: () => print('Connect'),
                child: Container(
                  width: Size.infinite.width,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xff3840f7),
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Connect',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
