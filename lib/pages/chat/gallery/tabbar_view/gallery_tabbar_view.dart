import 'package:flutter/material.dart';
import 'package:twake/pages/chat/gallery/tabbar_view/files_list_view.dart';
import 'package:twake/pages/chat/gallery/tabbar_view/pictures_list_view.dart';

class GalleryTabBarView extends StatelessWidget {
  final ScrollController scrollController;

  const GalleryTabBarView({Key? key, required this.scrollController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TabBarView(
        children: [
          PicturesListView(
            scrollController: scrollController,
          ),
          FilesListView(scrollController: scrollController),
        ],
      ),
    );
  }
}
