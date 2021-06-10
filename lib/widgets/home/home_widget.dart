import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/widgets/common/rounded_image.dart';
import 'package:twake/widgets/home/home_channel_list_widget.dart';

import 'home_direct_list_widget.dart';

class HomeWidget extends StatelessWidget {
  const HomeWidget() : super();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            toolbarHeight: kToolbarHeight + 80,
            bottom: TabBar(
              tabs: [
                Tab(text: 'Channels'),
                Tab(text: 'Chats',),
              ],
            ),
            title: _buildHeader(),
          ),
          body: TabBarView(
            children: [
              HomeChannelListWidget(),
              HomeDirectListWidget(),
            ],
          )),
    );
  }

  Widget _buildHeader() {
    return Container(
      child: Column(
        children: [
          Container(
            height: 36,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: RoundedImage(
                    width: 36,
                    height: 36,
                  ),
                ),
                Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      imageTwakeHomeLogo,
                      width: 63,
                      height: 15,
                    ))
              ],
            ),
          ),
          Divider(
            color: Colors.white,
            height: 12,
          ),
          HomeSearchTextField(),
        ],
      ),
    );
  }
}

class HomeSearchTextField extends StatelessWidget {
  const HomeSearchTextField() : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      child: TextField(
        style: TextStyle(
          color: Colors.black,
          fontSize: 17,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        decoration: new InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            prefixIcon: Icon(Icons.search),
            border: new OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(10.0),
              ),
              borderSide: BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
            filled: true,
            hintStyle: TextStyle(
              color: Color(0xff8e8e93),
              fontSize: 17,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
            hintText: "Search",
            fillColor: Color(0xfff9f8f9)),
      ),
    );
  }
}
