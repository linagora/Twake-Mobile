import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/providers/init_provider.dart';
import 'package:twake_mobile/providers/workspaces_provider.dart';

class WorkspacesScreen extends StatelessWidget {
  static const String route = '/workspaces';
  @override
  Widget build(BuildContext context) {
    final init = Provider.of<InitProvider>(context);
    String companyId = ModalRoute.of(context).settings.arguments as String;
    return ChangeNotifierProvider(
      create: (ctx) => WorkspacesProvider()
        ..loadWorkspaces(init.companyWorkspaces(companyId)),
      child: Consumer<WorkspacesProvider>(
        builder: (ctx, wsp, _) {
          final workspaces = wsp.items;
          return Scaffold(
            appBar: AppBar(
              title: Text('Your workspaces'),
            ),
            body: ListView(
                children: workspaces.map((w) => Text(w.name)).toList()),
          );
        },
      ),
    );
  }
}
