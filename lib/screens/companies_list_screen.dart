import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/providers/profile_provider.dart';
import 'package:twake_mobile/widgets/company/company_tile.dart';

class CompaniesListScreen extends StatelessWidget {
  static const route = '/companies/list';
  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your companies'),
      ),
      body: profile.loaded
          ? ListView(
              children: profile.companies.map((c) => CompanyTile(c)).toList(),
            )
          : Center(child: LinearProgressIndicator()),
    );
  }
}
