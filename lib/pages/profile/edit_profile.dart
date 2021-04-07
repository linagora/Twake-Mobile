import 'package:flutter/material.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/blocs/sheet_bloc/sheet_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/widgets/common/selectable_avatar.dart';
import 'package:twake/widgets/common/button_field.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _nameController = TextEditingController();
  final _displayedNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cellularController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _displayedNameController.dispose();
    _emailController.dispose();
    _cellularController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      context
                          .read<ProfileBloc>()
                          .add(SetProfileFlowStage(ProfileFlowStage.info));
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xff3840f7),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      SelectableAvatar(
                        size: 60.0,
                        icon: '',
                        onTap: () {},
                      ),
                      SizedBox(height: 12.0),
                      GestureDetector(
                        onTap: () => print('Change avatar!'),
                        child: Text('Tap to upload',
                            style: TextStyle(
                              color: Color(0xff3840f7),
                              fontSize: 13.0,
                              fontWeight: FontWeight.w400,
                            )),
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
        ),
      ),
    );
  }
}
