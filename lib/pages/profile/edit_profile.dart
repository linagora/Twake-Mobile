import 'package:flutter/material.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/widgets/common/selectable_avatar.dart';
import 'package:twake/widgets/common/rounded_text_field.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _nameController = TextEditingController();
  final _displayedNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cellularController = TextEditingController();

  var _canSave = true;

  @override
  void initState() {
    super.initState();
    _nameController.text = 'Diana Potokina';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _displayedNameController.dispose();
    _emailController.dispose();
    _cellularController.dispose();
    super.dispose();
  }

  void _save() {
    print('Save profile!');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 56.0,
              child: OverflowBox(
                maxWidth: MediaQuery.of(context).size.width,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 8.0),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                      // SizedBox(width: 24.0),
                      GestureDetector(
                        onTap: _canSave ? () => _save() : null,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Save',
                            style: TextStyle(
                              color: _canSave ? Color(0xff3840f7) : Color(0xffa2a2a2),
                              fontSize: 17.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 25.0),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SelectableAvatar(
                    size: 100.0,
                    icon: '',
                    onTap: () {},
                  ),
                  SizedBox(height: 12.0),
                  GestureDetector(
                    onTap: () => print('Change avatar!'),
                    child: Text(
                      'Tap to upload',
                      style: TextStyle(
                        color: Color(0xff3840f7),
                        fontSize: 13.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 36.0),
            Text(
              'NAME',
              style: TextStyle(
                fontSize: 17.0,
                fontWeight: FontWeight.w600,
                color: Colors.black.withOpacity(0.35),
              ),
            ),
            SizedBox(height: 12.0),
            RoundedTextField(
              controller: _nameController,
              hint: 'Not assigned',
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
            ),
            Divider(
              height: 1.0,
              color: Colors.black.withOpacity(0.1),
            ),
            RoundedTextField(
              controller: _displayedNameController,
              hint: 'Not assigned',
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              '«Displayed name» is how people see your name in Twake\nin @mentions and by other users in channels and private chats',
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.w400,
                color: Colors.black.withOpacity(0.35),
              ),
            ),
            SizedBox(height: 43.0),
            Text(
              'CONTACT DETAILS',
              style: TextStyle(
                fontSize: 17.0,
                fontWeight: FontWeight.w600,
                color: Colors.black.withOpacity(0.35),
              ),
            ),
            SizedBox(height: 12.0),
            RoundedTextField(
              controller: _nameController,
              hint: 'Not assigned',
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
            ),
            Divider(
              height: 1.0,
              color: Colors.black.withOpacity(0.1),
            ),
            RoundedTextField(
              controller: _displayedNameController,
              hint: 'Not assigned',
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
              ),
            ),
            SizedBox(height: 24.0),
            Text(
              'DATE & TIME',
              style: TextStyle(
                fontSize: 17.0,
                fontWeight: FontWeight.w600,
                color: Colors.black.withOpacity(0.35),
              ),
            ),
            SizedBox(height: 12.0),
            RoundedTextField(
              controller: _nameController,
              hint: 'Not assigned',
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
            ),
            Divider(
              height: 1.0,
              color: Colors.black.withOpacity(0.1),
            ),
            RoundedTextField(
              controller: _displayedNameController,
              hint: 'Not assigned',
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
