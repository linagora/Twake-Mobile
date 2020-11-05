import 'package:flutter/material.dart';
import 'package:twake_mobile/config/dimensions_config.dart';
import 'package:twake_mobile/models/company.dart';

class CompanyTile extends StatelessWidget {
  final Company company;
  CompanyTile(this.company);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Card(
        elevation: 1,
        child: ListTile(
          leading: CircleAvatar(
            radius: 5 * DimensionsConfig.widthMultiplier,
            backgroundImage: company.logo.isNotEmpty
                ? NetworkImage(
                    company.logo,
                    headers: {
                      'Content-Type': 'image/jpg',
                      'Accept':
                          'image/jpg, image/png, image/jpeg, application/octet-stream'
                    },
                  )
                : AssetImage('empty-image.png'),
          ),
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
