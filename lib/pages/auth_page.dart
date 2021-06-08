import 'package:flutter/material.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/widgets/auth/auth_form.dart';
import 'package:twake/pages/server_configuration.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  var _index = 0;
  late List<Widget> _widgets;

  @override
  void initState() {
    super.initState();

    _widgets = [
      Center(
        child: AuthForm(
          onConfigurationOpen: () => setState(() {
            _index = 1;
          }),
        ),
      ),
      ServerConfiguration(
        onCancel: () => setState(() {
          _index = 0;
        }),
        onConfirm: () => setState(() {
          _index = 0;
        }),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: Dim.maxScreenHeight,
            width: Dim.maxScreenWidth,
          ),
          MediaQuery.of(context).viewInsets.bottom == 0 // keyboard is hidden
              // show the curve
              ? ClipPath(
                  clipper: _DiagonalClipper(),
                  child: Container(
                    color: Theme.of(context).accentColor,
                    height: Dim.maxScreenHeight,
                    width: Dim.maxScreenWidth,
                  ),
                )
              // show nothing
              : Container(),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(top: Dim.hm5),
              width: Dim.widthPercent(20),
              height: Dim.widthPercent(20),
              child: Image.asset(
                'assets/images/logo-white.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          IndexedStack(
            alignment: Alignment.bottomCenter,
            sizing: StackFit.expand,
            index: _index,
            children: _widgets,
          ),
        ],
      ),
    );
  }
}

/// Custom clipper for getting wavy shape on auth screen
class _DiagonalClipper extends CustomClipper<Path> {
  final double _curvature = Dim.wm4;

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height * (1 / 15));
    path.lineTo(
        size.width / 2 - _curvature, size.height * (1 / 4) - _curvature / 2);
    path.quadraticBezierTo(size.width / 2, size.height * (1 / 4),
        size.width / 2 + _curvature, size.height * (1 / 4) - _curvature / 2);
    path.lineTo(size.width, size.height * (1 / 15));
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_DiagonalClipper oldClipper) => true;
}
