import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/config/dimensions_config.dart';
import 'package:twake_mobile/providers/profile_provider.dart';
import 'package:twake_mobile/widgets/common/image_avatar.dart';

import 'package:twake_mobile/widgets/workspace/workspace_tile.dart';

const double ICON_SIZE_MULTIPLIER = 4.5;

class TwakeDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileProvider>(context);
    final workspaces = profile.companyWorkspaces(profile.companies[0].id);
    final user = profile.currentProfile;
    final padding = EdgeInsets.symmetric(
      horizontal: DimensionsConfig.widthMultiplier * 3,
      vertical: DimensionsConfig.heightMultiplier,
    );
    final shadow = BoxShadow(
      offset: Offset(-10, 10),
      blurRadius: 10,
      color: Color.fromRGBO(0, 21, 53, 1),
    );
    return Container(
      width: DimensionsConfig.widthMultiplier * 80,
      child: Drawer(
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(15, 29, 54, 1),
          ), // TODO decorate the container
          // padding: EdgeInsets.symmetric(
          // horizontal: DimensionsConfig.widthMultiplier * 3,
          // vertical: DimensionsConfig.heightMultiplier,
          // ),
          child: Column(
            children: [
              Container(
                padding: padding,
                decoration: BoxDecoration(boxShadow: [shadow]),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ImageAvatar(profile.companies[0].logo),
                      SizedBox(
                        width: DimensionsConfig.widthMultiplier * 2,
                      ),
                      Text(
                        profile.companies[0].name,
                        style: Theme.of(context).textTheme.headline5,
                      ), // TODO configure the styles
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () {},
                            iconSize: DimensionsConfig.textMultiplier *
                                ICON_SIZE_MULTIPLIER,
                            icon: Icon(
                              Icons.settings_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ]),
              ),
              SizedBox(height: DimensionsConfig.heightMultiplier * 3),
              Padding(
                padding: padding,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Workspaces',
                      style: Theme.of(context).textTheme.headline5,
                    ), // TODO configure the styles
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () {},
                          iconSize: DimensionsConfig.textMultiplier *
                              ICON_SIZE_MULTIPLIER,
                          icon: Icon(
                            Icons.add_sharp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: DimensionsConfig.heightMultiplier * 2),
              Container(
                height: 50 * DimensionsConfig.heightMultiplier,
                padding: padding,
                child: ListView.separated(
                    separatorBuilder: (ctx, i) => Divider(),
                    itemCount: workspaces.length,
                    itemBuilder: (ctx, i) => Row(
                          children: [
                            ImageAvatar(workspaces[i].logo),
                            SizedBox(
                              width: DimensionsConfig.widthMultiplier * 2,
                            ),
                            Text(
                              workspaces[i].name,
                              style: Theme.of(context).textTheme.headline5,
                            ),
                          ],
                        )),
              ),
              Spacer(),
              Container(
                padding: padding,
                decoration: BoxDecoration(boxShadow: [shadow]),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ImageAvatar(user.thumbnail),
                      SizedBox(
                        width: DimensionsConfig.widthMultiplier * 2,
                      ),
                      Text(
                        '${user.firstName} ${user.lastName}',
                        style: Theme.of(context).textTheme.headline5,
                      ), // TODO configure the styles
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.login_outlined,
                              size: DimensionsConfig.textMultiplier *
                                  ICON_SIZE_MULTIPLIER,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// TODO outsource the icon buttons
