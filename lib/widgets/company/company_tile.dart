import 'package:flutter/material.dart';
import 'package:twake_mobile/models/company.dart';
import 'package:twake_mobile/screens/workspaces_screen.dart';
import 'package:twake_mobile/widgets/common/image_avatar.dart';

class CompanyTile extends StatelessWidget {
  final Company company;
  CompanyTile(this.company);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context)
            .pushNamed(WorkspacesScreen.route, arguments: company.id);
      },
      child: Card(
        elevation: 1,
        child: ListTile(
          leading: ImageAvatar(company.logo),
          title: Text(
            company.name,
            style: Theme.of(context).textTheme.headline3,
          ),
          subtitle: Text(
            '${company.workspaceCount} workspaces',
            style: Theme.of(context).textTheme.subtitle2,
          ),
          trailing: Icon(Icons.more_vert),
        ),
      ),
    );
  }
}
