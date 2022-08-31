import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:filesize/filesize.dart';
import 'package:open_file/open_file.dart';
import 'package:twake/blocs/cache_in_chat_cubit/cache_in_chat_cubit.dart';
import 'package:twake/blocs/file_cubit/download/file_download_cubit.dart';
import 'package:twake/blocs/file_cubit/download/file_download_state.dart';
import 'package:twake/blocs/file_cubit/file_cubit.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/models/file/download/file_downloading.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/utils/utilities.dart';
import 'package:twake/widgets/common/shimmer_loading.dart';
import 'package:twake/utils/extensions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        Get.find<CacheInChatCubit>().findCachedFile(fileId: widget.fileId);
    return cacheFile == null
        ? FutureBuilder(
            future: Get.find<FileCubit>().getFileData(id: widget.fileId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data == null) {
                  return _buildLoadingLayout();
                }
                final file = (snapshot.data as File);
                Get.find<CacheInChatCubit>().cacheFile(file: file);
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
          width: Dim.widthPercent(75),
          height: Dim.heightPercent(70),
          isLoading: true,
          child: Container(),
        ),
      );

  _buildFileWidget(File file) => Container(
        margin: const EdgeInsets.only(bottom: 4.0),
        child: Row(children: [
          _buildFileHeader(file),
          file.thumbnailUrl.isEmpty
              ? Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: _buildFileInfo(file),
                )
              : SizedBox.shrink(),
        ]),
      );

  _buildFileHeader(File file) {
    return Container(
      constraints: BoxConstraints(
          maxWidth: Dim.widthPercent(75), maxHeight: Dim.heightPercent(70)),
      child: BlocBuilder<FileDownloadCubit, FileDownloadState>(
          bloc: Get.find<FileDownloadCubit>(),
          builder: (context, state) {
            FileDownloading? selectedFile;
            if (state.listFileDownloading.isNotEmpty) {
              selectedFile = state.listFileDownloading.firstWhereOrNull(
                  (fileDownloading) => fileDownloading.messageFile == null
                      ? fileDownloading.file!.id == file.id
                      : fileDownloading.messageFile!.metadata.externalId ==
                          file.id);
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
              channelId: Globals.instance.channelId!,
              file: file,
              enableDownload: true,
              isImage: true);
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
          ? _buildFilePreview(file)
          : _buildFileTypeIcon(file),
    );
  }

  _buildFileInfo(File file) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: Dim.widthPercent(50)),
            child: RichText(
                text: TextSpan(
                    text: file.metadata.name,
                    style: TextStyle(
                        fontSize: 16.0,
                        color:
                            widget.isMyMessage ? Colors.white : Colors.black)),
                overflow: TextOverflow.ellipsis,
                maxLines: 2),
          ),
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

  _buildFilePreview(File file) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        child: Container(
          height: Dim.heightPercent(70) * _aspectRatioCoefficient(file),
          width: Dim.widthPercent(75), // * cWidth,
          child: CachedNetworkImage(
            height: Dim.heightPercent(70) * _aspectRatioCoefficient(file),
            width: Dim.widthPercent(75), // * cWidth,
            fit: BoxFit.cover,
            imageUrl: file.downloadUrl,
            progressIndicatorBuilder: (context, url, progress) {
              return ShimmerLoading(
                  isLoading: true,
                  height: Dim.heightPercent(70) * _aspectRatioCoefficient(file),
                  width: Dim.widthPercent(75), // * cWidth,
                  child: Container());
            },
          ),
        ),
      ),
    );
  }

  _buildFileTypeIcon(File file) {
    final extension = file.metadata.name.fileExtension;
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        color: Get.isDarkMode
            ? widget.isMyMessage
                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.3)
                : Theme.of(context)
                    .colorScheme
                    .secondaryContainer
                    .withOpacity(0.3)
            : widget.isMyMessage
                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.3)
                : Theme.of(context).iconTheme.color!.withOpacity(0.3),
        borderRadius: BorderRadius.all(Radius.circular(18)),
        border: Border.all(
          color: Get.isDarkMode
              ? Theme.of(context)
                  .colorScheme
                  .secondaryContainer
                  .withOpacity(0.5)
              : Theme.of(context).colorScheme.surface.withOpacity(0.3),
        ),
      ),
      child: Image.asset(
        extension.imageAssetByFileExtension,
        width: 32.0,
        height: 32.0,
        color: widget.isMyMessage ? null : Colors.grey,
      ),
    );
  }

  num _aspectRatioCoefficient(File file) {
    final num aspectRatio = file.thumbnails.isNotEmpty
        ? file.thumbnails.first.width / file.thumbnails.first.height
        : 1;
    final num coefficientHeight = aspectRatio > 1 ? 1 / aspectRatio : 1;
    // coefficientWidth that is not neeede for now
    // final coefficientWidth= aspectRatio < 1 ? aspectRatio : 1;
    return coefficientHeight;
  }

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
      context: context,
      message: AppLocalizations.of(context)!.cantOpenFile,
      iconPath: imageError,
    );
  }
}
