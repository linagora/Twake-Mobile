import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:twake/blocs_new/authentication_cubit/authentication_cubit.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/pages/auth_page.dart';
import 'package:twake/services/init_service.dart';

class InitialPage extends StatefulWidget {
  @override
  _InitialPageState createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    //  final authenticationCubitState = BlocProvider.of<AuthenticationCubit>(context).state;
  }

  Widget buildSplashScreen() {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: Dim.heightPercent(13),
          height: Dim.heightPercent(13),
          child: Lottie.asset(
            'assets/animations/splash.json',
            animate: true,
            repeat: true,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<AuthenticationCubit, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationSuccess) {
            InitService.syncData();
          }
        },
        builder: (ctx, state) {
          if (state is AuthenticationInProgress) {
            return buildSplashScreen();
          }
          if (state is AuthenticationInitial) {
            return AuthPage();
          }
          if (state is AuthenticationSuccess) {
            return Text("Authenticated",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40));
          }
          if (state is AuthenticationFailure) {
            return AuthPage();
          } else {
            return buildSplashScreen();
          }
        },
      ),
    );
  }
}
