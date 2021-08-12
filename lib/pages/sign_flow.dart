import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/authentication_cubit/authentication_cubit.dart';
import 'package:twake/pages/server_configuration.dart';

class SignFlow extends StatefulWidget {
  @override
  _SignFlowState createState() => _SignFlowState();
}

class _SignFlowState extends State<SignFlow> {
  int _index = 0;
  List<Widget> _widgets = [];

  @override
  void initState() {
    super.initState();

    _widgets = [
      SignInSignUpForm(
        onChangeServer: () => setState(() {
          _index = 1;
        }),
      ),
      ServerConfiguration(
        onCancel: () => setState(() {
          _index = 0;
        }),
        onConfirm: () => setState(() {
          _index = 0;
        }),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            alignment: Alignment.bottomCenter,
            sizing: StackFit.expand,
            index: _index,
            children: _widgets,
          ),
        ],
      ),
    );
  }
}

class SignInSignUpForm extends StatelessWidget {
  final Function onChangeServer;
  const SignInSignUpForm({Key? key, required this.onChangeServer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.015,
                ),
                Container(
                  width: 88,
                  height: 22,
                  color: Colors.white,
                  child: Image.asset(
                    'assets/images/3.0x/twake_home_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                Spacer(),
                SizedBox(
                  height: 40,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 60,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xFFF2F3F5),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    onPressed: () async {
                      await Get.find<AuthenticationCubit>().authenticate();
                    },
                    child: Text(
                      'Sign in',
                      style: TextStyle(
                          fontSize: 17,
                          color: Color(0xFF004DFF),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 60,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xFF004DFF),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    onPressed: () {},
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Spacer(),
                Text(
                  'Server connection preference',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 60,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xFFF2F3F5),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    onPressed: () {
                      onChangeServer();
                    },
                    child: Text(
                      'Change server',
                      style: TextStyle(
                          fontSize: 17,
                          color: Color(0xFF004DFF),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: Text(
                      'You can connect with different server or instead proceed with default Linagora server.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}