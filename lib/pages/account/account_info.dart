import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/widgets/common/image_widget.dart';
import 'package:twake/widgets/common/rounded_text_field.dart';

class AccountInfo extends StatefulWidget {
  @override
  _AccountInfoState createState() => _AccountInfoState();
}

class _AccountInfoState extends State<AccountInfo> {
  final _userNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  String _name = "";
  bool _canSave = false;
  String _picture = '';

  @override
  void initState() {
    super.initState();
    _userNameController.text = '';
    _firstNameController.text = '';
    _lastNameController.text = '';
    _oldPasswordController.text = '';
    _newPasswordController.text = '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _save() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff2f2f6),
      body: SafeArea(
        child: BlocBuilder<AccountCubit, AccountState>(
          bloc: Get.find<AccountCubit>(),
          builder: (context, accountState) {
            if (accountState is AccountLoadSuccess) {
              _userNameController.text = '@${accountState.account.username}';
              _firstNameController.text = accountState.account.firstName ?? '';
              _lastNameController.text = accountState.account.lastName ?? '';
              _picture = accountState.account.picture ?? '';
              _name = accountState.account.fullName;
            } else if (accountState is AccountLoadInProgress ||
                accountState is AccountLoadFailure) {}

            return GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              behavior: HitTestBehavior.opaque,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                children: [
                  Container(
                    height: 56.0,
                    child: OverflowBox(
                      maxWidth: MediaQuery.of(context).size.width,
                      maxHeight: 56.0,
                      child: Container(
                        padding:
                            const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => NavigatorService.instance.back(),
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: Color(0xff3840f7),
                              ),
                            ),
                            // SizedBox(width: 24.0),
                            GestureDetector(
                              onTap: _canSave ? () => _save() : null,
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
                          ],
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 25.0),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ImageWidget(
                              imageType: ImageType.common,
                              name: _name,
                              imageUrl: _picture,
                              size: 100,
                            ),
                            SizedBox(height: 12.0),
                          ],
                        ),
                      ),
                      SizedBox(height: 36.0),
                      RoundedTextField(
                        controller: _userNameController,
                        prefix: AppLocalizations.of(context)!.username,
                        hint: AppLocalizations.of(context)!.notAssigned,
                        borderRadius: BorderRadius.circular(10.0),
                        enabled: false,
                      ),
                      SizedBox(height: 43.0),
                      Text(
                        AppLocalizations.of(context)!.name,
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withOpacity(0.35),
                        ),
                      ),
                      SizedBox(height: 12.0),
                      RoundedTextField(
                        controller: _firstNameController,
                        prefix: AppLocalizations.of(context)!.firstName,
                        hint: AppLocalizations.of(context)!.notAssigned,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        ),
                        enabled: false,
                      ),
                      Divider(
                        height: 1.0,
                        color: Colors.black.withOpacity(0.1),
                      ),
                      RoundedTextField(
                        controller: _lastNameController,
                        prefix: AppLocalizations.of(context)!.lastName,
                        hint: AppLocalizations.of(context)!.notAssigned,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0),
                        ),
                        enabled: false,
                      ),
                      SizedBox(height: 43.0),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
