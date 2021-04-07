import 'package:flutter/material.dart';

class TabBarController extends StatelessWidget {
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
              Container(color: Colors.red),
              Container(color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }
}
