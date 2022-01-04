import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/authentication_cubit/authentication_cubit.dart';
import 'package:twake/blocs/registration_cubit/registration_cubit.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/pages/server_configuration.dart';
import 'package:twake/pages/sign_up.dart';

class SignFlow extends StatefulWidget {
  final String? requestedMagicLinkToken;

  const SignFlow({Key? key, this.requestedMagicLinkToken}) : super(key: key);

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
        onSignUp: () => setState(() {
          _index = 2;
        }),
        onChangeServer: () => setState(() {
          _index = 1;
        }),
        requestedMagicLinkToken: widget.requestedMagicLinkToken,
      ),
      ServerConfiguration(
        onCancel: () => setState(() {
          _index = 0;
        }),
        onConfirm: () => setState(() {
          _index = 0;
        }),
      ),
      SignUp(
        onCancel: () => setState(() {
          _index = 0;
        }),
        requestedMagicLinkToken: widget.requestedMagicLinkToken,
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
  final Function onSignUp;
  final String? requestedMagicLinkToken;

  const SignInSignUpForm(
      {Key? key,
      required this.onChangeServer,
      required this.onSignUp,
      this.requestedMagicLinkToken})
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
                  height: Dim.heightPercent(2),
                ),
                Container(
                  width: 88,
                  height: 22,
                  child: Image.asset(
                    'assets/images/3.0x/twake_home_logo.png',
                    fit: BoxFit.contain,
                    color: Theme.of(context)
                        .colorScheme
                        .primaryVariant
                        .withOpacity(0.9),
                  ),
                ),
                Spacer(),
                SizedBox(
                  height: 40,
                ),
                Container(
                  width: Dim.widthPercent(90),
                  height: 60,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.secondaryVariant,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    onPressed: () async {
                      await Get.find<AuthenticationCubit>().authenticate(
                          requestedMagicLinkToken: requestedMagicLinkToken);
                    },
                    child: Text(
                      AppLocalizations.of(context)!.signin,
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  width: Dim.widthPercent(90),
                  height: 60,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    onPressed: () {
                      Get.find<RegistrationCubit>().prepare();
                      onSignUp();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.signup,
                      style: MediaQuery.of(context).platformBrightness ==
                              Brightness.dark
                          ? Theme.of(context).textTheme.headline1!.copyWith(
                              fontSize: 17, fontWeight: FontWeight.w600)
                          : Theme.of(context).textTheme.bodyText1!.copyWith(
                              fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Spacer(),
                Text(
                  AppLocalizations.of(context)!.serverConnectionPreference,
                  style: Theme.of(context)
                      .textTheme
                      .headline2!
                      .copyWith(fontSize: 17, fontWeight: FontWeight.w900),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  width: Dim.widthPercent(90),
                  height: 60,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.secondaryVariant,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    onPressed: () {
                      onChangeServer();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.changeServer,
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Center(
                  child: Container(
                    width: Dim.widthPercent(85),
                    child: Text(
                      AppLocalizations.of(context)!.changeServerInfo,
                      style: Theme.of(context).textTheme.headline1!.copyWith(
                          fontSize: 13, fontWeight: FontWeight.normal),
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
