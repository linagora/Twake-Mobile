import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:twake/repositories/channel_repository.dart';
import 'package:twake/widgets/common/selectable_avatar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:twake/widgets/sheets/button_field.dart';
import 'package:twake/widgets/sheets/hint_line.dart';
import 'package:twake/widgets/sheets/sheet_text_field.dart';
import 'package:twake/widgets/sheets/switch_field.dart';

class EditChannel extends StatefulWidget {
  @override
  _EditChannelState createState() => _EditChannelState();
}

class _EditChannelState extends State<EditChannel> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();

  var _channelType = ChannelType.public;
  var _participants = <String>[];
  var _showHistoryForNew = true;
  var _canSave = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _nameFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  void _batchUpdateState({
    String name,
    String description,
    ChannelType type,
    List<String> participants,
    bool showHistoryForNew,
  }) {
    // context.read<AddChannelBloc>().add(Update(
    //   name: name ?? _channelNameController.text,
    //   description: description ?? _descriptionController.text,
    //   type: type ?? _channelType,
    //   participants: participants ?? _participants,
    //   automaticallyAddNew: automaticallyAddNew ?? _automaticallyAddNew,
    // ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffefeef3),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 17.0, 16.0, 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xff3840f7),
                        fontSize: 17.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      SelectableAvatar(size: 74.0),
                      SizedBox(height: 4.0),
                      Text('Change avatar',
                          style: TextStyle(
                            color: Color(0xff3840f7),
                            fontSize: 13.0,
                            fontWeight: FontWeight.w400,
                          )),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => print('Save channel.'),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: _canSave != null
                            ? Color(0xff3840f7)
                            : Color(0xffa2a2a2),
                        fontSize: 17.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RoundedBoxButton(
                  cover: Image.asset('assets/images/add_new_member.png'),
                  title: 'add',
                  onTap: () => print('Add'),
                ),
                SizedBox(width: 10.0),
                RoundedBoxButton(
                  cover: Image.asset('assets/images/leave.png'),
                  title: 'leave',
                  onTap: () => print('leave'),
                ),
              ],
            ),
            SizedBox(height: 24.0),
            HintLine(text: 'CHANNEL INFORMATION', isLarge: true),
            SizedBox(height: 12.0),
            Divider(
              thickness: 0.5,
              height: 0.5,
              color: Colors.black.withOpacity(0.2),
            ),
            SheetTextField(
              hint: 'Channel name',
              controller: _nameController,
              focusNode: _nameFocusNode,
            ),
            Divider(
              thickness: 0.5,
              height: 0.5,
              color: Colors.black.withOpacity(0.2),
            ),
            SheetTextField(
              hint: 'Description',
              controller: _descriptionController,
              focusNode: _descriptionFocusNode,
            ),
            Divider(
              thickness: 0.5,
              height: 0.5,
              color: Colors.black.withOpacity(0.2),
            ),
            // ButtonField(
            //   title: 'Channel type',
            //   trailingTitle: 'Public',
            //   hasArrow: true,
            // ),
            SizedBox(height: 32.0),
            HintLine(text: 'MEMBERS', isLarge: true),
            SizedBox(height: 12.0),
            Divider(
              thickness: 0.5,
              height: 0.5,
              color: Colors.black.withOpacity(0.2),
            ),
            ButtonField(
              title: 'Member management',
              trailingTitle: 'Manage',
              hasArrow: true,
            ),
            Divider(
              thickness: 0.5,
              height: 0.5,
              color: Colors.black.withOpacity(0.2),
            ),
            // SwitchField(
            //   title: 'Chat history for new members',
            //   value: _showHistoryForNew,
            //   onChanged: (value) =>
            //       _batchUpdateState(showHistoryForNew: value),
            //   isExtended: true,
            // ),
            // SizedBox(height: 8.0),
            // HintLine(text: 'Show previous chat history for newly added members'),
          ],
        ),
      ),
    );
  }
}

class RoundedBoxButton extends StatelessWidget {
  final Widget cover;
  final String title;
  final Function onTap;

  const RoundedBoxButton({
    Key key,
    @required this.cover,
    @required this.title,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(18.0, 13.0, 18.0, 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: SizedBox(
        width: 45.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            cover,
            SizedBox(height: 5.0),
            AutoSizeText(
              title,
              minFontSize: 10.0,
              maxFontSize: 13.0,
              maxLines: 1,
              style: TextStyle(
                color: Color(0xff3840f7),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
