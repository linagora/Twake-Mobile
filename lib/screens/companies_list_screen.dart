import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/providers/profile_provider.dart';
import 'package:twake_mobile/widgets/company/company_tile.dart';
import 'package:twake_mobile/widgets/drawer/twake_drawer.dart';

class CompaniesListScreen extends StatelessWidget {
  static const route = '/companies/list';
  @override
  Widget build(BuildContext context) {
    print('DEBUG: building companies screen');
    final profile = Provider.of<ProfileProvider>(context);
    return SafeArea(
      child: Scaffold(
        drawer: TwakeDrawer(),
        appBar: AppBar(
          title: Text('Your companies'),
        ),
        body: profile.loaded
            ? ListView(
                children: profile.companies.map((c) => CompanyTile(c)).toList(),
              )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
