import 'package:cached_network_image/cached_network_image.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/cache_in_chat_cubit/cache_in_chat_cubit.dart';
import 'package:twake/blocs/file_cubit/file_cubit.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/models/file/message_file.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/utils/extensions.dart';
import 'package:twake/widgets/common/shimmer_loading.dart';

typedef OnTap = void Function(dynamic file);

class FileChannelTile extends StatefulWidget {
  final String fileId;
  final String senderName;
  final OnTap? onTap;
  final MessageFile? messageFile;
  final bool onlyImage;
  final double fileTileHeight;

  FileChannelTile(
      {required this.fileId,
      required this.senderName,
      this.onTap,
      this.messageFile,
      this.onlyImage: false,
      this.fileTileHeight: 76})
      : super(key: ValueKey(fileId));

  @override
  State<FileChannelTile> createState() => _FileTileState();
}

class _FileTileState extends State<FileChannelTile> {
  @override
  Widget build(BuildContext context) {
    File? cacheFile =
        Get.find<CacheInChatCubit>().findCachedFile(fileId: widget.fileId);
    return widget.messageFile == null
        ? cacheFile == null
            ? FutureBuilder(
                future: Get.find<FileCubit>().getFileData(id: widget.fileId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data == null) {
                      return SizedBox.shrink();
                    }
                    final file = (snapshot.data as File);
                    Get.find<CacheInChatCubit>().cacheFile(file: file);
                    return _buildFileWidget(file: file);
                  }
                  return _buildLoadingLayout();
                },
              )
            : _buildFileWidget(file: cacheFile)
        : _buildFileWidget(messageFile: widget.messageFile);
  }

  Widget _buildLoadingLayout() => ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        child: ShimmerLoading(
          width: double.maxFinite,
          height: widget.fileTileHeight,
          isLoading: true,
          child: Container(),
        ),
      );

  Widget _buildFileWidget({File? file, MessageFile? messageFile}) =>
      GestureDetector(
        onTap: () {
          messageFile == null
              ? widget.onTap?.call(file)
              : widget.onTap?.call(messageFile);
        },
        child: Container(
          color: Colors.transparent,
          margin: const EdgeInsets.only(bottom: 4.0),
          child: Row(children: [
            _buildFileHeader(file: file, messageFile: messageFile),
            if (!widget.onlyImage) SizedBox(width: 12.0),
            if (!widget.onlyImage)
              Expanded(
                child: _buildFileInfo(file: file, messageFile: messageFile),
              ),
          ]),
        ),
      );

  Widget _buildFileHeader({File? file, MessageFile? messageFile}) {
    return SizedBox(
      width: widget.fileTileHeight,
      height: widget.fileTileHeight,
      child: _buildThumbnail(file: file, messageFile: messageFile),
    );
  }

  Widget _buildThumbnail({File? file, MessageFile? messageFile}) {
    return GestureDetector(
      onTap: () {
        NavigatorService.instance.navigateToFilePreview(
          channelId: Globals.instance.channelId,
          file: file,
          messageFile: messageFile,
          enableDownload: true,
          isImage: messageFile == null
              ? file!.metadata.mime.isImageMimeType
              : messageFile.metadata.mime.isImageMimeType,
        );
      },
      child: messageFile == null
          ? file!.thumbnailUrl.isNotEmpty
              ? _buildFilePreview(file.thumbnailUrl)
              : _buildFileTypeIcon(file: file)
          : messageFile.metadata.thumbnails.isNotEmpty
              ? _buildFilePreview(messageFile.thumbnailUrl)
              : _buildFileTypeIcon(messageFile: messageFile),
    );
  }

  Widget _buildFilePreview(String thumbUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      child: CachedNetworkImage(
        errorWidget: (context, url, error) => Icon(
          Icons.error,
          color: Theme.of(context).colorScheme.secondary,
        ),
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
  }

  Widget _buildFileTypeIcon({File? file, MessageFile? messageFile}) {
    final extension = messageFile == null
        ? file!.metadata.name.fileExtension
        : messageFile.metadata.name.fileExtension;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Theme.of(context).colorScheme.background,
      ),
      child: Image.asset(
        extension.imageAssetByFileExtension,
        width: 32.0,
        height: 32.0,
      ),
    );
  }

  Widget _buildFileInfo({File? file, MessageFile? messageFile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
            text: TextSpan(
                text: messageFile == null
                    ? file!.metadata.name
                    : messageFile.metadata.name,
                style: Theme.of(context)
                    .textTheme
                    .headline1!
                    .copyWith(fontWeight: FontWeight.w500, fontSize: 16)),
            overflow: TextOverflow.ellipsis,
            maxLines: 2),
        SizedBox(height: 4.0),
        Text(
          AppLocalizations.of(context)?.sentBy(widget.senderName) ?? '',
          textAlign: TextAlign.start,
          maxLines: 2,
          style: Theme.of(context)
              .textTheme
              .headline1!
              .copyWith(fontWeight: FontWeight.w200, fontSize: 14),
        ),
        Row(
          children: [
            Text(
              filesize(messageFile!.metadata.size),
              textAlign: TextAlign.start,
              style: Theme.of(context)
                  .textTheme
                  .headline1!
                  .copyWith(fontWeight: FontWeight.w200, fontSize: 14),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            Text(
              DateFormatter.getVerboseDateTime(messageFile == null
                  ? file!.updatedAt
                  : messageFile.createdAt),
              textAlign: TextAlign.start,
              style: Theme.of(context)
                  .textTheme
                  .headline1!
                  .copyWith(fontWeight: FontWeight.w200, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}
