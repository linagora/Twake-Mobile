import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:open_file_safe/open_file_safe.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/file_cubit/download/file_download_cubit.dart';
import 'package:twake/blocs/file_cubit/download/file_download_state.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/config/styles_config.dart';
import 'package:twake/models/file/download/file_downloading.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/models/file/message_file.dart';
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
  File? file;
  MessageFile? messageFile;
  late bool? enableDownload;
  late bool? isImageType;

  @override
  void initState() {
    super.initState();
    final getFile = Get.arguments[0];
    getFile.runtimeType == MessageFile ? messageFile = getFile : file = getFile;
    enableDownload = Get.arguments[1];
    isImageType = Get.arguments[2];
  }

  @override
  Widget build(BuildContext context) {
    final channel = (Get.find<T>().state as ChannelsLoadedSuccess).selected;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        titleSpacing: 0.0,
        shadowColor: Colors.grey[300],
        toolbarHeight: 60.0,
        title: channel != null
            ? FilePreviewHeader(
                isDirect: channel.isDirect,
                channelName: channel.name,
                avatars: channel.isDirect ? channel.avatars : const [],
                fileName: messageFile == null
                    ? file!.metadata.name
                    : messageFile!.metadata.name,
                channelIcon: Emojis.getByName(channel.icon ?? ''),
              )
            : SizedBox.shrink(),
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
                imageUrl: messageFile == null
                    ? (isImageType == true)
                        ? file!.downloadUrl
                        : file!.thumbnailUrl
                    : (isImageType == true)
                        ? messageFile!.downloadUrl
                        : messageFile!.thumbnailUrl,
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

  Widget _buildBottomLayout() {
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
                (fileDownloading) => fileDownloading.messageFile == null
                    ? fileDownloading.file!.id == file!.id
                    : fileDownloading.messageFile!.metadata.externalId ==
                        messageFile!.metadata.externalId);
          }
          return _buildDownloadIcon(file, messageFile, selectedFile);
        },
        listener: (context, state) async {
          FileDownloading? selectedFile;
          if (state.listFileDownloading.isNotEmpty) {
            selectedFile = state.listFileDownloading.firstWhereOrNull(
                (fileDownloading) => fileDownloading.messageFile == null
                    ? fileDownloading.file!.id == file!.id
                    : fileDownloading.messageFile!.metadata.externalId ==
                        messageFile!.metadata.externalId);
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

  Widget _buildDownloadIcon(
      File? file, MessageFile? messageFile, FileDownloading? fileDownloading) {
    if (fileDownloading == null) {
      return _initDownloadIcon(file, messageFile);
    }
    if (fileDownloading.downloadStatus ==
        FileItemDownloadStatus.downloadInProgress) {
      return _downloadInProgressIcon(fileDownloading);
    } else {
      return _initDownloadIcon(file, messageFile);
    }
  }

  Widget _initDownloadIcon(File? file, MessageFile? messageFile) {
    return GestureDetector(
      onTap: () => _handleDownloadFile(file, messageFile),
      child: Container(
        width: 46.0,
        height: 46.0,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Image.asset(
          imageDownload,
        ),
      ),
    );
  }

  Widget _downloadInProgressIcon(FileDownloading fileDownloading) {
    return GestureDetector(
      onTap: () => _handleCancelDownloadFile(fileDownloading),
      child: Container(
        width: 46.0,
        height: 46.0,
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

  void _handleDownloadFile(File? file, MessageFile? messageFile) {
    Get.find<FileDownloadCubit>()
        .download(context: context, file: file, messageFile: messageFile);
  }

  void _handleCancelDownloadFile(FileDownloading fileDownloading) {
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
            backgroundColor: Colors.black.withOpacity(0.7),
            title: Center(
              child: Text(
                (isImageType == true)
                    ? AppLocalizations.of(parentContext)
                            ?.fileDownloadedInGallery ??
                        ''
                    : AppLocalizations.of(parentContext)
                            ?.fileDownloadedInStorage ??
                        '',
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

  void _handleCanNotOpenFile() {
    Utilities.showSimpleSnackBar(
      context: context,
      message: AppLocalizations.of(context)!.cantOpenFile,
      iconPath: imageError,
    );
  }
}
