import 'package:flutter/material.dart';
import 'package:twake_mobile/screens/companies_list_screen.dart';

class AuthForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      elevation: 2,
      child: Container(
        width: deviceSize.width * 0.8,
        height: deviceSize.height * 0.39,
        child: Padding(
          padding: const EdgeInsets.all(23.0),
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Center(
                  child: const Text(
                    'Sign in to Twake',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Center(
                  child: const Text(
                    'Happy to see you \u{1F607}',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
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
                      vertical: 14,
                    ),
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    child: Text(
                      'Log in',
                      style: TextStyle(fontSize: 22),
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
