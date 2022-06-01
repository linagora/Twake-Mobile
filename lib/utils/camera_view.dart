import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/camera_cubit/camera_cubit.dart';
import 'package:twake/config/dimensions_config.dart';

import 'package:twake/routing/app_router.dart';
import 'package:twake/routing/route_paths.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/utils/utilities.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CameraView extends StatefulWidget {
  const CameraView({Key? key}) : super(key: key);

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  late CameraController _cameraController;

  @override
  void initState() {
    super.initState();
    if (Get.arguments.runtimeType == CameraController) {
      _cameraController = Get.arguments;
      Get.find<CameraCubit>().cameraDone();
    } else {
      Get.find<CameraCubit>().cameraFailed();
    }
  }

  @override
  void dispose() {
    //   _cameraController.dispose();
    super.dispose();
  }

  void _toggleCameraLens(List<CameraDescription> availableCameras) {
    if (availableCameras.length == 1) return;
    // get current lens direction
    final lensDirection = _cameraController.description.lensDirection;
    CameraDescription newDescription;
    if (lensDirection == CameraLensDirection.front) {
      newDescription = availableCameras.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.back);
    } else {
      newDescription = availableCameras.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.front);
    }

    if (newDescription != null) _initCamera(newDescription);
  }

  Future<void> _initCamera(CameraDescription description) async {
    _cameraController =
        CameraController(description, ResolutionPreset.max, enableAudio: true);
    try {
      await _cameraController.initialize();
      Get.find<CameraCubit>().cameraLensSwitch();
    } catch (e) {
      Logger()
          .log(Level.error, 'Error occured during camera lens switching :\n$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: Dim.maxScreenHeight,
        width: Dim.maxScreenWidth,
        color: Colors.black,
        child: SafeArea(
          child: Column(
            children: [
              _cameraView(),
              _bottomTitle(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cameraView() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(22),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _cameraPreview(),
              Align(alignment: Alignment.topCenter, child: _fleshlight()),
              Align(alignment: Alignment.bottomCenter, child: _controlPanel()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cameraPreview() {
    return BlocBuilder<CameraCubit, CameraState>(
      bloc: Get.find<CameraCubit>(),
      builder: (context, state) {
        return CameraPreview(_cameraController);
      },
    );
  }

  Widget _fleshlight() {
    return Container(
      height: 60,
      color: Colors.black.withOpacity(0.3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Padding(
              padding: EdgeInsets.all(Dim.widthPercent(5)),
              child: Icon(
                Icons.close,
                size: 26,
                color: Colors.white,
              ),
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              Get.find<CameraCubit>().nextFlashMode();
              final mode = Get.find<CameraCubit>().state.flashMode;
              mode == 0
                  ? _cameraController.setFlashMode(FlashMode.off)
                  : mode == 1
                      ? _cameraController.setFlashMode(FlashMode.auto)
                      : _cameraController.setFlashMode(FlashMode.always);
            },
            child: Padding(
              padding: EdgeInsets.all(Dim.widthPercent(5)),
              child: BlocBuilder<CameraCubit, CameraState>(
                bloc: Get.find<CameraCubit>(),
                builder: (context, state) {
                  return Icon(
                    state.flashMode == 0
                        ? Icons.flash_off_rounded
                        : state.flashMode == 1
                            ? Icons.flash_auto_rounded
                            : Icons.flash_on_rounded,
                    size: 26,
                    color: Colors.white,
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _controlPanel() {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(bottom: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildButton(
                onTap: () => Get.back(),
                size: 56,
                iconSize: 25,
                isMid: false,
                iconData: CupertinoIcons.photo,
                padding: EdgeInsets.only(left: Dim.widthPercent(5)),
                border: Border.all(
                    color: Theme.of(context).colorScheme.secondary, width: 0),
                opacity: 0.3),
            Spacer(),
            _buildButton(
                onTap: () async {
                  try {
                    final XFile file = await _cameraController.takePicture();
                    await push(RoutePaths.cameraPictureView.path,
                        arguments: file);
                  } catch (e) {
                    Logger().log(Level.error,
                        'Error occured during takeing Picture:\n$e');
                    Utilities.showSimpleSnackBar(
                      context: context,
                      message: AppLocalizations.of(context)!
                          .errorOccuredDuringTakeingPicture,
                    );
                  }
                },
                onLongPress: () async {
                  //   _cameraController.startVideoRecording();
                },
                onLongPressUp: () async {
                  //TODO Do we need to add a screen to work with the video file and process the file as in telegram?
                  /*    try {
                    final XFile file =
                        await _cameraController.stopVideoRecording();
                    await push(RoutePaths.cameraPictureView.path,
                        arguments: file.path);
                  } catch (e) {
                    Logger().log(Level.error,
                        'Error occured during saving Video file:\n$e');
                  }*/
                },
                isMid: true,
                size: 80,
                iconSize: 25,
                iconData: CupertinoIcons.photo,
                padding: EdgeInsets.all(Dim.widthPercent(1)),
                border: Border.all(color: Colors.white, width: 6),
                opacity: 0.5),
            Spacer(),
            _buildButton(
                onTap: () async {
                  final state = Get.find<CameraCubit>().state;
                  _toggleCameraLens(state.availableCameras);
                },
                size: 56,
                iconSize: 25,
                isMid: false,
                iconData: CupertinoIcons.repeat,
                padding: EdgeInsets.only(right: Dim.widthPercent(5)),
                border: Border.all(
                    color: Theme.of(context).colorScheme.secondary, width: 0),
                opacity: 0.3),
          ],
        ),
      ),
    );
  }

  Widget _bottomTitle() {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          /*  TODO add after implimenting editing video file 
        Text("Tap for photo, hold for video",
              style: Theme.of(context)
                  .textTheme
                  .headline3!
                  .copyWith(fontSize: 17, fontWeight: FontWeight.w600)),*/
          SizedBox(
            height: Dim.heightPercent(5),
          )
        ],
      ),
    );
  }

  Widget _buildButton(
      {required double size,
      required double iconSize,
      required EdgeInsets padding,
      required BoxBorder border,
      required IconData iconData,
      required double opacity,
      required bool isMid,
      required Function onTap,
      Function? onLongPress,
      Function? onLongPressUp}) {
    return GestureDetector(
      onLongPress: () async {
        if (onLongPress != null) onLongPress();
      },
      onLongPressUp: () {
        if (onLongPressUp != null) onLongPressUp();
      },
      onTap: () {
        onTap();
      },
      child: Padding(
        padding: padding,
        child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(opacity),
            shape: BoxShape.circle,
            border: border,
          ),
          child: isMid
              ? null
              : Icon(
                  iconData,
                  size: iconSize,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }
}
