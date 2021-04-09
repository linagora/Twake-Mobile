import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/auth_bloc/auth_bloc.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/blocs/sheet_bloc/sheet_bloc.dart';
import 'package:twake/repositories/sheet_repository.dart';
import 'package:twake/widgets/common/button_field.dart';
import 'package:twake/widgets/common/switch_field.dart';
import 'package:twake/widgets/common/warning_dialog.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SheetBloc>().add(SetFlow(flow: SheetFlow.profile));
      context
          .read<ProfileBloc>()
          .add(SetProfileFlowStage(ProfileFlowStage.info));
    });
  }

  void _handleLogout(BuildContext parentContext) async {
    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return WarningDialog(
          title: 'Are you sure you want to log out of your account?',
          leadingActionTitle: 'Cancel',
          trailingActionTitle: 'Log out',
          trailingAction: () async {
            BlocProvider.of<AuthBloc>(parentContext).add(ResetAuthentication());
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Color(0xffefeef3),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.0, 42.0, 16.0, 36.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage all your data in one place',
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
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
                  onTap: () {
                    context.read<SheetBloc>()
                      ..add(SetFlow(flow: SheetFlow.profile))
                      ..add(OpenSheet());
                  },
                ),
                SizedBox(height: 10.0),
                Text(
                  'Twake Connect allows you to edit personal data, manage\nworkspaces as well as manage active participants and\ntheir permissions.',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff939297),
                  ),
                ),
                SizedBox(height: 72.0),
                SwitchField(
                  image: 'assets/images/notifications.png',
                  title: 'Notifications',
                  value: false,
                  isExtended: true,
                  isRounded: true,
                  onChanged: (value) {},
                ),
                SizedBox(height: 8.0),
                Text(
                  'Allow notifications to stay up-to-date on new messages,\nmeetings and other alerts',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff939297),
                  ),
                ),
                SizedBox(height: 24.0),
                ButtonField(
                  image: 'assets/images/language.png',
                  title: 'Language',
                  titleStyle: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  hasArrow: true,
                  arrowColor: Color(0xff3c3c43).withOpacity(0.3),
                  trailingTitle: 'English',
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
                ),
                SizedBox(height: 24.0),
                ButtonField(
                  image: 'assets/images/support.png',
                  title: 'Customer support',
                  titleStyle: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  hasArrow: true,
                  arrowColor: Color(0xff3c3c43).withOpacity(0.3),
                ),
                SizedBox(height: 21.0),
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
                      'Log out',
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.w400,
                        color: Color(0xffff3b30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
