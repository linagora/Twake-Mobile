import 'package:flutter/material.dart';
import 'package:twake/widgets/common/selectable_avatar.dart';

class AddChannelContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: NewChannelForm(),
    );
  }
}

class NewChannelForm extends StatefulWidget {
  @override
  _NewChannelFormState createState() => _NewChannelFormState();
}

class _NewChannelFormState extends State<NewChannelForm> {
  var _channelName = '';
  var _description = '';
  var _groupName = '';
  var canGoNext = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Color(0xfff7f7f7),
          height: 52,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(),
              Text(
                'New Channel',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Next',
                  style: TextStyle(
                    color: canGoNext ? Color(0xff837cfe) : Color(0xffa2a2a2),
                    fontSize: 17.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
