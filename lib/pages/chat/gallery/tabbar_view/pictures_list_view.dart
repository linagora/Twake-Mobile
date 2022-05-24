import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/camera_cubit/camera_cubit.dart';
import 'package:twake/blocs/gallery_cubit/gallery_cubit.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/routing/route_paths.dart';
import 'package:twake/utils/constants.dart';
import 'package:twake/widgets/common/twake_alert_dialog.dart';

class PicturesListView extends StatefulWidget {
  final ScrollController scrollController;

  const PicturesListView({Key? key, required this.scrollController})
      : super(key: key);

  @override
  State<PicturesListView> createState() => _PicturesListViewState();
}

class _PicturesListViewState extends State<PicturesListView>
    with AutomaticKeepAliveClientMixin<PicturesListView> {
  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    final state = Get.find<CameraCubit>().state;
    if (state.cameraStateStatus == CameraStateStatus.found) {
      final camera = state.availableCameras.first;
      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
      );
      _cameraController!.initialize();
      Get.find<CameraCubit>().cameraDone();
    }
  }

  @override
  void dispose() {
    if (_cameraController != null) _cameraController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListView(
      controller: widget.scrollController,
      children: [
        Stack(
          children: [
            Container(
              color: Get.isDarkMode
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).primaryColor,
              child: BlocBuilder<GalleryCubit, GalleryState>(
                buildWhen: (_, currentState) =>
                    currentState.galleryStateStatus !=
                    GalleryStateStatus.newSelect,
                bloc: Get.find<GalleryCubit>(),
                builder: (context, state) {
                  if (state.galleryStateStatus == GalleryStateStatus.done) {
                    return _galleryDone(
                        assetsList: state.assetsList,
                        cameraController: _cameraController,
                        context: context);
                  } else if (state.galleryStateStatus ==
                      GalleryStateStatus.loading) {
                    return _galleryLoading(cameraController: _cameraController);
                  } else if (state.galleryStateStatus ==
                      GalleryStateStatus.newSelect) {
                    return _galleryDone(
                        assetsList: state.assetsList,
                        cameraController: _cameraController,
                        context: context);
                  } else {
                    return _galleryFailed(
                        cameraController: _cameraController, context: context);
                  }
                },
              ),
            ),
            //    _buttonBar(context),
          ],
        )
      ],
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
                        state.assetsList[index - 1], index - 1, context);
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

  Widget _cameraStream(BuildContext context, CameraController _controller) {
    return GestureDetector(
      onTap: () {
        push(RoutePaths.cameraView.path, arguments: _controller);
      },
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

  Widget _assetThumbnail(Uint8List data, int index, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final fileLen =
            Get.find<GalleryCubit>().state.selectedFilesIndex.length;
        if (fileLen == MAX_FILE_UPLOADING) {
          displayLimitationAlertDialog(context);
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

  void displayLimitationAlertDialog(BuildContext context) {
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
  bool get wantKeepAlive => true;
}
