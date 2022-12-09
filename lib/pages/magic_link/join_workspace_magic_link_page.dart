import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:sprintf/sprintf.dart';
import 'package:twake/blocs/authentication_cubit/authentication_cubit.dart';
import 'package:twake/blocs/magic_link_cubit/joining_cubit/joining_cubit.dart';
import 'package:twake/blocs/magic_link_cubit/joining_cubit/joining_state.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/config/styles_config.dart';
import 'package:twake/models/deeplink/join/workspace_join_response.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/endpoints.dart';
import 'package:twake/utils/utilities.dart';
import 'package:twake/widgets/common/button_text_builder.dart';
import 'package:twake/widgets/common/confirm_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class JoinWorkSpaceMagicLinkPage extends StatefulWidget {
  final String requestedToken;
  final String incomingHost;

  const JoinWorkSpaceMagicLinkPage({
    Key? key,
    required this.requestedToken,
    required this.incomingHost,
  }) : super(key: key);

  @override
  _JoinWorkSpaceMagicLinkPageState createState() =>
      _JoinWorkSpaceMagicLinkPageState();
}

class _JoinWorkSpaceMagicLinkPageState
    extends State<JoinWorkSpaceMagicLinkPage> {
  final joiningCubit = Get.find<JoiningCubit>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await joiningCubit.checkServerDifference(
          widget.requestedToken, widget.incomingHost);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  SizedBox(height: 8),
                  Image.asset(imageTwakeHomeLogo),
                  SizedBox(height: 20),
                  Text(AppLocalizations.of(context)?.joinWorkspaceIntro ?? '',
                      style:
                          StylesConfig.commonTextStyle.copyWith(fontSize: 15)),
                ],
              ),
              BlocConsumer<JoiningCubit, JoiningState>(
                bloc: joiningCubit,
                builder: (context, state) {
                  if (state is JoiningCheckTokenFinished) {
                    return state.joinResponse == null
                        ? _buildUnAvailableLayout(state.joinResponse)
                        : _buildAvailableLayout(state.joinResponse);
                  }
                  return _loadingLayout();
                },
                listener: (context, state) async {
                  if (state is JoiningWithDifferenceHost) {
                    SchedulerBinding.instance
                        .addPostFrameCallback((timeStamp) async {
                      await _showConfirmLogoutDialog(
                          currentServerUrl: Globals.instance.host);
                    });
                  }
                  if (state is JoiningStateForceLogout) {
                    Utilities.showSimpleSnackBar(
                      context: context,
                      message: AppLocalizations.of(context)
                              ?.youHaveBeenDisconnected(widget.incomingHost) ??
                          '',
                      iconPath: imageInvalid,
                      duration: const Duration(milliseconds: 3000),
                    );
                  }
                },
                listenWhen: (previous, current) {
                  // To make sure it will not show too many dialogs
                  if (previous is JoiningWithDifferenceHost) {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  }
                  return true;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableLayout(WorkspaceJoinResponse? workspaceJoinResponse) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imageSmileFace, width: 88, height: 88),
          SizedBox(height: 20),
          RichText(
              text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                  text: AppLocalizations.of(context)?.joinWorkspaceTitle ?? '',
                  style: StylesConfig.commonTextStyle
                      .copyWith(fontWeight: FontWeight.w600, fontSize: 20)),
              TextSpan(
                  text: workspaceJoinResponse?.workspace.name ?? '',
                  style: StylesConfig.commonTextStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Color(0xff004dff))),
            ],
          )),
          SizedBox(height: 36),
          Text(
              AppLocalizations.of(context)?.joinWorkspaceSubTitle(
                      workspaceJoinResponse?.workspace.name ?? '') ??
                  '',
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center),
          SizedBox(height: 12),
          ButtonTextBuilder(
            Key('button_join_workspace'),
            onButtonClick: () => _handleClickOnJoinButton(),
            backgroundColor:
                Theme.of(context).colorScheme.surface.withOpacity(0.5),
          )
              .setHeight(50)
              .setText(AppLocalizations.of(context)?.joinWorkspaceButton ?? '')
              .build()
        ],
      );

  Widget _buildUnAvailableLayout(
          WorkspaceJoinResponse? workspaceJoinResponse) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imageShrugging, width: 98, height: 88),
          SizedBox(height: 20),
          Text(
              AppLocalizations.of(context)?.joinWorkspaceUnAvailableTitle ?? '',
              style: StylesConfig.commonTextStyle
                  .copyWith(fontWeight: FontWeight.w600, fontSize: 20)),
          SizedBox(height: 36),
          Text(
              AppLocalizations.of(context)?.joinWorkspaceUnAvailableSubTitle ??
                  '',
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center),
          SizedBox(height: 12),
          ButtonTextBuilder(
            Key('button_create_company'),
            onButtonClick: () => _handleClickOnCreateCompanyButton(),
            backgroundColor:
                Theme.of(context).colorScheme.surface.withOpacity(0.5),
          )
              .setHeight(50)
              .setText(AppLocalizations.of(context)
                      ?.joinWorkspaceCreateCompanyButton ??
                  '')
              .build(),
          SizedBox(height: 14),
          Text(AppLocalizations.of(context)?.joinWorkspaceUnAvailableNote ?? '',
              style: TextStyle(fontSize: 13), textAlign: TextAlign.center),
        ],
      );

  void _handleClickOnJoinButton() async {
    await joiningCubit.joinWorkspace(widget.requestedToken,
        needCheckAuthentication: true);
  }

  void _handleClickOnCreateCompanyButton() async {
    try {
      final isAuthenticated =
          await Get.find<AuthenticationCubit>().isAuthenticated();
      if (isAuthenticated) {
        // Open console page in browser
        final consolePage = sprintf(Endpoint.consolePage,
            [Globals.instance.host.split('.').skip(1).join('.')]);
        await canLaunch(consolePage)
            ? await launch(consolePage)
            : throw 'Could not launch $consolePage';
      } else {
        // Open Sign-In/Sign-Up page
        await Get.find<AuthenticationCubit>().resetAuthenticationState();
      }
    } catch (e) {
      Logger().e('ERROR during opening console page:\n$e');
    }
  }

  Widget _loadingLayout() {
    return Container(
      child: CircularProgressIndicator(
        backgroundColor: Colors.transparent,
        color: const Color(0xff004dff),
        strokeWidth: 1.0,
      ),
    );
  }

  Future<void> _showConfirmLogoutDialog(
      {required String currentServerUrl}) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: ConfirmDialog(
            body: Text(
              AppLocalizations.of(context)
                      ?.confirmLogoutMagicLink(currentServerUrl) ??
                  '',
              style: Theme.of(context)
                  .textTheme
                  .headline1
                  ?.copyWith(fontSize: 18.0, fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
            cancelActionTitle: AppLocalizations.of(context)?.cancel ?? '',
            okActionTitle: AppLocalizations.of(context)?.logout ?? '',
            okAction: () => _handleLogoutAction(),
            cancelAction: () => _handleCancelAction(),
            closeDialogAction: () => _handleCancelAction(),
          ),
        );
      },
    );
  }

  void _handleLogoutAction() {
    joiningCubit.forceLogoutCurrentServer(
      widget.requestedToken,
      widget.incomingHost,
    );
  }

  void _handleCancelAction() {
    // cancel magic link flow, back to normal authen flow
    Get.find<AuthenticationCubit>().checkAuthentication();
  }
}
