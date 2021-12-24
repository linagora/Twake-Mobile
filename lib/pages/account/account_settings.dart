import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/blocs/authentication_cubit/authentication_cubit.dart';
import 'package:twake/blocs/lenguage_cubit/language_cubit.dart';
import 'package:twake/pages/select_language.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/routing/route_paths.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/utils/utilities.dart';
import 'package:twake/widgets/common/button_field.dart';
import 'package:twake/widgets/common/image_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:twake/widgets/common/warning_dialog.dart';

class AccountSettings extends StatefulWidget {
  @override
  _AccountSettingsState createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );
  bool _canSave = false;
  bool switchVal = true;
  String email = '';
  String picture = '';
  String name = '';

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
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

  _onShareWithEmptyOrigin(BuildContext context) async {
    Utilities.shareApp();
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
                  if (accountState is AccountLoadSuccess) {
                    final account = accountState.account;
                    picture = accountState.account.picture ?? '';
                    email = account.email;
                    name = accountState.account.fullName;
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
                          AppLocalizations.of(context)!.settings,
                          style: TextStyle(
                            fontSize: 34.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.0),
                      GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Color(0xFFFCFCFC),
                              borderRadius: BorderRadius.circular(14.0)),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 16.0, top: 18, bottom: 18),
                                child: ImageWidget(
                                  imageType: ImageType.common,
                                  name: name,
                                  imageUrl: picture,
                                  size: 44,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(fontSize: 17),
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      AppLocalizations.of(context)!.viewProfile,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF939297)),
                                    ),
                                  ],
                                ),
                              ),
                              Spacer(),
                              Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Icon(
                                  CupertinoIcons.forward,
                                  color: Color(0xff3c3c43).withOpacity(0.3),
                                ),
                              )
                            ],
                          ),
                        ),
                        onTap: () => NavigatorService.instance
                            .navigateToAccount(shouldShowInfo: true),
                      ),
                      Spacer(),
                      /* TODO implement again when settings screen is going to be ready
                      SwitchField(
                        image: 'assets/images/notifications.png',
                        title: AppLocalizations.of(context)!.notifications,
                        value: switchVal,
                        isExtended: true,
                        isRounded: true,
                        onChanged: (value) {
                          setState(() {
                            switchVal = value;
                          });
                          switchVal
                              ? Get.find<AuthenticationCubit>().registerDevice()
                              : Get.find<AuthenticationCubit>()
                                  .unRegisterDevice();
                        },
                      ),*/
                      SizedBox(height: 16.0),
                      GestureDetector(
                        onTap: () => NavigatorService.instance.openTwakeWebView(
                            'https://go.crisp.chat/chat/embed/?website_id=9ef1628b-1730-4044-b779-72ca48893161&user_email=$email'),
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Color(0xFFFCFCFC),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0),
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 14,
                              ),
                              SizedBox(
                                height: 29,
                                child: Image.asset(
                                    'assets/images/2.0x/support.png'),
                              ),
                              SizedBox(
                                width: 14,
                              ),
                              Text(
                                AppLocalizations.of(context)!.customerSupport,
                                style: TextStyle(
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                              Spacer(),
                              Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Icon(
                                  CupertinoIcons.forward,
                                  color: Color(0xff3c3c43).withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 2.0),
                      GestureDetector(
                        onTap: () async {
                          push(
                            RoutePaths.accountLanguage.path,
                          );
                        },
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Color(0xFFFCFCFC),
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(10.0),
                              bottomLeft: Radius.circular(10.0),
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 14,
                              ),
                              SizedBox(
                                  height: 29,
                                  child: Image.asset(
                                      'assets/images/2.0x/net_global.png')),
                              SizedBox(
                                width: 14,
                              ),
                              Text(
                                AppLocalizations.of(context)!.language,
                                style: TextStyle(
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                              Spacer(),
                              BlocBuilder<LanguageCubit, LanguageState>(
                                bloc: Get.find<LanguageCubit>(),
                                builder: (context, state) {
                                  if (state is NewLanguage) {
                                    return Text(
                                      getLanguageString(
                                          languageCode: state.language,
                                          context: context),
                                      style: TextStyle(
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                    );
                                  }
                                  {
                                    return SizedBox.shrink();
                                  }
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 14, right: 14.0),
                                child: Icon(
                                  CupertinoIcons.forward,
                                  color: Color(0xff3c3c43).withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      ButtonField(
                        onTap: () => _onShareWithEmptyOrigin(context),
                        image: 'assets/images/2.0x/invite_people.png',
                        title:
                            AppLocalizations.of(context)!.invitePeopleToTwake,
                        titleStyle: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        hasArrow: true,
                        arrowColor: Color(0xff3c3c43).withOpacity(0.3),
                      ),
                      SizedBox(height: 80.0),
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                            color: Color(0xFFFCFCFC),
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 14,
                            ),
                            SizedBox(
                                height: 29,
                                child: Image.asset(
                                    'assets/images/2.0x/twake_logo.png')),
                            SizedBox(
                              width: 14,
                            ),
                            Text(
                              AppLocalizations.of(context)!.twakeVersion,
                              style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                            Spacer(),
                            Text(
                              _packageInfo.version,
                              style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                            SizedBox(
                              width: 14,
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 16.0),
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
