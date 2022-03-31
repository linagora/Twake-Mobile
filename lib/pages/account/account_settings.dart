import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/blocs/authentication_cubit/authentication_cubit.dart';
import 'package:twake/blocs/lenguage_cubit/language_cubit.dart';
import 'package:twake/pages/account/select_language.dart';
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
          if (mounted) {
            Navigator.popUntil(context, ModalRoute.withName(RoutePaths.initial));
          }
        }
      },
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
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
                                color: Theme.of(context)
                                    .textTheme
                                    .headline4!
                                    .color,
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
                        child: Text(AppLocalizations.of(context)!.settings,
                            style: Theme.of(context)
                                .textTheme
                                .headline1!
                                .copyWith(
                                    fontWeight: FontWeight.bold, fontSize: 34)),
                      ),
                      SizedBox(height: 12.0),
                      _buildViewProfile(),
                      Spacer(),
                      SizedBox(height: 16.0),
                      _buildThemeSupportLanguage(),
                      SizedBox(height: 16.0),
                      _buildInvitePeople(),
                      Flexible(child: SizedBox(height: 80.0)),
                      _buildTwakeVersion(),
                      SizedBox(height: 16.0),
                      _buildLogOut(),
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

  _buildViewProfile() {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(14.0)),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 18, bottom: 18),
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
                  Text(name,
                      style: Theme.of(context)
                          .textTheme
                          .headline1!
                          .copyWith(fontWeight: FontWeight.w600, fontSize: 16)),
                  SizedBox(
                    height: 4,
                  ),
                  Text(AppLocalizations.of(context)!.viewProfile,
                      style: Theme.of(context).textTheme.headline2),
                ],
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Icon(
                CupertinoIcons.forward,
                color: Theme.of(context).colorScheme.secondary,
              ),
            )
          ],
        ),
      ),
      onTap: () =>
          NavigatorService.instance.navigateToAccount(shouldShowInfo: true),
    );
  }

  _buildThemeSupportLanguage() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => push(
            RoutePaths.accountTheme.path,
          ),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
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
                  child: Image.asset('assets/images/2.0x/appearance.png'),
                ),
                SizedBox(
                  width: 14,
                ),
                Text(
                  AppLocalizations.of(context)!.appearance,
                  style: Theme.of(context)
                      .textTheme
                      .headline1!
                      .copyWith(fontWeight: FontWeight.normal, fontSize: 17),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Icon(CupertinoIcons.forward,
                      color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 2.0),
        GestureDetector(
          onTap: () => NavigatorService.instance.openTwakeWebView(
              'https://go.crisp.chat/chat/embed/?website_id=9ef1628b-1730-4044-b779-72ca48893161&user_email=$email'),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 14,
                ),
                SizedBox(
                  height: 29,
                  child: Image.asset('assets/images/2.0x/support.png'),
                ),
                SizedBox(
                  width: 14,
                ),
                Text(
                  AppLocalizations.of(context)!.customerSupport,
                  style: Theme.of(context)
                      .textTheme
                      .headline1!
                      .copyWith(fontWeight: FontWeight.normal, fontSize: 17),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Icon(CupertinoIcons.forward,
                      color: Theme.of(context).colorScheme.secondary),
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
              color: Theme.of(context).colorScheme.secondaryContainer,
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
                    child: Image.asset('assets/images/2.0x/net_global.png')),
                SizedBox(
                  width: 14,
                ),
                Text(
                  AppLocalizations.of(context)!.language,
                  style: Theme.of(context)
                      .textTheme
                      .headline1!
                      .copyWith(fontWeight: FontWeight.normal, fontSize: 17),
                ),
                Spacer(),
                BlocBuilder<LanguageCubit, LanguageState>(
                  bloc: Get.find<LanguageCubit>(),
                  builder: (context, state) {
                    if (state is NewLanguage) {
                      return Text(
                        getLanguageString(
                            languageCode: state.language, context: context),
                        style: Theme.of(context)
                            .textTheme
                            .headline2!
                            .copyWith(fontSize: 15),
                      );
                    }
                    {
                      return SizedBox.shrink();
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 14, right: 14.0),
                  child: Icon(
                    CupertinoIcons.forward,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  _buildInvitePeople() {
    return ButtonField(
        onTap: () => _onShareWithEmptyOrigin(context),
        image: 'assets/images/2.0x/invite_people.png',
        title: AppLocalizations.of(context)!.invitePeopleToTwake,
        titleStyle: Theme.of(context)
            .textTheme
            .headline1!
            .copyWith(fontWeight: FontWeight.normal, fontSize: 17),
        hasArrow: true,
        arrowColor: Theme.of(context).colorScheme.secondary);
  }

  _buildTwakeVersion() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(10.0)),
      child: Row(
        children: [
          SizedBox(
            width: 14,
          ),
          SizedBox(
              height: 29,
              child: Image.asset('assets/images/2.0x/twake_logo.png')),
          SizedBox(
            width: 14,
          ),
          Text(
            AppLocalizations.of(context)!.twakeVersion,
            style: Theme.of(context)
                .textTheme
                .headline1!
                .copyWith(fontWeight: FontWeight.normal, fontSize: 17),
          ),
          Spacer(),
          Text(_packageInfo.version,
              style: Theme.of(context)
                  .textTheme
                  .headline2!
                  .copyWith(fontSize: 15)),
          SizedBox(
            width: 14,
          )
        ],
      ),
    );
  }

  _buildLogOut() {
    return GestureDetector(
      onTap: () => _handleLogout(context),
      child: Container(
        height: 44.0,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(10.0),
        ),
        alignment: Alignment.center,
        child: Text(AppLocalizations.of(context)!.logout,
            style: Theme.of(context).textTheme.headline5),
      ),
    );
  }
}
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