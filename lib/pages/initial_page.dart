import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/auth_bloc.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/events/auth_event.dart';
import 'package:twake/pages/auth_page.dart';
import 'package:twake/pages/main_page.dart';
import 'package:twake/states/auth_state.dart';

class InitialPage extends StatefulWidget {
  @override
  _InitialPageState createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<AuthBloc>(context).add(AuthInitialize());
  }

  Widget buildSplashScreen() {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: Dim.hm9,
          height: Dim.hm9,
          child: Image.asset(
            'assets/images/oldtwakelogo.jpg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (ctx, state) {
        if (state is AuthInitializing) {
          return buildSplashScreen();
        }
        if (state is Unauthenticated) {
          return AuthPage();
        }
        return MainPage();
      },
    );
  }
}
