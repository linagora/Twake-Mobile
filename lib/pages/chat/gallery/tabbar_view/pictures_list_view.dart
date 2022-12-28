import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:twake/blocs/camera_cubit/camera_cubit.dart';
import 'package:twake/blocs/gallery_cubit/gallery_cubit.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/routing/route_paths.dart';
import 'package:twake/utils/constants.dart';
import 'package:twake/widgets/common/button_text_builder.dart';
import 'package:twake/widgets/common/twake_alert_dialog.dart';

class PicturesListView extends StatefulWidget {
  final ScrollController scrollController;

  const PicturesListView({Key? key, required this.scrollController})
      : super(key: key);

  @override
  State<PicturesListView> createState() => _PicturesListViewState();
}

class _PicturesListViewState extends State<PicturesListView>
    with
        AutomaticKeepAliveClientMixin<PicturesListView>,
        WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _cameraControllerInitInitialize = false;

  @override
  void initState() {
    super.initState();

    widget.scrollController.addListener(() {
      if (widget.scrollController.positions.last.atEdge) {
        if (widget.scrollController.positions.last.pixels != 0) {
          Get.find<GalleryCubit>().getGalleryAssets(isGettingNewAssets: true);
        }
      }
    });

    Get.find<GalleryCubit>().tabChange(0);

    final state = Get.find<CameraCubit>().state;
    if (state.cameraStateStatus == CameraStateStatus.found ||
        state.cameraStateStatus == CameraStateStatus.done) {
      _cameraController = CameraController(
          state.availableCameras.first, ResolutionPreset.high,
          enableAudio: false);
      _cameraControllerInitInitialize = true;
      _initCamera();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // it is necessary otherwise the controller falls off
    if (state == AppLifecycleState.inactive) {
      _cameraController!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      final cameraCubitState = Get.find<CameraCubit>().state;
      if (cameraCubitState.cameraStateStatus == CameraStateStatus.found ||
          cameraCubitState.cameraStateStatus == CameraStateStatus.done) {
        _cameraController = CameraController(
            cameraCubitState.availableCameras.first, ResolutionPreset.high,
            enableAudio: false);
        _cameraController!.initialize();
      }
    }
  }

  @override
  void dispose() {
    if (_cameraController != null) _cameraController!.dispose();
    super.dispose();
  }

  void _initCamera() async {
    await _cameraController!.initialize();
    setState(() {});
    Get.find<CameraCubit>().cameraDone();
  }

  void _prepareCamera(CameraState state) {
    _cameraController = CameraController(
        state.availableCameras.first, ResolutionPreset.high,
        enableAudio: false);
    _initCamera();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListView(
      controller: widget.scrollController,
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
                    isAddingDummyAssets: state.isAddingDummyAssets,
                    cameraController: _cameraController,
                    context: context);
              } else if (state.galleryStateStatus ==
                  GalleryStateStatus.loading) {
                return _galleryLoading(cameraController: _cameraController);
              } else if (state.galleryStateStatus ==
                  GalleryStateStatus.newSelect) {
                return _galleryDone(
                    assetsList: state.assetsList,
                    isAddingDummyAssets: state.isAddingDummyAssets,
                    cameraController: _cameraController,
                    context: context);
              } else {
                return _galleryFailed(context: context);
              }
            },
          ),
        )
      ],
    );
  }

  Widget _galleryDone(
      {required List<Uint8List> assetsList,
      required BuildContext context,
      required bool isAddingDummyAssets,
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
      itemCount: isAddingDummyAssets == false
          ? assetsList.length + 1
          : assetsList.length + 1 + assetsIterationStep,
      itemBuilder: (_, index) {
        return index == 0
            ? _cameraStream(context, cameraController)
            : index < (assetsList.length + 1)
                ? BlocBuilder<GalleryCubit, GalleryState>(
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
                            child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                        );
                      }
                    },
                  )
                : Center(
                    child: Container(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  );
      },
    );
  }

  Widget _galleryFailed({required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        children: [
          Image.asset(imageStop_x2),
          SizedBox(
            height: 16,
          ),
          Text(AppLocalizations.of(context)!.galleryImagesUnavailable,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headline1!
                  .copyWith(fontSize: 17, fontWeight: FontWeight.w400)),
          SizedBox(
            height: 16,
          ),
          FractionallySizedBox(
            widthFactor: 0.6,
            child: ButtonTextBuilder(Key('button_go_to_settings'),
                    onButtonClick: () => openAppSettings(),
                    backgroundColor: Theme.of(context).colorScheme.surface)
                .setText(AppLocalizations.of(context)!.goToSettings)
                .setHeight(44)
                .setBorderRadius(BorderRadius.all(Radius.circular(14)))
                .build(),
          )
        ],
      ),
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
            ? _cameraStream(context, cameraController)
            : Center(
                child: Container(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.secondary),
                ),
              );
      },
    );
  }

  Widget _cameraStream(BuildContext context, CameraController? _controller) {
    final state = Get.find<CameraCubit>().state;
    if (_controller == null &&
        state.cameraStateStatus == CameraStateStatus.found) {
      _prepareCamera(state);
      return Center(
        child: Container(
          height: 50,
          width: 50,
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      );
    }

    return BlocListener<CameraCubit, CameraState>(
      bloc: Get.find<CameraCubit>(),
      listener: (context, state) {
        if (state.cameraStateStatus == CameraStateStatus.found &&
            !_cameraControllerInitInitialize) {
          _prepareCamera(state);
        }
      },
      child: _controller == null || !_controller.value.isInitialized
          ? Container(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'The camera is not available',
                    style: Theme.of(context)
                        .textTheme
                        .headline1!
                        .copyWith(fontSize: 14),
                  ),
                ),
              ),
            )
          : GestureDetector(
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
                        } else if (state.cameraStateStatus ==
                            CameraStateStatus.loading) {
                          return Center(
                            child: Container(
                              height: 50,
                              width: 50,
                              child: CircularProgressIndicator(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                          );
                        } else
                          return Container(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'The camera is not available',
                                  style: Theme.of(context).textTheme.headline1,
                                ),
                              ),
                            ),
                          );
                      },
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _assetThumbnail(Uint8List data, int index, BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        Get.find<GalleryCubit>().addFileIndex(index);
        final fileLen =
            Get.find<GalleryCubit>().state.selectedFilesIndex.length;
        if (fileLen == MAX_FILE_UPLOADING) {
          displayLimitationAlertDialog(context);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(
                data,
                fit: BoxFit.cover,
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
                      return Stack(
                        children: [
                          state.selectedFilesIndex.contains(index)
                              ? Positioned(
                                  right: 5,
                                  bottom: 5,
                                  child: Container(
                                    height: 22,
                                    width: 22,
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 1, top: 1),
                                        child: Text(
                                            "${state.selectedFilesIndex.indexOf(index) + 1}",
                                            style: Get.isDarkMode
                                                ? Theme.of(context)
                                                    .textTheme
                                                    .headline1!
                                                    .copyWith(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500)
                                                : Theme.of(context)
                                                    .textTheme
                                                    .bodyText1!
                                                    .copyWith(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox.shrink(),
                          Icon(
                            Icons.circle_outlined,
                            size: 30,
                            color: Get.isDarkMode
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(context).primaryColor,
                          ),
                        ],
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
