import 'package:flutter/material.dart';
import 'package:twake_mobile/widgets/auth/auth_form.dart';

class AuthScreen extends StatelessWidget {
  static const route = '/auth';
  @override
  Widget build(BuildContext context) {
    final deviceDimensions = MediaQuery.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            /// Calculating
            height: deviceDimensions.size.height -
                deviceDimensions.padding.top -
                deviceDimensions.padding.bottom,
            width: deviceDimensions.size.width,
          ),
          ClipPath(
            clipper: DiagonalClipper(),
            child: Container(
              color: Theme.of(context).primaryColor,

              // Calculating the height
              height: deviceDimensions.size.height -
                  deviceDimensions.padding.top -
                  deviceDimensions.padding.bottom,
              width: deviceDimensions.size.width,
            ),
          ),
          Center(child: AuthForm()),
        ],
      ),
    );
  }
}

class DiagonalClipper extends CustomClipper<Path> {
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
  bool shouldReclip(DiagonalClipper oldClipper) => true;
}
