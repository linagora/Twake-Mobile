import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/routing/app_router.dart';

class SignUp extends StatefulWidget {
  final Function? onCancel;
  final Function? onConfirm;

  const SignUp({
    Key? key,
    this.onCancel,
    this.onConfirm,
  }) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void initState() {
    //_controller.text = Globals.instance.host;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _connect() async {
    FocusScope.of(context).requestFocus(FocusNode());
    var host = _controller.text;
    bool valid = await Globals.instance.hostSet(host);
    if (valid) {
      widget.onConfirm!();
      //   print(Globals.instance.host);
    } else {
      //   print(Globals.instance.host);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          margin: EdgeInsets.fromLTRB(
            15.0,
            5.0,
            15.0,
            65.0,
            //  Dim.heightPercent(8),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
          content: Text(
            'Invalid host',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: CupertinoButton(
              child: Icon(
                CupertinoIcons.clear,
                color: Colors.grey[600],
              ),
              onPressed: () {}),
        )
      ]),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          behavior: HitTestBehavior.opaque,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 25),
                child: Text(
                  'Sign up',
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 25, right: 25, top: 10),
                child: Text(
                  'By continuing, you’re agreeing to our Terms of Services and Privacy Policy',
                  style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF969698)),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 15),
                child: TextFormField(
                  key: _formKey,
                  validator: (value) =>
                      value!.isEmpty ? 'Address cannot be blank' : null,
                  controller: _controller,
                  onFieldSubmitted: (_) => _connect(),
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: " Email",
                    hintStyle: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffc8c8c8),
                    ),
                    alignLabelWithHint: true,
                    fillColor: Color(0xfff4f4f4),
                    filled: true,
                    suffix: Container(
                      width: 30,
                      height: 25,
                      padding: EdgeInsets.only(left: 10),
                      child: IconButton(
                        padding: EdgeInsets.all(0),
                        onPressed: () => _controller.clear(),
                        iconSize: 15,
                        icon: Icon(CupertinoIcons.clear),
                      ),
                    ),
                    border: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        width: 0.0,
                        style: BorderStyle.none,
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: SizedBox(
                  height: Dim.heightPercent(50),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Already have an account?',
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF969698)),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () => _connect(),
                  child: Text(
                    'Sign in',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff3840f7),
                    ),
                  ),
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
                child: TextButton(
                  onPressed: () => _connect(),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(0xff3840f7),
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Start using Twake',
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
      ),
    );
  }
}
