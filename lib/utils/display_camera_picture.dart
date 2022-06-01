// A widget that displays the picture taken by the user.
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_cubit.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/models/file/local_file.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/routing/route_paths.dart';
import 'package:twake/utils/utilities.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DisplayCameraPictureScreen extends StatefulWidget {
  const DisplayCameraPictureScreen();

  @override
  State<DisplayCameraPictureScreen> createState() =>
      _DisplayCameraPictureScreenState();
}

class _DisplayCameraPictureScreenState
    extends State<DisplayCameraPictureScreen> {
  late XFile imageXFile;

  @override
  void initState() {
    super.initState();

    imageXFile = Get.arguments;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _uploadPicture() async {
    try {
      final lengthXFile = await imageXFile.length();
      final Uint8List uint8List = await imageXFile.readAsBytes();
      final LocalFile localFile = LocalFile(
          name: imageXFile.name,
          path: imageXFile.path,
          thumbnail: uint8List,
          size: lengthXFile,
          updatedAt: DateTime.now().millisecondsSinceEpoch);

      Get.find<FileUploadCubit>().upload(
        sourceFile: localFile,
        sourceFileUploading: SourceFileUploading.InChat,
      );
      // For some reason it doesn't work as intended
      final channel =
          (Get.find<ChannelsCubit>().state as ChannelsLoadedSuccess).selected;
      channel == null
          ? await pushOff(RoutePaths.directMessages.path)
          : await pushOff(RoutePaths.channelMessages.path);
      /*  Can do this while fixing this bug 
      Get.back();
      Get.back();
      Get.back();*/
    } catch (e) {
      Logger().log(
          Level.error, 'Error occured during uploading camera picture:\n$e');
      Utilities.showSimpleSnackBar(
        context: context,
        message: AppLocalizations.of(context)!.errorOccuredDuringSavingPicture,
      );
    }
  }

  Widget build(BuildContext context) {
    return Container(
      height: Dim.maxScreenHeight,
      width: Dim.maxScreenWidth,
      color: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            _pictureView(),
            _bottomTitle(),
          ],
        ),
      ),
    );
  }

  Widget _pictureView() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
        child: ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(22),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _picture(),
              Align(alignment: Alignment.bottomCenter, child: _buildButtons()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _picture() {
    return Image.file(
      File(imageXFile.path),
      fit: BoxFit.fill,
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        GestureDetector(
          onTap: (() => Get.back()),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  AppLocalizations.of(context)!.retake,
                  style: Theme.of(context).textTheme.headline1,
                ),
              ),
            ),
          ),
        ),
        Spacer(),
        GestureDetector(
          onTap: () {
            _uploadPicture();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  AppLocalizations.of(context)!.save,
                  style: Theme.of(context).textTheme.headline1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomTitle() {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          SizedBox(
            height: Dim.heightPercent(5),
          )
        ],
      ),
    );
  }
}
