import 'package:flutter/material.dart';

class SearchTabBarView extends StatelessWidget {
  final String searchTerm;

  const SearchTabBarView({Key? key, required this.searchTerm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        Text('here tab view'),
        Text('here tab view'),
        Text('here tab view'),
        Text('here tab view'),
        Text('here tab view')
      ],
    );
  }
}
