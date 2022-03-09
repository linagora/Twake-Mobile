import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/authentication_cubit/authentication_cubit.dart';
import 'package:twake/blocs/companies_cubit/companies_cubit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:twake/models/deeplink/join/workspace_join_response.dart';
import 'package:twake/widgets/common/button_text_builder.dart';

class NoCompanyWidget extends StatefulWidget {

  final WorkspaceJoinResponse? magicLinkJoinResponse;
  const NoCompanyWidget({Key? key, this.magicLinkJoinResponse}) : super(key: key);

  @override
  _NoCompanyWidgetState createState() => _NoCompanyWidgetState();
}

class _NoCompanyWidgetState extends State<NoCompanyWidget> {

  final companyCubit = Get.find<CompaniesCubit>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('😔', style: TextStyle(fontSize: 48.0)),
              SizedBox(height: 24.0),
              Text(AppLocalizations.of(context)?.youHaveNoCompany ?? '',
                  style: Get.theme.textTheme.headline1?.copyWith(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold
                  )),
              SizedBox(height: 16.0),
              Text(AppLocalizations.of(context)?.youHaveNoCompanySubtitle ?? '',
                  style: Get.theme.textTheme.headline1,
                  textAlign: TextAlign.center),
              SizedBox(height: 40.0),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    ButtonTextBuilder(Key('button_retry'),
                          onButtonClick: () => _handleClickOnRetry(),
                          backgroundColor: Theme.of(context).colorScheme.secondaryContainer)
                      .setText(AppLocalizations.of(context)?.retry ?? '')
                      .setTextStyle(
                        Get.theme.textTheme.headline4!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 17.0,
                        ),
                      )
                      .setHeight(50)
                      .setBorderRadius(BorderRadius.all(Radius.circular(14)))
                      .build(),
                    SizedBox(height: 8.0),
                    ButtonTextBuilder(Key('button_logout'),
                          onButtonClick: () => _handleClickOnLogout(),
                          backgroundColor: Theme.of(context).colorScheme.surface)
                      .setText(AppLocalizations.of(context)?.logout ?? '')
                      .setHeight(50)
                      .setBorderRadius(BorderRadius.all(Radius.circular(14)))
                      .build()
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _handleClickOnRetry() {
    Get.find<AuthenticationCubit>().refetchAllAfterRetriedNoCompany(
      joinResponse: widget.magicLinkJoinResponse,
    );
  }

  void _handleClickOnLogout() {
    Get.find<AuthenticationCubit>().logout();
  }
}
