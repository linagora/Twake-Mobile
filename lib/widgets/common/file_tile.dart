import 'package:cached_network_image/cached_network_image.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:twake/blocs/cache_file_cubit/cache_file_cubit.dart';
import 'package:twake/blocs/file_cubit/file_cubit.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/utils/utilities.dart';
import 'package:twake/widgets/common/shimmer_loading.dart';
import 'package:twake/utils/extensions.dart';

const _fileTileHeight = 76.0;

class FileTile extends StatelessWidget {
  final String fileId;
  final bool isMyMessage;

  FileTile({required this.fileId, required this.isMyMessage})
      : super(key: ValueKey(fileId));

  @override
  Widget build(BuildContext context) {
    File? cacheFile = Get.find<CacheFileCubit>().findCachedFile(fileId: fileId);
    return cacheFile == null
        ? FutureBuilder(
            future: Get.find<FileCubit>().getFileData(id: fileId),
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
    child: Row(
          children: [
            _buildThumbnail(file),
            SizedBox(width: 12.0),
            Flexible(
              child: _buildInfo(file),
            ),
          ]
    ),
  );

  _buildThumbnail(File file) => SizedBox(
        width: _fileTileHeight,
        height: _fileTileHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildFilePreview(file),
          ],
        ),
      );

  _buildFilePreview(File file) => GestureDetector(
        onTap: () async {
          final imageCachedPath =
              await Utilities.getCachedImagePath(file.thumbnailUrl);
          await OpenFile.open(imageCachedPath, type: file.metadata.mime);
        },
        child: file.metadata.mime.isImageMimeType
            ? ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                child: CachedNetworkImage(
                  width: double.maxFinite,
                  height: double.maxFinite,
                  fit: BoxFit.cover,
                  imageUrl: file.thumbnailUrl,
                  progressIndicatorBuilder: (context, url, progress) {
                    return ShimmerLoading(
                        isLoading: true,
                        width: double.maxFinite,
                        height: double.maxFinite,
                        child: Container());
                  },
                ),
              )
            : Image.asset(imageFile,
                width: 32, height: 32, color: isMyMessage ? null : Colors.grey),
      );

  _buildInfo(File file) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
              text: TextSpan(
                  text: file.metadata.name,
                  style: TextStyle(
                      fontSize: 16.0,
                      color: isMyMessage ? Colors.white : Colors.black)),
              overflow: TextOverflow.ellipsis,
              maxLines: 2),
          Text(
            filesize(file.uploadData.size),
            textAlign: TextAlign.start,
            style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                color: isMyMessage
                    ? Color.fromRGBO(255, 255, 255, 0.58)
                    : Color.fromRGBO(0, 0, 0, 0.58)),
          ),
        ],
      );
}
