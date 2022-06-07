import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_cubit.dart';
import 'package:twake/blocs/gallery_cubit/gallery_cubit.dart';
import 'package:twake/models/file/local_file.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GalleryButtonBar extends StatelessWidget {
  _handleUploadFiles() {
    final state = Get.find<GalleryCubit>().state;

    for (var i = 0; i < state.selectedFilesIndex.length; i++) {
      final LocalFile localFile = LocalFile(
          name: state.assetEntity[state.selectedFilesIndex[i]].title!,
          path: state.fileList[state.selectedFilesIndex[i]].path,
          thumbnail: state.assetsList[state.selectedFilesIndex[i]],
          size: state.fileList[state.selectedFilesIndex[i]].lengthSync(),
          updatedAt: DateTime.now().millisecondsSinceEpoch);

      Get.find<FileUploadCubit>().upload(
        sourceFile: localFile,
        sourceFileUploading: SourceFileUploading.InChat,
      );
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GalleryCubit, GalleryState>(
      bloc: Get.find<GalleryCubit>(),
      /*buildWhen: (_, currentState) =>
                        currentState.galleryStateStatus ==
                        GalleryStateStatus.newSelect,,*/
      builder: (context, state) {
        return state.selectedTab == 0
            ? state.selectedFilesIndex.length != 0
                ? Container(
                    color: Get.isDarkMode
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).primaryColor,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 12, right: 12, bottom: 12, top: 12),
                      child: TextButton(
                        onPressed: () => _handleUploadFiles(),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    AppLocalizations.of(context)!.attach,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline1!
                                        .copyWith(fontSize: 16)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor:
                                      Theme.of(context).iconTheme.color,
                                  child: Text(
                                      '${state.selectedFilesIndex.length}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4!
                                          .copyWith(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : SizedBox.shrink()
            : SizedBox.shrink();
      },
    );
  }
}
