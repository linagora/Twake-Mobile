import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/gallery_cubit/gallery_cubit.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/pages/chat/gallery/tabbar/gallery_view_tab.dart';

class GalleryViewTabBar extends StatelessWidget {
  Widget _buildHeader(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Get.find<GalleryCubit>().clearSelection(),
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
              child: Text(AppLocalizations.of(context)!.clear,
                  style: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(fontWeight: FontWeight.w400, fontSize: 17)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              AppLocalizations.of(context)!.gallery,
              style: Theme.of(context).textTheme.headline1!.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 21,
                  ),
            ),
          ),
          GestureDetector(
            onTap: () => Get.back(),
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
              child: Image.asset(
                imageClose,
                width: 24.0,
                height: 24.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TabController tabController = DefaultTabController.of(context)!;

    return Container(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildHeader(context),
            SizedBox(
              height: 15,
            ),
            SizedBox(
              height: 38,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GalleryViewTab(
                      tabController: tabController,
                      title: AppLocalizations.of(context)!.image,
                      tabIndex: 0,
                      borderRadiusGeometry: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      icon: Icon(Icons.image)),
                  GalleryViewTab(
                      tabController: tabController,
                      title: AppLocalizations.of(context)!.file,
                      tabIndex: 1,
                      borderRadiusGeometry: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      icon: Icon(CupertinoIcons.doc)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
