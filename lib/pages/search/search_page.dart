import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Widget _buildTabBar() {
    return Text('here tabbar');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: 1,
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            child: Column(
              children: [
                _buildTabBar(),
                Divider(
                  thickness: 1,
                  height: 4,
                  color: Theme.of(context).colorScheme.secondaryContainer,
                ),
                Expanded(
                  child: TabBarView(
                    children: [Text('here tab view')],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
