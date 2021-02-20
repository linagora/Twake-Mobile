import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/configuration_cubit/configuration_cubit.dart';
import 'package:twake/blocs/configuration_cubit/configuration_state.dart';

class ServerConfiguration extends StatefulWidget {
  @override
  _ServerConfigurationState createState() => _ServerConfigurationState();
}

class _ServerConfigurationState extends State<ServerConfiguration> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20.0),
            Image.asset('assets/images/server.png'),
            SizedBox(height: 20.0),
            Text(
              'Server connection\npreference',
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 36.0),
            Padding(
              padding: EdgeInsets.only(left: 16, right: 36.0),
              child: Text(
                'Before you can proceed, please, choose a default server connection',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.normal,
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 0),
              child: BlocBuilder<ConfigurationCubit, ConfigurationState>(
                builder: (context, state) {
                  return TextFormField(
                    key: _formKey,
                    validator: (value) =>
                        value.isEmpty ? 'Address cannot be blank' : null,
                    controller: _controller,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'https:// mobile.api.twake.app',
                      hintStyle: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.w400,
                        color: Color(0xffc8c8c8),
                      ),
                      alignLabelWithHint: true,
                      fillColor: Color(0xfff4f4f4),
                      filled: true,
                      suffix: Container(
                        width: 30,
                        height: 25,
                        padding: EdgeInsets.only(left: 10),
                        child: IconButton(
                          padding: EdgeInsets.all(0),
                          onPressed: () => _controller.clear(),
                          iconSize: 15,
                          icon: Icon(CupertinoIcons.clear),
                        ),
                      ),
                      border: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          width: 0.0,
                          style: BorderStyle.none,
                        ),
                      ),
                    ),
                  );
                }
              ),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                'Tap “Connect” if you don’t know exactly what is this all about',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 22.0),
              child: TextButton(
                onPressed: () => print('Connect'),
                child: Container(
                  width: Size.infinite.width,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xff3840f7),
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Connect',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
