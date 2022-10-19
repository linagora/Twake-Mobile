import 'package:flutter/material.dart';

import 'package:twake/pages/search/search_tabbar_view/search_chats_view.dart';
import 'package:twake/pages/search/search_tabbar_view/search_files_view.dart';
import 'package:twake/pages/search/search_tabbar_view/search_media_view.dart';
import 'package:twake/pages/search/search_tabbar_view/search_messages_view.dart';

class SearchAllView extends StatefulWidget {
  @override
  State<SearchAllView> createState() => _SearchAllViewState();
}

class _SearchAllViewState extends State<SearchAllView>
    with AutomaticKeepAliveClientMixin<SearchAllView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListView(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      children: [
        SearchChatsView(isAllTab: true),
        SearchMediaView(isAllTab: true),
        SearchFilesView(isAllTab: true),
        SearchMessagesView(isAllTab: true),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
