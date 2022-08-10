import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/cache_in_chat_cubit/cache_in_chat_cubit.dart';
import 'package:twake/blocs/file_cubit/file_cubit.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/utils/extensions.dart';
import 'package:twake/widgets/common/highlighted_text_widget.dart';

class FileItem extends StatelessWidget {
  final Message message;
  final Account user;
  final String searchTerm;

  const FileItem(
      {Key? key,
      required this.message,
      required this.user,
      required this.searchTerm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fileId = message.files![0] as String;

    File? cacheFile =
        Get.find<CacheInChatCubit>().findCachedFile(fileId: fileId);

    return cacheFile == null
        ? FutureBuilder(
            future: Get.find<FileCubit>().getFileData(id: fileId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data != null) {
                final file = (snapshot.data as File);
                Get.find<CacheInChatCubit>().cacheFile(file: file);
                return _buildView(context, file);
              }

              return SizedBox();
            },
          )
        : _buildView(context, cacheFile);
  }

  _buildView(BuildContext context, File file) {
    return GestureDetector(
      onTap: () {
        NavigatorService.instance.navigate(
          channelId: 'test id',
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        color: Colors.transparent,
        child: Row(
          children: [
            Image.asset(
              file.metadata.name.fileExtension.imageAssetByFileExtension,
              width: 36.0,
              height: 36.0,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(user.fullName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline1!
                                    .copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Image.asset(imageArrowRight,
                                  width: 13, height: 12),
                            ),
                            Expanded(
                              child: Text(file.metadata.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline1!
                                      .copyWith(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                      Text(DateFormatter.getVerboseTime(message.createdAt),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .headline3!
                              .copyWith(fontSize: 13)),
                      Text(DateFormatter.getVerboseDate(message.createdAt),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .headline3!
                              .copyWith(fontSize: 13)),
                    ],
                  ),
                  Text(message.firstName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .headline1!
                          .copyWith(fontSize: 15)),
                  SizedBox(height: 2.0),
                  Text(
                    filesize(file.uploadData.size),
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                        color: Color.fromRGBO(0, 0, 0, 0.58)),
                  ),
                  HighlightedTextWidget(
                      text: message.text,
                      searchTerm: searchTerm,
                      maxLines: 1,
                      textOverflow: TextOverflow.ellipsis,
                      textStyle: Theme.of(context)
                          .textTheme
                          .headline3!
                          .copyWith(fontSize: 15),
                      highlightStyle: Theme.of(context)
                          .textTheme
                          .headline3!
                          .copyWith(
                              fontSize: 15,
                              color: Theme.of(context).colorScheme.surface)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
