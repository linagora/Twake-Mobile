import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:twake/pages/search/search_settings.dart';
import 'package:twake/pages/search/search_tabbar/search_tabbar.dart';
import 'package:twake/pages/search/search_tabbar_view.dart';
import 'package:twake/widgets/common/twake_search_text_field.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();

  String _searchTerm = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: searchTabsList.length,
          child: Container(
            margin: const EdgeInsets.only(top: 10, left: 16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: TwakeSearchTextField(
                    height: 40,
                    controller: _searchController,
                    hintText: AppLocalizations.of(context)!.search,
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                  ),
                ),
                SearchTabBar(tabs: searchTabsList),
                Divider(
                  thickness: 1,
                  height: 4,
                  color: Theme.of(context).colorScheme.secondaryContainer,
                ),
                Expanded(
                  child: SearchTabBarView(searchTerm: _searchTerm),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
