import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/camera_cubit/camera_cubit.dart';
import 'package:twake/blocs/company_files_cubit/company_file_cubit.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_cubit.dart';
import 'package:twake/blocs/gallery_cubit/gallery_cubit.dart';
import 'package:twake/models/file/local_file.dart';
import 'package:twake/pages/chat/gallery/tabbar/gallery_view_tabbar.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/routing/route_paths.dart';
import 'package:twake/utils/constants.dart';
import 'package:twake/widgets/common/twake_alert_dialog.dart';
import 'package:twake/widgets/common/twake_search_text_field.dart';

class GalleryView extends StatefulWidget {
  const GalleryView({
    Key? key,
  }) : super(key: key);

  @override
  GalleryViewState createState() => GalleryViewState();
}

class GalleryViewState extends State<GalleryView> {
  final _searchController = TextEditingController();
  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    final state = Get.find<CameraCubit>().state;
    if (state.cameraStateStatus == CameraStateStatus.found) {
      final camera = state.availableCameras.first;
      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
      );
      _cameraController!.initialize();
      Get.find<CameraCubit>().emit(CameraState(
        cameraStateStatus: CameraStateStatus.done,
      ));
    }
  }

  @override
  void dispose() {
    if (_cameraController != null) _cameraController!.dispose();
    super.dispose();
  }

  _handleUplodFiles() {
    final state = Get.find<GalleryCubit>().state;

    for (var i = 0; i < state.selectedFilesIndex.length; i++) {
      final LocalFile localFile = LocalFile(
          name: state.assetEntity[state.selectedFilesIndex[i]].title!,
          path: state.fileList[state.selectedFilesIndex[i]].path,
          size: state.fileList[state.selectedFilesIndex[i]].lengthSync(),
          updatedAt: DateTime.now().millisecondsSinceEpoch);

      Get.find<FileUploadCubit>().upload(
        sourceFile: localFile,
        sourceFileUploading: SourceFileUploading.InChat,
      );
    }
    Get.back();
  }

  void displayLimitationAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TwakeAlertDialog(
          header: Text(
            AppLocalizations.of(context)?.reachedLimitFileUploading ?? '',
            style: Theme.of(context).textTheme.headline4!.copyWith(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
            textAlign: TextAlign.center,
          ),
          body: Text(
            AppLocalizations.of(context)?.reachedLimitFileUploadingSub ?? '',
            style: Theme.of(context)
                .textTheme
                .headline6!
                .copyWith(fontSize: 14.0, color: const Color(0xff6d7885)),
            textAlign: TextAlign.center,
          ),
          okActionTitle: AppLocalizations.of(context)?.gotIt ?? '',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.pop(context),
      child: DraggableScrollableSheet(
        initialChildSize: 0.4,
        maxChildSize: 0.8,
        builder: (context, controller) => Container(
          child: DefaultTabController(
            length: 2,
            initialIndex: 0,
            child: Container(
              color: Get.isDarkMode
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).primaryColor,
              child: Column(
                children: [
                  ListView(
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      controller: controller,
                      children: [GalleryViewTabBar()]),
                  Expanded(
                    child: TabBarView(
                      children: [
                        ListView(
                          controller: controller,
                          children: [
                            _galleryStates(
                                cameraController: _cameraController,
                                context: context),
                          ],
                        ),
                        ListView(
                          controller: controller,
                          children: [
                            _fileStates(context: context),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buttonBar(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _galleryDone(
      {required List<Uint8List> assetsList,
      required BuildContext context,
      CameraController? cameraController}) {
    return GridView.builder(
      key: PageStorageKey<String>('galleryDone'),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: assetsList.length + 1,
      itemBuilder: (_, index) {
        return index == 0
            ? BlocBuilder<CameraCubit, CameraState>(
                bloc: Get.find<CameraCubit>(),
                builder: (context, state) {
                  if (state.cameraStateStatus == CameraStateStatus.done) {
                    return _cameraStream(context, cameraController!);
                  } else if (state.cameraStateStatus ==
                          CameraStateStatus.loading ||
                      state.cameraStateStatus == CameraStateStatus.found) {
                    return Center(
                      child: Container(
                        height: 50,
                        width: 50,
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else {
                    return Text('Camera is not available',
                        style: Theme.of(context).textTheme.headline1);
                  }
                },
              )
            : BlocBuilder<GalleryCubit, GalleryState>(
                bloc: Get.find<GalleryCubit>(),
                buildWhen: (_, currentState) =>
                    currentState.galleryStateStatus !=
                    GalleryStateStatus.newSelect,
                builder: (context, state) {
                  if (state.galleryStateStatus == GalleryStateStatus.done ||
                      state.galleryStateStatus ==
                          GalleryStateStatus.newSelect) {
                    return _assetThumbnail(
                        state.assetsList[index - 1], index - 1);
                  } else {
                    return Center(
                      child: Container(
                        height: 50,
                        width: 50,
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                },
              );
      },
    );
  }

  Widget _galleryFailed(
      {required BuildContext context, CameraController? cameraController}) {
    return GridView.builder(
      key: PageStorageKey<String>('galleryFailed'),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      shrinkWrap: true,
      itemCount: 2,
      itemBuilder: (_, index) {
        return index == 0
            ? BlocBuilder<CameraCubit, CameraState>(
                bloc: Get.find<CameraCubit>(),
                builder: (context, state) {
                  if (state.cameraStateStatus == CameraStateStatus.done) {
                    return _cameraStream(context, cameraController!);
                  } else if (state.cameraStateStatus ==
                          CameraStateStatus.loading ||
                      state.cameraStateStatus == CameraStateStatus.found) {
                    return Center(
                      child: Container(
                        height: 50,
                        width: 50,
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Camera is not available',
                          style: Theme.of(context).textTheme.headline1),
                    );
                  }
                },
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Gallety is not available",
                    style: Theme.of(context).textTheme.headline1),
              );
      },
    );
  }

  Widget _galleryLoading({
    CameraController? cameraController,
  }) {
    return GridView.builder(
      key: PageStorageKey<String>('galleryLoading'),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      shrinkWrap: true,
      itemCount: 8,
      itemBuilder: (_, index) {
        return index == 0
            ? BlocBuilder<CameraCubit, CameraState>(
                bloc: Get.find<CameraCubit>(),
                builder: (context, state) {
                  if (state.cameraStateStatus == CameraStateStatus.done) {
                    return _cameraStream(context, cameraController!);
                  } else if (state.cameraStateStatus ==
                          CameraStateStatus.loading ||
                      state.cameraStateStatus == CameraStateStatus.found) {
                    return Center(
                      child: Container(
                        height: 50,
                        width: 50,
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Camera is not available',
                          style: Theme.of(context).textTheme.headline1),
                    );
                  }
                },
              )
            : Center(
                child: Container(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(),
                ),
              );
      },
    );
  }

  Widget _fileStates({required BuildContext context}) {
    return Container(
      color: Get.isDarkMode
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TwakeSearchTextField(
              height: 40,
              controller: _searchController,
              hintText: AppLocalizations.of(context)!.search,
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.add,
                  size: 32,
                  color: Theme.of(context).colorScheme.surface,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "Add local storage file",
                    style: Theme.of(context).textTheme.headline4,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              "Twake files",
              style: Theme.of(context)
                  .textTheme
                  .headline1!
                  .copyWith(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            BlocBuilder<CompanyFileCubit, CompanyFileState>(
              bloc: Get.find<CompanyFileCubit>(),
              builder: (context, state) {
                if (state.companyFileStatus == CompanyFileStatus.done) {
                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        return Container(
                          height: 50,
                          width: 50,
                          child: Row(
                            children: [
                              Icon(
                                Icons.folder,
                                size: 40,
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Dummy file",
                                  style: Theme.of(context).textTheme.headline4,
                                ),
                              ),
                            ],
                          ),
                        );
                      });
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _galleryStates(
      {required BuildContext context, CameraController? cameraController}) {
    return Stack(
      children: [
        Container(
          color: Get.isDarkMode
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).primaryColor,
          child: BlocBuilder<GalleryCubit, GalleryState>(
            buildWhen: (_, currentState) =>
                currentState.galleryStateStatus != GalleryStateStatus.newSelect,
            bloc: Get.find<GalleryCubit>(),
            builder: (context, state) {
              if (state.galleryStateStatus == GalleryStateStatus.done) {
                return _galleryDone(
                    assetsList: state.assetsList,
                    cameraController: cameraController,
                    context: context);
              } else if (state.galleryStateStatus ==
                  GalleryStateStatus.loading) {
                return _galleryLoading(cameraController: cameraController);
              } else if (state.galleryStateStatus ==
                  GalleryStateStatus.newSelect) {
                return _galleryDone(
                    assetsList: state.assetsList,
                    cameraController: cameraController,
                    context: context);
              } else {
                return _galleryFailed(
                    cameraController: cameraController, context: context);
              }
            },
          ),
        ),
        //    _buttonBar(context),
      ],
    );
  }

  Widget _cameraStream(BuildContext context, CameraController _controller) {
    return GestureDetector(
      onTap: () => push(
        RoutePaths.cameraView.path,
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            child: BlocBuilder<CameraCubit, CameraState>(
              bloc: Get.find<CameraCubit>(),
              builder: (context, state) {
                if (state.cameraStateStatus == CameraStateStatus.done) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      CameraPreview(_controller),
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 40,
                      )
                    ],
                  );
                } else
                  return Container(
                    child: Text(
                      'Camera is not here lol',
                      style: Theme.of(context).textTheme.headline1,
                    ),
                  );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buttonBar(BuildContext context) {
    return BlocBuilder<GalleryCubit, GalleryState>(
      bloc: Get.find<GalleryCubit>(),
      /*buildWhen: (_, currentState) =>
                        currentState.galleryStateStatus ==
                        GalleryStateStatus.newSelect,,*/
      builder: (context, state) {
        return state.selectedFilesIndex.length != 0
            ? Container(
                color: Get.isDarkMode
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 12, right: 12, bottom: 12, top: 12),
                  child: TextButton(
                    onPressed: () => _handleUplodFiles(),
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
                            child: Text("Attach",
                                style: Theme.of(context).textTheme.headline1),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: Text('${state.selectedFilesIndex.length}'),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : SizedBox.shrink();
      },
    );
  }

  Widget _assetThumbnail(Uint8List data, int index) {
    return GestureDetector(
      onTap: () async {
        final fileLen =
            Get.find<GalleryCubit>().state.selectedFilesIndex.length;
        if (fileLen == MAX_FILE_UPLOADING) {
          displayLimitationAlertDialog();
          return;
        }
        Get.find<GalleryCubit>().addFileIndex(index); // _handlePickFile(index);
      },
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: /*Image.memory(
            data,
            fit: BoxFit.fill, ),*/
              Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(
                data,
                fit: BoxFit.fill,
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: BlocBuilder<GalleryCubit, GalleryState>(
                    bloc: Get.find<GalleryCubit>(),
                    buildWhen: (_, currentState) =>
                        currentState.galleryStateStatus ==
                        GalleryStateStatus.newSelect,
                    builder: (context, state) {
                      return state.selectedFilesIndex.contains(index)
                          ? Stack(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 26,
                                  color: Get.isDarkMode
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primaryContainer
                                      : Theme.of(context).primaryColor,
                                ),
                              ],
                            )
                          : Icon(
                              Icons.circle_outlined,
                              size: 26,
                              color: Get.isDarkMode
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                  : Theme.of(context).primaryColor,
                            );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
