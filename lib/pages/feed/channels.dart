import 'package:flutter/material.dart';

class Channels extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(
                  text: 'Channels',
                ),
                Tab(
                  text: 'Direct chats',
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
