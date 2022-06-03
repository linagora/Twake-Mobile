import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/pages/chat/gallery/gallery_button_bar.dart';
import 'package:twake/pages/chat/gallery/tabbar/gallery_view_tabbar.dart';
import 'package:twake/pages/chat/gallery/tabbar_view/gallery_tabbar_view.dart';

class GalleryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.pop(context),
      child: DraggableScrollableSheet(
        initialChildSize: 0.4,
        maxChildSize: 0.85,
        builder: (context, controller) => Container(
          child: DefaultTabController(
            length: 2,
            initialIndex: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                color: Get.isDarkMode
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).primaryColor,
              ),
              child: Column(
                children: [
                  ListView(
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      controller: controller,
                      children: [GalleryViewTabBar()]),
                  GalleryTabBarView(scrollController: controller),
                  GalleryButtonBar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
