import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:open_file/open_file.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/file_cubit/download/file_download_cubit.dart';
import 'package:twake/blocs/file_cubit/download/file_download_state.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/config/styles_config.dart';
import 'package:twake/models/file/download/file_downloading.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/pages/chat/file_preview_header.dart';
import 'package:twake/utils/emojis.dart';
import 'package:twake/utils/utilities.dart';
import 'package:twake/widgets/common/shimmer_loading.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FilePreview<T extends BaseChannelsCubit> extends StatefulWidget {
  const FilePreview({Key? key}) : super(key: key);

  @override
  _FilePreviewState<T> createState() => _FilePreviewState<T>();
}

class _FilePreviewState<T extends BaseChannelsCubit>
    extends State<FilePreview<T>> {
  late File file;
  late bool? enableDownload;
  late bool? isImageType;

  @override
  void initState() {
    super.initState();
    file = Get.arguments[0];
    enableDownload = Get.arguments[1];
    isImageType = Get.arguments[2];
  }

  @override
  Widget build(BuildContext context) {
    final channel = (Get.find<T>().state as ChannelsLoadedSuccess).selected!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        titleSpacing: 0.0,
        shadowColor: Colors.grey[300],
        toolbarHeight: 60.0,
        title: FilePreviewHeader(
          isDirect: channel.isDirect,
          channelName: channel.name,
          avatars: channel.isDirect ? channel.avatars : const [],
          fileName: file.metadata.name,
          channelIcon: Emojis.getByName(channel.icon ?? ''),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.close, color: Colors.white))
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CachedNetworkImage(
                width: double.maxFinite,
                height: double.maxFinite,
                fit: BoxFit.contain,
                errorWidget: (context, url, error) => Icon(
                  Icons.error,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                imageUrl: (isImageType == true)
                    ? file.downloadUrl
                    : file.thumbnailUrl,
                progressIndicatorBuilder: (context, url, progress) {
                  return ShimmerLoading(
                      isLoading: true,
                      width: double.maxFinite,
                      height: double.maxFinite,
                      child: Container());
                },
              ),
            ),
            enableDownload == true ? _buildBottomLayout() : SizedBox.shrink()
          ],
        ),
      ),
    );
  }

  _buildBottomLayout() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.centerRight,
      child: BlocConsumer<FileDownloadCubit, FileDownloadState>(
        bloc: Get.find<FileDownloadCubit>(),
        builder: (context, state) {
          FileDownloading? selectedFile;
          if (state.listFileDownloading.isNotEmpty) {
            selectedFile = state.listFileDownloading.firstWhereOrNull(
                (fileDownloading) => fileDownloading.file.id == file.id);
          }
          return _buildDownloadIcon(file, selectedFile);
        },
        listener: (context, state) async {
          FileDownloading? selectedFile;
          if (state.listFileDownloading.isNotEmpty) {
            selectedFile = state.listFileDownloading.firstWhereOrNull(
                (fileDownloading) => fileDownloading.file.id == file.id);
          }
          if (selectedFile != null) {
            if (selectedFile.downloadStatus ==
                FileItemDownloadStatus.downloadSuccessful) {
              await _showDialogComplete(context, selectedFile);
              Get.find<FileDownloadCubit>().removeDownloadingFile(
                  downloadTaskId: selectedFile.downloadTaskId!);
            }
          }
        },
      ),
    );
  }

  _buildDownloadIcon(File file, FileDownloading? fileDownloading) {
    if (fileDownloading == null) {
      return _initDownloadIcon(file);
    }
    if (fileDownloading.downloadStatus ==
        FileItemDownloadStatus.downloadInProgress) {
      return _downloadInProgressIcon(fileDownloading);
    } else {
      return _initDownloadIcon(file);
    }
  }

  _initDownloadIcon(File file) {
    return GestureDetector(
      onTap: () => _handleDownloadFile(file),
      child: Container(
        width: 32.0,
        height: 32.0,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Image.asset(imageDownload),
      ),
    );
  }

  _downloadInProgressIcon(FileDownloading fileDownloading) {
    return GestureDetector(
      onTap: () => _handleCancelDownloadFile(fileDownloading),
      child: Container(
        width: 32.0,
        height: 32.0,
        padding: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          color: const Color(0xff004dff).withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              backgroundColor: Colors.transparent,
              color: const Color(0xff004dff),
              strokeWidth: 1.0,
            ),
            Image.asset(imageCancelDownload)
          ],
        ),
      ),
    );
  }

  _handleDownloadFile(File file) {
    Get.find<FileDownloadCubit>().download(context: context, file: file);
  }

  _handleCancelDownloadFile(FileDownloading fileDownloading) {
    if (fileDownloading.downloadTaskId != null) {
      Get.find<FileDownloadCubit>().cancelDownloadingFile(
          downloadTaskId: fileDownloading.downloadTaskId!);
    }
  }

  Future<void> _showDialogComplete(
      BuildContext parentContext, FileDownloading? fileDownloading) async {
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            Navigator.of(context).pop();
            return false;
          },
          child: AlertDialog(
            backgroundColor: Colors.black.withOpacity(0.4),
            title: Center(
              child: Text(
                (isImageType == true)
                  ? AppLocalizations.of(parentContext)?.fileDownloadedInGallery ?? ''
                  : AppLocalizations.of(parentContext)?.fileDownloadedInStorage ?? '',
                style: StylesConfig.commonTextStyle
                    .copyWith(color: Colors.white, fontSize: 16.0),
              ),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(
                  AppLocalizations.of(parentContext)?.openIt ?? '',
                  style: StylesConfig.commonTextStyle
                      .copyWith(color: Colors.white, fontSize: 16.0),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();

                  if (fileDownloading == null) return;
                  if (fileDownloading.downloadStatus !=
                      FileItemDownloadStatus.downloadSuccessful) return;
                  if (fileDownloading.downloadTaskId != null) {
                    await _handleOpenFile(
                        taskId: fileDownloading.downloadTaskId!);
                    return;
                  }
                  if (fileDownloading.savedPath != null) {
                    await _handleOpenFile(savedPath: fileDownloading.savedPath);
                    return;
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Open file either by [taskId] or [savedPath]
  Future<void> _handleOpenFile({String? taskId, String? savedPath}) async {
    try {
      if (taskId != null) {
        final result = await Get.find<FileDownloadCubit>()
            .openDownloadedFile(downloadTaskId: taskId);
        if (!result) {
          _handleCanNotOpenFile();
        }
        return;
      }
      if (savedPath != null) {
        final result = await OpenFile.open(savedPath);
        if (result.type != ResultType.done) {
          _handleCanNotOpenFile();
        }
        return;
      }
    } catch (e) {
      Logger().e('Error occurred during open file after downloaded:\n$e');
      _handleCanNotOpenFile();
    }
  }

  _handleCanNotOpenFile() {
    Utilities.showSimpleSnackBar(
      context: context,
      message: AppLocalizations.of(context)!.cantOpenFile,
      iconPath: imageError,
    );
  }
}
