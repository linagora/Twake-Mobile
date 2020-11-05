import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/providers/companies_provider.dart';
import 'package:twake_mobile/widgets/company/company_tile.dart';

class CompaniesListScreen extends StatelessWidget {
  static const route = '/companies/list';
  @override
  Widget build(BuildContext context) {
    var companies = Provider.of<CompaniesProvider>(context).items;
    return Scaffold(
      appBar: AppBar(
        title: Text('Your companies'),
      ),
      body: Center(
        child: ListView(
          children: companies.map((c) => CompanyTile(c)).toList(),
        ),
      ),
    );
  }
}
