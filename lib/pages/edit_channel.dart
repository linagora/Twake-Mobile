import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:twake/widgets/common/selectable_avatar.dart';

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
              padding: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xff837cfe),
                        fontSize: 17.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SelectableAvatar(),
                  TextButton(
                    onPressed: () => print('Save channel.'),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: _canSave != null
                            ? Color(0xff837cfe)
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
          ],
        ),
      ),
    );
  }
}

class RoundedBoxButton extends StatelessWidget {
  final Image image;
  final String title;
  final Function onTap;

  const RoundedBoxButton({
    Key key,
    @required this.image,
    @required this.title,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          image,
          SizedBox(height: 7.0),
          Text(
            title,
            style: TextStyle(
              color: Color(0xff3840f7),
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
