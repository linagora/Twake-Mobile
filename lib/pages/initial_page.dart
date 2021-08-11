import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:twake/blocs/authentication_cubit/authentication_cubit.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/pages/sign_flow.dart';
import 'package:twake/pages/syncing_data.dart';

import 'home/home_widget.dart';

class InitialPage extends StatefulWidget {
  @override
  _InitialPageState createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    //print(Globals.instance.host);
    //  final authenticationCubitState = BlocProvider.of<AuthenticationCubit>(context).state;
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, //ensures portrait at all times.
      // you can override this if necessary
    ]);

    return LayoutBuilder(
      builder: (context, constraints) => OrientationBuilder(
        builder: (context, orientation) {
          Dim.init(constraints, orientation);
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: BlocBuilder<AuthenticationCubit, AuthenticationState>(
              bloc: Get.find<AuthenticationCubit>(),
              builder: (ctx, state) {
                if (state is AuthenticationInProgress) {
                  return buildSplashScreen();
                } else if (state is AuthenticationInitial) {
                  return SignFlow();
                } else if (state is PostAuthenticationSyncInProgress) {
                  return SyncingDataScreen(
                    state.progress.toDouble(),
                  );
                } else if (state is PostAuthenticationSyncFailed) {
                  return SyncDataFailed();
                } else if (state is PostAuthenticationSyncSuccess ||
                    state is AuthenticationSuccess) {
                  return HomeWidget();
                } else if (state is AuthenticationFailure) {
                  return SignFlow();
                } else {
                  return buildSplashScreen();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
