import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/auth_bloc.dart';
import 'package:twake/config/styles_config.dart';
import 'package:twake/pages/webview_page.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;

class AuthForm extends StatefulWidget {
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  String username = '';
  String password = '';
  var passwordController = TextEditingController();
  var usernameController = TextEditingController();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final GlobalKey<FormState> formKey = GlobalKey();

  /// Closure to store the username from form field
  void onUsernameSaved() {
    username = usernameController.text;
    // triggering ui rebuild
    setState(() {});
  }

  /// Closure to store the password from form field
  void onPasswordSaved() {
    password = passwordController.text;
    // triggering ui rebuild
    setState(() {});
  }

  @override
  initState() {
    super.initState();
    passwordController.addListener(onPasswordSaved);
    usernameController.addListener(onUsernameSaved);
  }

  @override
  dispose() {
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  String validateUsername(String value) {
    if (value.isEmpty) {
      return 'Username cannot be empty';
    }
    return null;
  }

  String validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password cannot be empty';
    }
    return null;
  }

  void onSubmit() {
    BlocProvider.of<AuthBloc>(context).add(
      Authenticate(
        username,
        password,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Dim.widthPercent(87),
      height: Dim.heightPercent(67),
      child: Padding(
        padding: EdgeInsets.only(
          left: Dim.wm4,
          right: Dim.wm4,
          top: Dim.hm3,
          bottom: Dim.hm2,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  'Let\'s get started!',
                  style: Theme.of(context).textTheme.headline1,
                ),
              ),
              SizedBox(height: Dim.heightMultiplier),
              Center(
                child: Text(
                  'Sign in to continue',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
              Spacer(),
              _AuthTextForm(
                label: 'Email',
                validator: validateUsername,
                // onSaved: onUsernameSaved,
                controller: usernameController,
                focusNode: _usernameFocusNode,
              ),
              SizedBox(height: Dim.hm3),
              _AuthTextForm(
                label: 'Password',
                obscured: true,
                validator: validatePassword,
                // onSaved: onPasswordSaved,
                controller: passwordController,
                focusNode: _passwordFocusNode,
              ),
              SizedBox(height: Dim.heightMultiplier),
              Align(
                alignment: Alignment.centerRight,
                child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      WebViewScreen.route,
                      arguments: 'https://web.twake.app/',
                    );
                  },
                  child: Text(
                    'Forgot password?',
                    style: StylesConfig.miniPurple,
                  ),
                ),
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: Dim.wm4,
                    vertical: Dim.tm2(decimal: -.2),
                  ),
                  color: Theme.of(context).accentColor,
                  textColor: Colors.white,
                  disabledColor: Color.fromRGBO(238, 238, 238, 1),
                  child: Text(
                    'Login',
                    style: Theme.of(context).textTheme.button,
                  ),
                  onPressed: username.isNotEmpty && password.isNotEmpty
                      ? () => onSubmit()
                      : null,
                ),
              ),
              Spacer(),
              Align(
                alignment: Alignment.center,
                child: FittedBox(
                  child: Row(
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: StylesConfig.miniPurple
                            .copyWith(color: Colors.black87),
                      ),
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            WebViewScreen.route,
                            arguments: 'https://web.twake.app/',
                          );
                        },
                        child: Text(
                          ' Sign up',
                          style: StylesConfig.miniPurple,
                        ),
                      ),
                    ],
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

class _AuthTextForm extends StatefulWidget {
  final String label;
  final bool obscured;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String Function(String) validator;
  const _AuthTextForm({
    @required this.label,
    @required this.controller,
    @required this.focusNode,
    this.validator,
    this.obscured: false,
  });

  @override
  __AuthTextFormState createState() => __AuthTextFormState();
}

class __AuthTextFormState extends State<_AuthTextForm> {
  bool _obscured = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // style: TextStyle(fontSize: Dim.tm2(decimal: 0.2)),
      obscureText: widget.obscured ? _obscured : false,
      validator: widget.validator,
      // onFieldSubmitted: widget.onSaved,
      controller: widget.controller,
      focusNode: widget.focusNode,
      keyboardType: TextInputType.emailAddress,
      style: Theme.of(context).textTheme.headline2,
      decoration: InputDecoration(
        fillColor: Color.fromRGBO(239, 239, 245, 1),
        filled: true,
        labelText: widget.label,
        labelStyle: TextStyle(fontSize: Dim.tm2(decimal: .1), height: 0.9),
        contentPadding: EdgeInsets.fromLTRB(
          Dim.wm3,
          Dim.heightMultiplier,
          Dim.wm3,
          Dim.heightMultiplier,
        ),
        suffixIcon: widget.obscured
            ? IconButton(
                icon: Icon(
                  Icons.remove_red_eye_outlined,
                  color: _obscured ? Colors.grey : Colors.blue,
                ),
                onPressed: () {
                  setState(() {
                    _obscured = !_obscured;
                  });
                })
            : null,
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            width: 0.0,
            style: BorderStyle.none,
          ),
          borderRadius: BorderRadius.circular(7.0),
        ),
      ),
    );
  }
}
