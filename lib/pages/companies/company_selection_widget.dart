import 'package:flutter/material.dart';
import 'package:twake/pages/workspaces_management/workspace_title.dart';
import 'package:twake/pages/workspaces_management/workspaces_management.dart';

class CompanySelectionWidget extends StatelessWidget {
  const CompanySelectionWidget() : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          AddWorkspaceTile(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              itemCount: 20,
              itemBuilder: (context, index) {
                return WorkspaceTile(
                  image: 'assets/images/cancel.png',
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
