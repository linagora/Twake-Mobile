import 'package:cached_network_image/cached_network_image.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:open_file/open_file.dart';
import 'package:twake/blocs/cache_file_cubit/cache_file_cubit.dart';
import 'package:twake/blocs/file_cubit/download/file_download_cubit.dart';
import 'package:twake/blocs/file_cubit/download/file_download_state.dart';
import 'package:twake/blocs/file_cubit/file_cubit.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/models/file/download/file_downloading.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/utils/utilities.dart';
import 'package:twake/widgets/common/shimmer_loading.dart';
import 'package:twake/utils/extensions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:collection/collection.dart';

const _fileTileHeight = 76.0;

/// Note [1]:
/// This is decided by User Story.
/// When it's image, user can only download from Preview page, so there is no download icon.

class FileTile extends StatefulWidget {
  final String fileId;
  final bool isMyMessage;

  FileTile({required this.fileId, required this.isMyMessage})
      : super(key: ValueKey(fileId));

  @override
  State<FileTile> createState() => _FileTileState();
}

class _FileTileState extends State<FileTile> {
  @override
  Widget build(BuildContext context) {
    File? cacheFile =
        Get.find<CacheFileCubit>().findCachedFile(fileId: widget.fileId);
    return cacheFile == null
        ? FutureBuilder(
            future: Get.find<FileCubit>().getFileData(id: widget.fileId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data == null) {
                  return _buildLoadingLayout();
                }
                final file = (snapshot.data as File);
                Get.find<CacheFileCubit>().cacheFile(file: file);
                return _buildFileWidget(file);
              }
              return _buildLoadingLayout();
            },
          )
        : _buildFileWidget(cacheFile);
  }

  _buildLoadingLayout() => ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        child: ShimmerLoading(
          width: double.maxFinite,
          height: _fileTileHeight,
          isLoading: true,
          child: Container(),
        ),
      );

  _buildFileWidget(File file) => Container(
        margin: const EdgeInsets.only(bottom: 4.0),
        child: Row(children: [
          _buildFileHeader(file),
          SizedBox(width: 12.0),
          Flexible(
            child: _buildFileInfo(file),
          ),
        ]),
      );

  _buildFileHeader(File file) {
    return SizedBox(
      width: _fileTileHeight,
      height: _fileTileHeight,
      child: BlocBuilder<FileDownloadCubit, FileDownloadState>(
          bloc: Get.find<FileDownloadCubit>(),
          builder: (context, state) {
            FileDownloading? selectedFile;
            if (state.listFileDownloading.isNotEmpty) {
              selectedFile = state.listFileDownloading.firstWhereOrNull(
                  (fileDownloading) => fileDownloading.file.id == file.id);
            }
            return Stack(
              alignment: Alignment.center,
              children: [
                _buildThumbnail(file, selectedFile),
                _buildDownloadIcon(file, selectedFile)
              ],
            );
          }),
    );
  }

  _buildThumbnail(File file, FileDownloading? fileDownloading) {
    return GestureDetector(
      onTap: () {
        /// Read [1] for the detail
        if (file.metadata.mime.isImageMimeType) {
          NavigatorService.instance.navigateToFilePreview(
              channelId: Globals.instance.channelId!, file: file);
          return;
        }
        if (fileDownloading == null) return;
        if (fileDownloading.downloadStatus !=
            FileItemDownloadStatus.downloadSuccessful) return;
        if (fileDownloading.downloadTaskId != null) {
          _handleOpenFile(taskId: fileDownloading.downloadTaskId!);
          return;
        }
        if (fileDownloading.savedPath != null) {
          _handleOpenFile(savedPath: fileDownloading.savedPath);
          return;
        }
      },
      child: file.thumbnailUrl.isNotEmpty
          ? _buildFilePreview(file.thumbnailUrl)
          : _buildFileTypeIcon(file),
    );
  }

  _buildDownloadIcon(File file, FileDownloading? fileDownloading) {
    /// Read [1] for the detail
    if (file.metadata.mime.isImageMimeType) {
      return SizedBox.shrink();
    }
    if (fileDownloading == null) {
      return _initDownloadIcon(file);
    }
    switch (fileDownloading.downloadStatus) {
      case FileItemDownloadStatus.downloadSuccessful:
        return SizedBox.shrink();
      case FileItemDownloadStatus.downloadInProgress:
        return _downloadInProgressIcon(fileDownloading);
      default:
        return _initDownloadIcon(file);
    }
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

  _initDownloadIcon(File file) {
    return GestureDetector(
      onTap: () => _handleDownloadFile(file),
      child: Container(
        width: 32.0,
        height: 32.0,
        decoration: BoxDecoration(
          color: const Color(0xff004dff).withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Image.asset(imageDownload),
      ),
    );
  }

  _buildFilePreview(String thumbUrl) => ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        child: CachedNetworkImage(
          width: double.maxFinite,
          height: double.maxFinite,
          fit: BoxFit.cover,
          imageUrl: thumbUrl,
          progressIndicatorBuilder: (context, url, progress) {
            return ShimmerLoading(
                isLoading: true,
                width: double.maxFinite,
                height: double.maxFinite,
                child: Container());
          },
        ),
      );

  _buildFileTypeIcon(File file) {
    final extension = file.metadata.name.fileExtension;
    return Image.asset(
      extension.imageAssetByFileExtension,
      width: 32.0,
      height: 32.0,
      color: widget.isMyMessage ? null : Colors.grey,
    );
  }

  _buildFileInfo(File file) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
              text: TextSpan(
                  text: file.metadata.name,
                  style: TextStyle(
                      fontSize: 16.0,
                      color: widget.isMyMessage ? Colors.white : Colors.black)),
              overflow: TextOverflow.ellipsis,
              maxLines: 2),
          Text(
            filesize(file.uploadData.size),
            textAlign: TextAlign.start,
            style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                color: widget.isMyMessage
                    ? Color.fromRGBO(255, 255, 255, 0.58)
                    : Color.fromRGBO(0, 0, 0, 0.58)),
          ),
        ],
      );

  // Open file either by [taskId] or [savedPath]
  _handleOpenFile({String? taskId, String? savedPath}) async {
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

  _handleDownloadFile(File file) {
    Get.find<FileDownloadCubit>().download(context: context, file: file);
  }

  _handleCancelDownloadFile(FileDownloading fileDownloading) {
    if (fileDownloading.downloadTaskId != null) {
      Get.find<FileDownloadCubit>().cancelDownloadingFile(
          downloadTaskId: fileDownloading.downloadTaskId!);
    }
  }

  _handleCanNotOpenFile() {
    Utilities.showSimpleSnackBar(
      message: AppLocalizations.of(context)!.cantOpenFile,
      iconPath: imageError,
    );
  }
}
