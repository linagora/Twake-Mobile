import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/config/dimensions_config.dart' show Dim;
import 'package:twake_mobile/providers/profile_provider.dart';
import 'package:twake_mobile/services/twake_api.dart';
import 'package:twake_mobile/widgets/common/image_avatar.dart';

const double ICON_SIZE_MULTIPLIER = 4.5;

class TwakeDrawer extends StatefulWidget {
  @override
  _TwakeDrawerState createState() => _TwakeDrawerState();
}

class _TwakeDrawerState extends State<TwakeDrawer> {
  bool _companiesHidden = true;
  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileProvider>(context);
    final workspaces = profile.workspaces;
    final companies = profile.companies;
    final user = profile.currentProfile;
    final padding = EdgeInsets.symmetric(
      horizontal: Dim.wm2,
      vertical: Dim.heightMultiplier,
    );
    // final shadow = BoxShadow(
    // offset: Offset(-10, 10),
    // blurRadius: 10,
    // color: Colors.white,
    // );
    return Container(
      width: Dim.widthPercent(80),
      child: Drawer(
        child: Container(
          // padding: EdgeInsets.symmetric(
          // horizontal: DimensionsConfig.widthMultiplier * 3,
          // vertical: DimensionsConfig.heightMultiplier,
          // ),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.only(left: Dim.wm3),
                title: Text(
                  _companiesHidden ? 'Workspaces' : 'Choose company',
                  style: Theme.of(context).textTheme.headline5,
                ), // TODO configure the styles
                trailing: _companiesHidden
                    ? IconButton(
                        color: Colors.black87,
                        onPressed: () {
                          setState(() {
                            _companiesHidden = false;
                          });
                        },
                        iconSize: Dim.tm4(),
                        icon: Icon(
                          Icons.loop,
                        ),
                      )
                    : SizedBox(width: 0, height: 0),
              ),
              Divider(),
              SizedBox(height: Dim.hm2),
              if (_companiesHidden)
                Container(
                  height: Dim.heightPercent(55),
                  child: ListView.builder(
                      itemCount: workspaces.length,
                      itemBuilder: (ctx, i) => InkWell(
                            onTap: () {
                              profile.currentWorkspaceSet(workspaces[i].id);
                              Navigator.of(context).pop();
                            },
                            child: ListTile(
                              leading: ImageAvatar(workspaces[i].logo),
                              title: Text(
                                workspaces[i].name,
                              ),
                              subtitle: Text(profile.selectedCompany.name),
                            ),
                          )),
                ),
              if (!_companiesHidden)
                Container(
                  height: Dim.heightPercent(55),
                  child: ListView.builder(
                      itemCount: companies.length,
                      itemBuilder: (ctx, i) => InkWell(
                            onTap: () {
                              profile.currentCompanySet(companies[i].id);
                              setState(() {
                                _companiesHidden = true;
                              });
                            },
                            child: ListTile(
                              leading: ImageAvatar(companies[i].logo),
                              title: Text(
                                companies[i].name,
                              ),
                              subtitle: Text(
                                '${companies[i].workspaceCount} workspaces',
                              ),
                            ),
                          )),
                ),
              Spacer(),
              Divider(),
              ListTile(
                contentPadding: padding,
                leading: ImageAvatar(user.thumbnail),
                title: Text(
                  '${user.firstName} ${user.lastName}',
                  style: Theme.of(context).textTheme.headline5,
                ), // TODO configure the styles
                trailing: IconButton(
                  onPressed: () {
                    final api = Provider.of<TwakeApi>(context, listen: false);
                    profile.logout(api);
                  },
                  color: Colors.black87,
                  icon: Icon(
                    Icons.logout,
                    size: Dim.tm4(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// TODO outsource the icon buttons
