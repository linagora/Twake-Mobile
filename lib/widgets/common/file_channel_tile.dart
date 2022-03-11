import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/cache_file_cubit/cache_file_cubit.dart';
import 'package:twake/blocs/file_cubit/file_cubit.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/widgets/common/shimmer_loading.dart';
import 'package:twake/utils/extensions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const _fileTileHeight = 76.0;

class FileChannelTile extends StatefulWidget {
  final String fileId;
  final String senderName;

  FileChannelTile({required this.fileId, required this.senderName}) : super(key: ValueKey(fileId));

  @override
  State<FileChannelTile> createState() => _FileTileState();
}

class _FileTileState extends State<FileChannelTile> {
  @override
  Widget build(BuildContext context) {
    File? cacheFile = Get.find<CacheFileCubit>().findCachedFile(fileId: widget.fileId);
    return cacheFile == null
        ? FutureBuilder(
            future: Get.find<FileCubit>().getFileData(id: widget.fileId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data == null) {
                  return SizedBox.shrink();
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
          Expanded(
            child: _buildFileInfo(file),
          ),
        ]),
      );

  _buildFileHeader(File file) {
    return SizedBox(
      width: _fileTileHeight,
      height: _fileTileHeight,
      child: _buildThumbnail(file),
    );
  }

  _buildThumbnail(File file) {
    return GestureDetector(
      onTap: () {
        NavigatorService.instance.navigateToFilePreview(
          channelId: Globals.instance.channelId!,
          file: file,
          enableDownload: true,
          isImage: file.metadata.mime.isImageMimeType,
        );
      },
      child: file.thumbnailUrl.isNotEmpty
          ? _buildFilePreview(file.thumbnailUrl)
          : _buildFileTypeIcon(file),
    );
  }

  _buildFilePreview(String thumbUrl) {
    return ClipRRect(
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
  }

  _buildFileTypeIcon(File file) {
    final extension = file.metadata.name.fileExtension;
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

  _buildFileInfo(File file) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
            text: TextSpan(
                text: file.metadata.name,
                style: Theme.of(context)
                    .textTheme
                    .headline1!
                    .copyWith(fontWeight: FontWeight.w600, fontSize: 16)),
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
        Text(
          DateFormatter.getVerboseDateTime(file.updatedAt),
          textAlign: TextAlign.start,
          style: Theme.of(context)
              .textTheme
              .headline1!
              .copyWith(fontWeight: FontWeight.w200, fontSize: 14),
        ),
      ],
    );
  }
}
