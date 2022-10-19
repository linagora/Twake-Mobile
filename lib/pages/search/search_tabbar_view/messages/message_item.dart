import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_state.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/services/service_bundle.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/widgets/common/highlighted_text_widget.dart';
import 'package:twake/widgets/common/image_widget.dart';

class MessageItem extends StatelessWidget {
  final Message message;
  final Channel channel;
  final String searchTerm;

  const MessageItem(
      {Key? key,
      required this.message,
      required this.channel,
      required this.searchTerm})
      : super(key: key);

  String getWorkspaceName() {
    try {
      final workspaces =
          (Get.find<WorkspacesCubit>().state as WorkspacesLoadSuccess)
              .workspaces;

      final workspace =
          workspaces.firstWhere((element) => element.id == channel.workspaceId);

      return workspace.name;
    } catch (e) {
      Logger().e("error while getting workspace name: $e");
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        NavigatorService.instance.navigate(
          channelId: channel.id,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        color: Colors.transparent,
        child: Row(
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ImageWidget(
                    name: message.username ?? '',
                    imageType: ImageType.common,
                    size: 56,
                    imageUrl: message.picture ?? '',
                  ),
                ),
                SizedBox.shrink(),
              ],
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
                            Text(getWorkspaceName(),
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
                                  width: 13,
                                  height: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer),
                            ),
                            Expanded(
                              child: Text(channel.name,
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
