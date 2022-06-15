import 'package:flutter/material.dart';
import 'package:twake/pages/search/search_tabbar_view/search_contacts_view.dart';

class SearchTabBarView extends StatelessWidget {
  final String searchTerm;

  const SearchTabBarView({Key? key, required this.searchTerm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        Text('in development'),
        Text('in development'),
        Text('in development'),
        Text('in development'),
        SearchContactsView(),
      ],
    );
  }
}
