import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/config/styles_config.dart';
import 'package:twake_mobile/services/twake_api.dart';
import 'package:twake_mobile/config/dimensions_config.dart' show Dim;

class AuthForm extends StatefulWidget {
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  String username = '';
  String password = '';
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

  var passwordController = TextEditingController();
  var usernameController = TextEditingController();

  @override
  initState() {
    passwordController.addListener(onPasswordSaved);
    usernameController.addListener(onUsernameSaved);
    super.initState();
  }

  @override
  dispose() {
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

  Future<void> onSubmit(BuildContext ctx) async {
    if (!formKey.currentState.validate()) return;
    formKey.currentState.save();
    try {
      await Provider.of<TwakeApi>(ctx, listen: false)
          .authenticate(username, password);
    } catch (error) {
      Scaffold.of(ctx).hideCurrentSnackBar();
      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text('Failed to authorize! Check credentials and try again'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Dim.widthPercent(87),
      height: Dim.heightPercent(63),
      child: Padding(
        padding: EdgeInsets.only(
          left: Dim.wm4,
          right: Dim.wm4,
          top: Dim.hm4,
          bottom: Dim.hm2,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
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
              SizedBox(height: Dim.hm8),
              _AuthTextForm(
                label: 'Email',
                validator: validateUsername,
                // onSaved: onUsernameSaved,
                controller: usernameController,
              ),
              SizedBox(height: Dim.hm4),
              _AuthTextForm(
                label: 'Password',
                obscured: true,
                validator: validatePassword,
                // onSaved: onPasswordSaved,
                controller: passwordController,
              ),
              SizedBox(height: Dim.heightMultiplier),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Forgot password?',
                  style: StylesConfig.miniPurple,
                ),
              ),
              SizedBox(height: Dim.hm4),
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
                      ? () => onSubmit(context)
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
                      Text(
                        ' Sign up',
                        style: StylesConfig.miniPurple,
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
  final String Function(String) validator;
  const _AuthTextForm({
    @required this.label,
    @required this.controller,
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
      obscureText: widget.obscured ? _obscured : false,
      validator: widget.validator,
      // onFieldSubmitted: widget.onSaved,
      controller: widget.controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        fillColor: Color.fromRGBO(239, 239, 245, 1),
        filled: true,
        labelText: widget.label,
        labelStyle: TextStyle(fontSize: Dim.tm2(decimal: .1)),
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
