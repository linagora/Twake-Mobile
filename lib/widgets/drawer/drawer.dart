import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/config/dimensions_config.dart';
import 'package:twake_mobile/providers/profile_provider.dart';

import 'package:twake_mobile/widgets/workspace/workspace_tile.dart';

class TwakeDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileProvider>(context);
    final workspaces = profile.companyWorkspaces(profile.companies[0].id);
    return Container(
      width: DimensionsConfig.widthMultiplier * 70,
      decoration: BoxDecoration(), // TODO decorate the container
      child: Drawer(
        child: Container(
          padding: EdgeInsets.all(2 * DimensionsConfig.widthMultiplier),
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(12, 28, 54, 1),
            ),
          ]),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                  profile.companies[0].name,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ), // TODO configure the styles
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.settings,
                    color: Colors.white,
                  ),
                ),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                  'Workspaces',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ), // TODO configure the styles
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ]),
              Container(
                height: 70 * DimensionsConfig.heightMultiplier,
                child: ListView(
                  children: workspaces.map((w) => WorkspaceTile(w)).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
