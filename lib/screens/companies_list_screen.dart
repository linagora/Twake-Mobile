import 'package:flutter/material.dart';

class CompaniesListScreen extends StatelessWidget {
  static const route = '/companies/list';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your companies'),
      ),
      body: Center(
        child: Text('You haven\'t been added to any company yet!'),
      ),
    );
  }
}
