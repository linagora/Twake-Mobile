import 'package:flutter/material.dart';
import 'package:twake_mobile/config/dimensions_config.dart';
import 'package:twake_mobile/widgets/auth/auth_form.dart';

class AuthScreen extends StatelessWidget {
  static const route = '/auth';
  @override
  Widget build(BuildContext context) {
    print('DEBUG: building auth screen');
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              height: DimensionsConfig.maxScreenHeight,
              width: DimensionsConfig.maxScreenWidth,
            ),
            ClipPath(
              clipper: _DiagonalClipper(),
              child: Container(
                color: Theme.of(context).primaryColor,
                height: DimensionsConfig.maxScreenHeight,
                width: DimensionsConfig.maxScreenWidth,
              ),
            ),
            Center(child: SingleChildScrollView(child: AuthForm())),
          ],
        ),
      ),
    );
  }
}

class _DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height * (3 / 5));
    path.lineTo(size.width, size.height * (2 / 5));
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_DiagonalClipper oldClipper) => true;
}
