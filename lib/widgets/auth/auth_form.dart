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
  void onUsernameSaved(value) => username = value;

  /// Closure to store the password from form field
  void onPasswordSaved(value) {
    password = value;
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
      height: Dim.heightPercent(75),
      child: Padding(
        padding: EdgeInsets.only(
          left: Dim.wm4,
          right: Dim.wm4,
          top: Dim.heightPercent(10),
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
              Center(
                child: Text(
                  'Sign in to continue',
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
              SizedBox(height: Dim.hm7),
              _AuthTextForm(
                label: 'Email',
                validator: validatePassword,
                onSaved: onUsernameSaved,
              ),
              SizedBox(height: Dim.hm4),
              _AuthTextForm(
                label: 'Password',
                obscured: true,
                validator: validateUsername,
                onSaved: onPasswordSaved,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Forgot password?',
                  style: StylesConfig.miniPurple,
                ),
              ),
              SizedBox(height: Dim.hm5),
              SizedBox(
                width: double.infinity,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: Dim.wm4,
                    vertical: Dim.tm2(),
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
  final void Function(String) onSaved;
  final String Function(String) validator;
  const _AuthTextForm({
    @required this.label,
    @required this.onSaved,
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
      onChanged: widget.onSaved,
      onFieldSubmitted: widget.onSaved,
      decoration: InputDecoration(
        fillColor: Color.fromRGBO(242, 241, 255, 1),
        filled: true,
        labelText: widget.label,
        labelStyle: TextStyle(fontSize: Dim.tm2(decimal: .1)),
        contentPadding: EdgeInsets.fromLTRB(12, 5, 12, 5),
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
