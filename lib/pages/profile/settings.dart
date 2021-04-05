import 'package:flutter/material.dart';
import 'package:twake/widgets/common/button_field.dart';
import 'package:twake/widgets/common/switch_field.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffefeef3),
      body: SafeArea(
        child: Container(
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
                onTap: () => print('Logout'),
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
    );
  }
}
