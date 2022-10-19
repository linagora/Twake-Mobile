import 'package:flutter/material.dart';
import 'package:twake/pages/search/search_settings.dart';
import 'package:twake/pages/search/search_tabbar/search_tabbar_item.dart';

class SearchTabBar extends StatelessWidget {
  final List<SearchTab> tabs;

  const SearchTabBar({Key? key, required this.tabs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TabBar(
        tabs: tabs.map((e) => SearchTabBarItem(tab: e)).toList(),
        labelPadding: EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.only(left: 16),
        isScrollable: true,
        indicatorColor: Theme.of(context).colorScheme.surface,
        unselectedLabelColor: Theme.of(context).colorScheme.secondary,
        unselectedLabelStyle: Theme.of(context).textTheme.headline1!.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
        labelStyle: Theme.of(context).textTheme.headline3!.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
