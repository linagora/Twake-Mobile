import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/authentication_cubit/authentication_cubit.dart';
import 'package:twake/config/dimensions_config.dart';

class SignUp extends StatefulWidget {
  final Function? onCancel;

  const SignUp({
    Key? key,
    this.onCancel,
  }) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool isSent = false;

  @override
  void initState() {
    isSent = false;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendLink() async {
    //add send action if validate
    if (_formKey.currentState!.validate()) {
      setState(() {
        isSent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: SafeArea(
          child: Row(
            children: <Widget>[
              Container(
                width: 70,
              ),
              Spacer(),
              isSent
                  ? SizedBox(
                      width: Dim.widthPercent(25),
                      child:
                          Image.asset('assets/images/3.0x/twake_home_logo.png'),
                    )
                  : Container(),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: CupertinoButton(
                    child: Icon(
                      CupertinoIcons.clear,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      if (isSent == true) {
                        setState(() {
                          isSent = false;
                        });
                      } else {
                        widget.onCancel!();
                        _controller.clear();
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            isSent
                ? Column(
                    children: [
                      SizedBox(
                        height: Dim.heightPercent(10),
                      ),
                      SizedBox(
                          width: Dim.widthPercent(25),
                          child:
                              Image.asset('assets/images/3.0x/send_tile.png')),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 25,
                            left: Dim.widthPercent(10),
                            right: Dim.widthPercent(10),
                            bottom: 15),
                        child: Text(
                          'Done, we’ve sent a verfication link and generated password to:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF969698)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 25, right: 25, bottom: 15),
                        child: Text(
                          _controller.text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await Get.find<AuthenticationCubit>().authenticate();
                        },
                        child: Text(
                          'Sign in',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff3840f7),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
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
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                            validator: (value) {
                              if (value == null) {
                                return null;
                              }
                              if (EmailValidator.validate(value)) {
                                return null;
                              } else {
                                return 'Please enter the correct email address';
                              }
                            },
                            controller: _controller,
                            onFieldSubmitted: (_) {
                              _sendLink();
                              setState(() {});
                            },
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
                              suffix: _formKey.currentState == null
                                  ? Container(
                                      width: 30,
                                      height: 25,
                                      padding: EdgeInsets.only(left: 10),
                                      child: IconButton(
                                        padding: EdgeInsets.all(0),
                                        onPressed: () => _controller.clear(),
                                        iconSize: 15,
                                        icon: Icon(CupertinoIcons.clear),
                                      ),
                                    )
                                  : _formKey.currentState!.validate()
                                      ? Container(
                                          width: 30,
                                          height: 25,
                                          padding: EdgeInsets.only(left: 10),
                                          child: IconButton(
                                            padding: EdgeInsets.all(0),
                                            onPressed: () =>
                                                _controller.clear(),
                                            iconSize: 15,
                                            icon: Icon(CupertinoIcons.clear),
                                          ),
                                        )
                                      : CircleAvatar(
                                          radius: 10,
                                          backgroundColor: Colors.white,
                                          child: Icon(
                                            CupertinoIcons
                                                .exclamationmark_circle_fill,
                                            color: Colors.red[400],
                                            size: 20,
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
                      ),
                      Flexible(
                        child: SizedBox(
                          height: Dim.heightPercent(40),
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
                          onPressed: () async {
                            await Get.find<AuthenticationCubit>()
                                .authenticate();
                          },
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
                        padding: const EdgeInsets.only(
                            left: 25, right: 25, bottom: 25),
                        child: TextButton(
                          onPressed: () {
                            _sendLink();
                            setState(() {});
                          },
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
          ],
        ),
      ),
    );
  }
}
