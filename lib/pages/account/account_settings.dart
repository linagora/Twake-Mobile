import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/blocs/authentication_cubit/authentication_cubit.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/widgets/common/button_field.dart';
import 'package:twake/widgets/common/switch_field.dart';
import 'package:twake/widgets/common/warning_dialog.dart';

class AccountSettings extends StatefulWidget {
  @override
  _AccountSettingsState createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  bool _canSave = false;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance!.addPostFrameCallback((_) {
    //   Get.find<AccountCubit>().fetch(userId: Globals.instance.userId);
    // });
  }

  void _handleLogout(BuildContext parentContext) async {
    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return WarningDialog(
          title: AppLocalizations.of(parentContext)!.logoutConfirmation,
          leadingActionTitle: 'Cancel',
          trailingActionTitle: 'Log out',
          trailingAction: () {
            Get.find<AuthenticationCubit>().logout();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationCubit, AuthenticationState>(
      bloc: Get.find<AuthenticationCubit>(),
      listenWhen: (_, current) => current is LogoutInProgress,
      listener: (context, authenticationState) {
        if (authenticationState is LogoutInProgress) {
          if (mounted) NavigatorService.instance.back(shouldLogout: true);
        }
      },
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          color: Color(0xffefeef3),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.0, 22.0, 16.0, 36.0),
              child: BlocBuilder<AccountCubit, AccountState>(
                bloc: Get.find<AccountCubit>(),
                builder: (context, accountState) {
                  var email = '';
                  var language = '';
                  if (accountState is AccountLoadSuccess) {
                    final account = accountState.account;
                    email = account.email;
                    language = account.language ?? '';
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: GestureDetector(
                              onTap: () => NavigatorService.instance.back(),
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: Color(0xff3840f7),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: GestureDetector(
                              onTap: () {},
                              child: Text(
                                '',
                                style: TextStyle(
                                  color: _canSave
                                      ? Color(0xff3840f7)
                                      : Color(0xffa2a2a2),
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32.0),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          AppLocalizations.of(context)!.manageYourData,
                          style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.0),
                      ButtonField(
                        image: 'assets/images/gear_blue.png',
                        imageSize: 44.0,
                        title: 'Twake Connect',
                        height: 88.0,
                        titleStyle: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        hasArrow: true,
                        onTap: () => NavigatorService.instance
                            .navigateToAccount(shouldShowInfo: true),
                      ),
                      SizedBox(height: 10.0),
                      Padding(
                         padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          AppLocalizations.of(context)!.twakeConnectInfo,
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff939297),
                          ),
                        ),
                      ),
                      SizedBox(height: 22.0),
                      SwitchField(
                        image: 'assets/images/notifications.png',
                        title: AppLocalizations.of(context)!.notifications,
                        value: true,
                        isExtended: true,
                        isRounded: true,
                        onChanged: (value) {},
                      ),
                      SizedBox(height: 8.0),
                      Padding(
                         padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          AppLocalizations.of(context)!.notificationsInfo,
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff939297),
                          ),
                        ),
                      ),
                         SizedBox(height: 8.0),

                      /* ButtonField(
                          image: 'assets/images/language.png',
                          title: AppLocalizations.of(context)!.language,
                          titleStyle: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                          hasArrow: true,
                          arrowColor: Color(0xff3c3c43).withOpacity(0.3),
                          trailingTitle: language,
                          trailingTitleStyle: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.black.withOpacity(0.6),
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0),
                          ),
                        ),
                        Divider(
                          height: 1.0,
                          color: Colors.black.withOpacity(0.1),
                        ),
                        ButtonField(
                          image: 'assets/images/location.png',
                          title: 'Location',
                          titleStyle: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                          hasArrow: true,
                          arrowColor: Color(0xff3c3c43).withOpacity(0.3),
                          trailingTitle: 'Paris',
                          trailingTitleStyle: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.black.withOpacity(0.6),
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10.0),
                            bottomRight: Radius.circular(10.0),
                          ),
                        ),*/

                      ButtonField(
                        onTap: () => NavigatorService.instance.openTwakeWebView(
                            'https://go.crisp.chat/chat/embed/?website_id=9ef1628b-1730-4044-b779-72ca48893161&user_email=$email'),
                        image: 'assets/images/support.png',
                        title: AppLocalizations.of(context)!.customerSupport,
                        titleStyle: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        hasArrow: true,
                        arrowColor: Color(0xff3c3c43).withOpacity(0.3),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () => _handleLogout(context),
                        child: Container(
                          height: 44.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            AppLocalizations.of(context)!.logout,
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.w400,
                              color: Color(0xffff3b30),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 21.0),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
