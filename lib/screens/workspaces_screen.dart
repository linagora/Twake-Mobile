import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/providers/profile_provider.dart';
import 'package:twake_mobile/widgets/workspace/workspace_tile.dart';

class WorkspacesScreen extends StatelessWidget {
  static const String route = '/workspaces';
  @override
  Widget build(BuildContext context) {
    String companyId = ModalRoute.of(context).settings.arguments as String;
    return Consumer<ProfileProvider>(
      builder: (ctx, profile, _) {
        final workspaces = profile.companyWorkspaces(companyId);
        return Scaffold(
          appBar: AppBar(
            title: Text('Your workspaces'),
          ),
          body: ListView(
            children: workspaces.map((w) => WorkspaceTile(w)).toList(),
          ),
        );
      },
    );
  }
}
