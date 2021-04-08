import 'package:flutter/material.dart';

class Channels extends StatefulWidget {
  @override
  _ChannelsState createState() => _ChannelsState();
}

class _ChannelsState extends State<Channels> {
  var _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          primary: false,
          appBar: AppBar(
            bottom: TabBar(
              onTap: (index) {
                setState(() {
                  _selectedTab = index;
                });
              },
              indicatorPadding: _selectedTab == 0
                  ? EdgeInsets.only(left: 30.0)
                  : EdgeInsets.only(right: 30.0),
              indicatorColor: Color(0xff004dff),
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                Container(
                  width: 130.0,
                  padding: const EdgeInsets.only(left: 30.0),
                  child: Tab(
                    text: 'Channels',
                  ),
                ),
                Container(
                  width: 130.0,
                  padding: const EdgeInsets.only(right: 30.0),
                  child: Tab(
                    text: 'Direct chats',
                  ),
                ),
              ],
            ),
            title: Text('Tabs Demo'),
          ),
          body: TabBarView(
            children: [
              Container(color: Colors.white60),
              Container(color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}
