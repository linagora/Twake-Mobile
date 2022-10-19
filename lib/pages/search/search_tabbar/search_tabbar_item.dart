import 'package:flutter/material.dart';
import 'package:twake/pages/search/search_settings.dart';

class SearchTabBarItem extends StatelessWidget {
  final SearchTab tab;

  const SearchTabBarItem({Key? key, required this.tab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tab(child: Text(tab.name));
  }
}
