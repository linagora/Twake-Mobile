import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/authentication_cubit/authentication_cubit.dart';
import 'package:twake/blocs/registration_cubit/registration_cubit.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendLink(String email) async {
    if (_formKey.currentState!.validate()) {
      final stateRegistration = Get.find<RegistrationCubit>().state;
      if (stateRegistration is RegistrationReady) {
        await Get.find<RegistrationCubit>().signup(
            email: email,
            secretToken: stateRegistration.secretToken,
            code: stateRegistration.code);
      }
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
              BlocBuilder<RegistrationCubit, RegistrationState>(
                  bloc: Get.find<RegistrationCubit>(),
                  builder: (ctx, state) {
                    if (state is RegistrationSuccess) {
                      return SizedBox(
                        width: Dim.widthPercent(25),
                        child: Image.asset(
                            'assets/images/3.0x/twake_home_logo.png'),
                      );
                    }
                    return Container();
                  }),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: CupertinoButton(
                    child: Icon(
                      CupertinoIcons.clear,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      {
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
        child: BlocBuilder<RegistrationCubit, RegistrationState>(
          bloc: Get.find<RegistrationCubit>(),
          builder: (ctx, state) {
            if (state is RegistrationReady) {
              return registrationInitial(emailExists: false, init: false);
            } else if (state is RegistrationSuccess) {
              return registrationSuccess();
            } else if (state is RegistrationFailed) {
              if (state.emailExists) {
                return registrationInitial(emailExists: true, init: false);
              } else {
                return registrationFailed();
              }
            } else {
              return registrationInitial(emailExists: false, init: true);
            }
          },
        ),
      ),
    );
  }

  Widget registrationInitial({required bool emailExists, required bool init}) {
    return Column(
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
          child: init
              ? Center(child: CircularProgressIndicator())
              : Form(
                  autovalidateMode: AutovalidateMode.disabled,
                  key: _formKey,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.disabled,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email address';
                      }
                      if (EmailValidator.validate(value)) {
                        return null;
                      } else {
                        if (emailExists) {
                          return 'Entered email is already in use';
                        } else {
                          return 'Please enter the correct email address';
                        }
                      }
                    },
                    controller: _controller,
                    onFieldSubmitted: (_) {
                      _sendLink(_controller.text);
                      //  setState(() {});
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
                                    onPressed: () => _controller.clear(),
                                    iconSize: 15,
                                    icon: Icon(CupertinoIcons.clear),
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    CupertinoIcons.exclamationmark_circle_fill,
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
              await Get.find<AuthenticationCubit>().authenticate();
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
          padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
          child: TextButton(
            onPressed: () {
              _sendLink(_controller.text);
              setState(() {});
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xFF004DFF),
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
    );
  }

  Widget registrationSuccess() {
    return Column(
      children: [
        SizedBox(
          height: Dim.heightPercent(10),
        ),
        SizedBox(
            width: Dim.widthPercent(25),
            child: Image.asset('assets/images/3.0x/send_tile.png')),
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
          padding: const EdgeInsets.only(left: 25, right: 25, bottom: 15),
          child: Text(
            _controller.text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 17.0,
                fontWeight: FontWeight.w600,
                color: Colors.black),
          ),
        ),
        BlocBuilder<RegistrationCubit, RegistrationState>(
          bloc: Get.find<RegistrationCubit>(),
          builder: (ctx, state) {
            if (state is RegistrationSuccess) {
              return Padding(
                padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
                child: TextButton(
                  onPressed: () async {
                    await Get.find<RegistrationCubit>()
                        .resendEmail(email: _controller.text);
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(0xFF004DFF),
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Resend email',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            } else if (state is EmailResendSuccess) {
              return Row(
                children: [
                  Icon(
                    CupertinoIcons.check_mark_circled_solid,
                    color: Color(0xff3840F7),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Email sent',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF02A82E),
                    ),
                  ),
                ],
              );
            } else if (state is EmailResendFailed) {
              return Row(
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_circle_fill,
                    color: Colors.red[400],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Email resend failed',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF02A82E),
                    ),
                  ),
                ],
              );
            } else {
              return Row(
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_circle_fill,
                    color: Colors.red[400],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Email resend failed',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF02A82E),
                    ),
                  ),
                ],
              );
            }
          },
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
    );
  }

  Widget registrationFailed() {
    return Padding(
      padding: EdgeInsets.only(
          left: Dim.widthPercent(10), right: Dim.widthPercent(10)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: Text(
              'Sign up failed',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            'Unfortunately, something went wrong during your sign up',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: Dim.heightPercent(5),
          ),
          Container(
            width: Dim.widthPercent(40),
            child: Image.asset(
              'assets/images/3.0x/emoji_face.png',
            ),
          ),
          SizedBox(
            height: Dim.heightPercent(10),
          ),
          Text(
            'Please, try to sign up once again later or contact our technical support team',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          SizedBox(
            height: Dim.heightPercent(10),
          ),
          TextButton(
            onPressed: () {
              _sendLink(_controller.text);
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xFF004DFF),
                borderRadius: BorderRadius.circular(14.0),
              ),
              alignment: Alignment.center,
              child: Text(
                'Sign up once again',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
