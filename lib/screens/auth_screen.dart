import 'package:flutter/material.dart';
import 'package:twake_mobile/widgets/auth/auth_form.dart';

class AuthScreen extends StatelessWidget {
  static const route = '/auth';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthForm(),
    );
  }
}
