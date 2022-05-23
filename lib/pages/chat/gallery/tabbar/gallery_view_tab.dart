import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/company_files_cubit/company_file_cubit.dart';
import 'package:twake/blocs/gallery_cubit/gallery_cubit.dart';

class GalleryViewTab extends StatelessWidget {
  final TabController tabController;
  final String title;
  final Icon icon;
  final int tabIndex;
  final BorderRadiusGeometry borderRadiusGeometry;

  const GalleryViewTab(
      {Key? key,
      required this.tabController,
      required this.title,
      required this.tabIndex,
      required this.borderRadiusGeometry,
      required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          tabController.animateTo(tabIndex);
          Get.find<CompanyFileCubit>().getCompanyFiles();
          Get.find<GalleryCubit>().tabChange(tabIndex);
        },
        child: BlocBuilder<GalleryCubit, GalleryState>(
          bloc: Get.find<GalleryCubit>(),
          builder: (context, state) {
            int tab = state.selectedTab;
            return AnimatedContainer(
              duration: Duration(milliseconds: 200),
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: borderRadiusGeometry,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  color: //tabController.index == 0
                      tab == tabIndex
                          ? Theme.of(context).colorScheme.surface
                          : Get.isDarkMode
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).primaryColor),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: icon,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.headline1,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
