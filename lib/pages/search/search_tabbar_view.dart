import 'package:flutter/material.dart';
import 'package:twake/pages/search/search_tabbar_view/search_all_view.dart';
import 'package:twake/pages/search/search_tabbar_view/search_chats_view.dart';
import 'package:twake/pages/search/search_tabbar_view/search_files_view.dart';
import 'package:twake/pages/search/search_tabbar_view/search_media_view.dart';
import 'package:twake/pages/search/search_tabbar_view/search_messages_view.dart';

class SearchTabBarView extends StatelessWidget {
  const SearchTabBarView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        SearchAllView(),
        SearchMessagesView(),
        SearchMediaView(),
        SearchFilesView(),
        SearchChatsView(),
        // SearchContactsView(),
      ],
    );
  }
}
