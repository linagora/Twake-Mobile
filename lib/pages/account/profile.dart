/* import 'package:flutter/material.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/blocs/sheet_bloc/sheet_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/models/language_option.dart';
import 'package:twake/widgets/common/selectable_avatar.dart';
import 'package:twake/widgets/common/button_field.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  String? _firstName = '';
  String? _lastName = '';
  String? _picture = '';
  var _language = '';
  List<LanguageOption>? _availableLanguages = <LanguageOption>[];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BlocBuilder<AccountCubit, AccountState>(
        buildWhen: (_, current) =>
            current is AccountLoadSuccess ||
            current is AccountSaveSuccess ||
            current is AccountPictureUploadSuccess,
        builder: (context, state) {
          if (state is AccountLoadSuccess) {
            _firstName = state.firstName;
            _lastName = state.lastName;
            _picture = state.picture;
            _availableLanguages = state.availableLanguages;
          }
          if (state is AccountSaveSuccess) {
            _firstName = state.firstName;
            _lastName = state.lastName;
          }
          if (state is AccountPictureUploadSuccess) {
            _picture = state.link;
          }
          // print('AccountCubit state in Profile: $state');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.read<SheetBloc>().add(CloseSheet());
                      },
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xff3840f7),
                      ),
                    ),
                    Column(
                      children: [
                        SelectableAvatar(
                          size: 60.0,
                          userpic: _picture,
                          onTap: () {},
                        ),
                        SizedBox(height: 12.0),
                        Text(
                          '$_firstName $_lastName',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 24.0),
                  ],
                ),
              ),
              SizedBox(height: 36.0),
              Text(
                'Profile',
                style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 12.0),
              ButtonField(
                title: 'Edit personal information',
                titleStyle: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
                hasArrow: true,
                arrowColor: Color(0xff3c3c43).withOpacity(0.3),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
                onTap: () {
                  context
                      .read<AccountCubit>()
                      .updateAccountFlowStage(AccountFlowStage.edit);
                },
              ),
              Divider(
                height: 1.0,
                color: Colors.black.withOpacity(0.1),
              ),
              ButtonField(
                title: 'Privacy settings',
                titleStyle: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
                hasArrow: true,
                arrowColor: Color(0xff3c3c43).withOpacity(0.3),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
              ),
              SizedBox(height: 40.0),
              Text(
                'Companies and workspaces',
                style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 12.0),
              ButtonField(
                title: 'Active companies',
                titleStyle: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
                trailingTitle: '5',
                trailingTitleStyle: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff004dff),
                ),
                hasArrow: true,
                arrowColor: Color(0xff3c3c43).withOpacity(0.3),
              ),
              SizedBox(height: 32.0),
              Text(
                'Users',
                style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 12.0),
              ButtonField(
                title: 'Manage users',
                titleStyle: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
                trailingTitle: '124',
                trailingTitleStyle: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff004dff),
                ),
                hasArrow: true,
                arrowColor: Color(0xff3c3c43).withOpacity(0.3),
              ),
            ],
          );
        },
      ),
    );
  }
}
 */
