import 'package:flutter/material.dart';

class Channels extends StatefulWidget {
  @override
  _ChannelsState createState() => _ChannelsState();
}

class _ChannelsState extends State<Channels> with SingleTickerProviderStateMixin {
  TabController _controller;
  var _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);

    _controller.addListener(() {
      setState(() {
        _selectedTab = _controller.index;
      });
      print("Selected tab: " + _controller.index.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: false,
      appBar: AppBar(
        bottom: TabBar(
          controller: _controller,
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
        controller: _controller,
        children: [
          Container(color: Colors.white60),
          Container(color: Colors.white54),
        ],
      ),
    );
  }
}
