import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:twake/widgets/common/selectable_avatar.dart';
import 'package:auto_size_text/auto_size_text.dart';

class EditChannel extends StatefulWidget {
  @override
  _EditChannelState createState() => _EditChannelState();
}

class _EditChannelState extends State<EditChannel> {
  var _canSave = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffefeef3),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
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
                      SelectableAvatar(
                        width: 74.0,
                        height: 74.0,
                      ),
                      SizedBox(height: 4.0),
                      Text('Change avatar',
                          style: TextStyle(
                            color: Color(0xff3840f7),
                            fontSize: 13.0,
                            fontWeight: FontWeight.w400,
                          )),
                    ],
                  ),
                  TextButton(
                    onPressed: () => print('Save channel.'),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: _canSave != null
                            ? Color(0xff3840f7)
                            : Color(0xffa2a2a2),
                        fontSize: 17.0,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.end,
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
                SizedBox(width: 8.0),
                RoundedBoxButton(
                  cover: Image.asset('assets/images/leave.png'),
                  title: 'leave',
                  onTap: () => print('leave'),
                ),
              ],
            )
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
