import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:twake/blocs/authentication_cubit/authentication_cubit.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/deeplink/join/workspace_join_response.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/pages/magic_link/join_workspace_magic_link_page.dart';
import 'package:twake/pages/sign_flow.dart';
import 'package:twake/pages/syncing_data.dart';
import 'package:uni_links/uni_links.dart';

import 'home/home_widget.dart';

class InitialPage extends StatefulWidget {
  @override
  _InitialPageState createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> with WidgetsBindingObserver {
  StreamSubscription? _magicLinkStreamSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    connectionStatusSnackBar();
    _handleMagicLinkEvent();
  }

  void _handleMagicLinkEvent() {
    try {
      _handleIncomingLinkStream();
      _handleIncomingLinkInitial();
    } catch (e) {
      Logger().e('ERROR during receiving magic link:\n$e');
      // Make sure old authentication flow is work as expected when magic link is failed
      Get.find<AuthenticationCubit>().checkAuthentication();
    }
  }

  void _handleIncomingLinkStream() {
    // Handle app links while the app is already started -
    // be it in the foreground or in the background.
    _magicLinkStreamSub = uriLinkStream.listen((Uri? uri) {
      if (!mounted) {
        return;
      }
      _handleIncomingLink(uri);
    }, onError: (Object e) {
      throw Exception('ERROR during receiving magic link:\n$e');
    });
  }

  Future<void> _handleIncomingLinkInitial() async {
    // Handle app links while the app was started

    // Prevent checking incoming url when logout
    final currentAuthState = Get.find<AuthenticationCubit>().state;
    if (currentAuthState is LogoutInProgress) return;

    try {
      final uri = await getInitialUri();
      if (!mounted) {
        return;
      }
      _handleIncomingLink(uri);
    } on PlatformException {
      throw Exception('ERROR during receiving magic link');
    } on FormatException catch (e) {
      throw Exception('ERROR during receiving magic link:\n$e');
    }
  }

  _handleIncomingLink(Uri? uri) {
    final token = uri?.queryParameters['join'];
    if (token != null && token.isNotEmpty) {
      Get.find<AuthenticationCubit>().checkTokenAvailable(token);
    } else {
      Get.find<AuthenticationCubit>().checkAuthentication();
    }
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
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  Text(AppLocalizations.of(context)!.internetConnection,
                      style: Theme.of(context)
                          .textTheme
                          .headline1!
                          .copyWith(fontSize: 16)),
                ],
              ),
            ),
          );
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
    _magicLinkStreamSub?.cancel();
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
            body: BlocConsumer<AuthenticationCubit, AuthenticationState>(
              bloc: Get.find<AuthenticationCubit>(),
              builder: (ctx, state) {
                if (state is AuthenticationInProgress) {
                  return buildSplashScreen();
                } else if (state is AuthenticationInitial ||
                    state is AuthenticationFailure ||
                    state is InvitationJoinFailed ||
                    state is AuthenticationInvitationPending) {
                  if (state is AuthenticationInvitationPending) {
                    return SignFlow(
                        requestedMagicLinkToken: state.requestedToken);
                  }
                  return SignFlow();
                } else if (state is PostAuthenticationSyncInProgress) {
                  return SyncingDataScreen(state.progress.toDouble());
                } else if (state is PostAuthenticationSyncFailed) {
                  return SyncDataFailed();
                } else if (state is PostAuthenticationSyncSuccess ||
                    state is AuthenticationSuccess) {
                  var magicLinkJoinResponse;
                  if (state is PostAuthenticationSyncSuccess) {
                    magicLinkJoinResponse = state.magicLinkJoinResponse;
                  } else if (state is AuthenticationSuccess) {
                    magicLinkJoinResponse = state.magicLinkJoinResponse;
                  }
                  if (magicLinkJoinResponse == null) {
                    return HomeWidget();
                  }
                  _selectWorkspaceAfterJoin(magicLinkJoinResponse);
                  return HomeWidget();
                } else if (state is InvitationJoinCheckingTokenFinished) {
                  return JoinWorkSpaceMagicLinkPage(
                      workspaceJoinResponse: state.joinResponse,
                      requestedToken: state.requestedToken);
                } else {
                  return buildSplashScreen();
                }
              },
              listener: (context, state) {
                if (state is InvitationJoinSuccess &&
                    state.needCheckAuthentication) {
                  Get.find<AuthenticationCubit>().checkAuthentication(
                      workspaceJoinResponse: state.joinResponse,
                      pendingRequestedToken: state.requestedToken);
                }
              },
            ),
          );
        },
      ),
    );
  }

  void _selectWorkspaceAfterJoin(WorkspaceJoinResponse? workspaceJoinResponse) {
    if (workspaceJoinResponse?.company.id != null) {
      Globals.instance.companyId = workspaceJoinResponse!.company.id;
    }
    if (workspaceJoinResponse?.workspace.id != null) {
      Globals.instance.workspaceId = workspaceJoinResponse?.workspace.id;
    }
  }
}
