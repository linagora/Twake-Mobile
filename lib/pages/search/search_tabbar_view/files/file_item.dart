import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
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
  final File file;
  final String searchTerm;

  const FileItem(
      {Key? key,
      required this.message,
      required this.user,
      required this.file,
      required this.searchTerm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        NavigatorService.instance.navigate(
          channelId: '???',
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            bottom: BorderSide(width: 0.5, color: Colors.grey.shade300),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              file.metadata.name.fileExtension.imageAssetByFileExtension,
              width: 36.0,
              height: 36.0,
              fit: BoxFit.fill,
            ),
            SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: HighlightedTextWidget(
                            text: file.metadata.name,
                            searchTerm: searchTerm,
                            maxLines: 1,
                            textOverflow: TextOverflow.ellipsis,
                            textStyle: Theme.of(context)
                                .textTheme
                                .headline1!
                                .copyWith(fontSize: 17),
                            highlightStyle: Theme.of(context)
                                .textTheme
                                .headline1!
                                .copyWith(
                                    fontSize: 17,
                                    color:
                                        Theme.of(context).colorScheme.surface)),
                      ),
                      Text(DateFormatter.getVerboseTime(message.createdAt),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .headline3!
                              .copyWith(fontSize: 13)),
                    ],
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        filesize(file.uploadData.size),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                            color: Color.fromRGBO(0, 0, 0, 0.58)),
                      ),
                      Container(
                        width: 3,
                        height: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Color.fromRGBO(0, 0, 0, 0.58)),
                      ),
                      Text(
                        DateFormatter.getVerboseDateTime(message.createdAt),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                            color: Color.fromRGBO(0, 0, 0, 0.58)),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        constraints: BoxConstraints(maxWidth: 120),
                        child: Text(user.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .headline1!
                                .copyWith(
                                    fontSize: 13, fontWeight: FontWeight.w400)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child:
                            Image.asset(imageArrowRight, width: 12, height: 11),
                      ),
                      Expanded(
                        child: Text('???',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .headline1!
                                .copyWith(
                                    fontSize: 13, fontWeight: FontWeight.w400)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
