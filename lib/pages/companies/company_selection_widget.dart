import 'package:flutter/material.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/pages/workspaces_management/add_workspace_tile.dart';
import 'package:twake/pages/workspaces_management/workspace_title.dart';

class CompanySelectionWidget extends StatelessWidget {
  const CompanySelectionWidget() : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          AddWorkspaceTile(title: 'Add a new company'),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              itemCount: 20,
              itemBuilder: (context, index) {
                return WorkspaceTile(
                  image: imagePathCancel,
                  title: '$index',
                  selected: index == 1,
                  subtitle: '',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
