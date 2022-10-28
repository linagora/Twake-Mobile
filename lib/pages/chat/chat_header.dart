import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/online_status_cubit/online_status_cubit.dart';
import 'package:twake/blocs/writing_cubit/writing_cubit.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/pages/chat/writingStatus.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/widgets/common/image_widget.dart';
import 'package:twake/widgets/common/online_status_circle.dart';
import 'package:twake/widgets/common/shimmer_loading.dart';

class ChatHeader extends StatelessWidget {
  final bool isDirect;
  final bool isPrivate;
  final int membersCount;
  final List<String> users;
  final String channelId;
  final String icon;
  final String name;
  final Function? onTap;
  final List<Avatar> avatars;

  const ChatHeader(
      {Key? key,
      required this.isDirect,
      this.isPrivate = false,
      required this.users,
      required this.channelId,
      required this.membersCount,
      this.icon = '',
      this.name = '',
      this.onTap,
      this.avatars = const []})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap as void Function()?,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              ImageWidget(
                  imageType: isDirect ? ImageType.common : ImageType.channel,
                  size: 42,
                  fontSize: 32,
                  imageUrl: isDirect ? avatars.first.link : icon,
                  avatars: avatars,
                  stackSize: 24,
                  name: name),
              if (isDirect)
                Positioned(
                    left: 28,
                    child: OnlineStatusCircle(
                      channelId: channelId,
                      size: 16,
                    ))
            ],
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ShimmerLoading(
                  key: ValueKey<String>('name'),
                  isLoading: name.isEmpty,
                  width: 60.0,
                  height: 10.0,
                  child: Text(
                    name,
                    style: Theme.of(context)
                        .textTheme
                        .headline1!
                        .copyWith(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
                BlocBuilder<WritingCubit, WritingState>(
                  bloc: Get.find<WritingCubit>(),
                  builder: (context, state) {
                    if (state.writingStatus == WritingStatus.writing &&
                        state.writingMap.containsKey(channelId) &&
                        state.writingMap[channelId]!.isNotEmpty) {
                      return ChatWritingStatus(
                          usersList: state.writingMap[channelId]!,
                          isDirect: isDirect,
                          key: ValueKey(channelId));
                    } else if (state.writingStatus ==
                            WritingStatus.notWriting &&
                        state.writingMap.containsKey(channelId) &&
                        state.writingMap[channelId]!.isNotEmpty) {
                      return ChatWritingStatus(
                          usersList: state.writingMap[channelId]!,
                          isDirect: isDirect,
                          key: ValueKey(channelId));
                    } else {
                      return isDirect && avatars.length == 1
                          ? BlocBuilder<OnlineStatusCubit, OnlineStatusState>(
                              bloc: Get.find<OnlineStatusCubit>(),
                              builder: (context, state) {
                                final statusList = Get.find<OnlineStatusCubit>()
                                    .isConnected(channelId);
                                return state.onlineStatus ==
                                            OnlineStatus.success &&
                                        statusList[0]
                                    ? Text(
                                        AppLocalizations.of(context)!.online,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline2!
                                            .copyWith(
                                                fontSize: 13,
                                                fontWeight: FontWeight.normal),
                                      )
                                    : Text(
                                        '${statusList[1] == 946670400000 ? '' : AppLocalizations.of(context)!.online} ${statusList[1] == 946670400000 ? '' : DateFormatter.getVerboseDate(statusList[1], true)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline2!
                                            .copyWith(
                                                fontSize: 13,
                                                fontWeight: FontWeight.normal),
                                      );
                              },
                            )
                          : SizedBox(
                              height: 16,
                              child: Text(
                                AppLocalizations.of(context)!
                                    .membersPlural(membersCount),
                                style: Theme.of(context)
                                    .textTheme
                                    .headline2!
                                    .copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.normal),
                              ),
                            );
                    }
                  },
                ),
              ],
            ),
          ),
          SizedBox(width: 15),
        ],
      ),
    );
  }
}
