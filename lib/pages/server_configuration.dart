import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/routing/app_router.dart';

class ServerConfiguration extends StatefulWidget {
  final Function? onCancel;
  final Function? onConfirm;

  const ServerConfiguration({
    Key? key,
    this.onCancel,
    this.onConfirm,
  }) : super(key: key);

  @override
  _ServerConfigurationState createState() => _ServerConfigurationState();
}

class _ServerConfigurationState extends State<ServerConfiguration> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void initState() {
    _controller.text = Globals.instance.host;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _connect() async {
    FocusScope.of(context).requestFocus(FocusNode());
    var host = _controller.text;
    bool valid = await Globals.instance.hostSet(host);
    if (valid) {
      widget.onConfirm!();
      //   print(Globals.instance.host);
    } else {
      //   print(Globals.instance.host);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          margin: EdgeInsets.fromLTRB(
            15.0,
            5.0,
            15.0,
            65.0,
            //  Dim.heightPercent(8),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
          content: Text(
            'Invalid host',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(onPressed: () {
          widget.onCancel!();
          // print(Globals.instance.host);
          _controller.text = Globals.instance.host;
        }),
      ),
      body: SafeArea(
        child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: SizedBox(height: 10.0)),
                Image.asset('assets/images/server.png'),
                Expanded(child: SizedBox(height: 15.0)),
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
                Expanded(child: SizedBox(height: 36.0)),
                Expanded(
                  child: Padding(
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
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 0),
                  child: TextFormField(
                    key: _formKey,
                    validator: (value) =>
                        value!.isEmpty ? 'Address cannot be blank' : null,
                    controller: _controller,
                    onFieldSubmitted: (_) => _connect(),
                    style: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: Globals.instance.host.isEmpty
                          ? 'https://beta.twake.app'
                          : Globals.instance.host,
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
                    onPressed: () => _connect(),
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
            )),
      ),
    );
  }
}
