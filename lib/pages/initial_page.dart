import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/authentication_cubit/authentication_cubit.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/globals/globals.dart';
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
    connectionStatusSnackBar();
  }

  void connectionStatusSnackBar() async {
    Globals.instance.connection.listen(
      (connection) {
        if (connection == Connection.disconnected) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              margin: EdgeInsets.fromLTRB(
                15.0,
                5.0,
                15.0,
                65.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.white,
              elevation: 6,
              duration: Duration(days: 365),
              content: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 14, right: 14),
                    child: Icon(
                      CupertinoIcons.exclamationmark_circle,
                      color: Colors.red[400],
                      size: 28,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.internetConnection,
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        } else if (connection == Connection.connected) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
        } else {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
        }
      },
    );
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
      body: Container(
        color: Color(0xFF004DFF),
        child: Center(
          child: Column(
            children: [
              Spacer(),
              SizedBox(
                height: Dim.heightPercent(5),
              ),
              SizedBox(
                width: Dim.widthPercent(45),
                child: Image.asset(
                  'assets/images/3.0x/Twake_launch_logo.png',
                ),
              ),
              Spacer(),
              SizedBox(
                width: Dim.widthPercent(30),
                child: Image.asset(
                  'assets/images/3.0x/Twake_launch_Linagora.png',
                ),
              ),
              SizedBox(
                height: Dim.heightPercent(5),
              ),
            ],
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
