import 'package:flutter/material.dart';
import 'package:twake_mobile/config/dimensions_config.dart';
import 'package:twake_mobile/screens/companies_list_screen.dart';

class AuthForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        width: 83 * DimensionsConfig.widthMultiplier,
        height: 47 * DimensionsConfig.heightMultiplier,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: 7 * DimensionsConfig.widthMultiplier,
              vertical: 0.3 * DimensionsConfig.heightMultiplier),
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Center(
                  child: Text(
                    'Sign in to Twake',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                Center(
                  child: Text(
                    'Happy to see you \u{1F607}',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                SizedBox(height: 3 * DimensionsConfig.heightMultiplier),
                const _AuthTextForm(label: 'Username or e-mail'),
                const _AuthTextForm(label: 'Password', obscured: true),
                SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 0.7 * DimensionsConfig.heightMultiplier,
                    ),
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    child: Text(
                      'Log in',
                      style: Theme.of(context).textTheme.button,
                    ),
                    // allows to login no matter what, have to implement authentication logic first
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacementNamed(CompaniesListScreen.route);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthTextForm extends StatelessWidget {
  final String label;
  final bool obscured;
  const _AuthTextForm({
    @required this.label,
    this.obscured: false,
  });
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscured,
      decoration: InputDecoration(
        fillColor: Color.fromRGBO(238, 238, 238, 0.9),
        filled: true,
        labelText: label,
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
