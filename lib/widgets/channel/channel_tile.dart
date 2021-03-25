import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/draft_bloc/draft_bloc.dart';
import 'package:twake/blocs/profile_bloc/profile_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/channel.dart';
import 'package:twake/repositories/draft_repository.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/utils/navigation.dart';
import 'package:twake/widgets/common/text_avatar.dart';

class ChannelTile extends StatelessWidget {
  final Channel channel;

  ChannelTile(this.channel);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        var draftType = DraftType.channel;
        final id = channel.id;
        // Load draft from local storage
        context.read<DraftBloc>().add(LoadDraft(id: id, type: draftType));

        openChannel(context, channel.id);
      },
      child: SizedBox(
        height: 62.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // SizedBox(width: 12),
            TextAvatar(channel.icon),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        channel.name,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: channel.hasUnread == 1
                              ? FontWeight.w900
                              : FontWeight.w400,
                          color: Color(0xff444444),
                        ),
                      ),
                      SizedBox(width: 6),
                      if (channel.visibility != null &&
                          channel.visibility == 'private')
                        Icon(
                          Icons.lock_outline,
                          size: 16.0,
                          color: Color(0xff444444),
                        ),
                      Spacer(),
                      Text(
                        DateFormatter.getVerboseDateTime(channel.lastActivity),
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 4.0),
                        child: Text(
                          channel.lastMessage['text'] ?? 'No messages yet',
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff444444),
                          ),
                        ),
                      ),
                      Spacer(),
                      if (channel.messagesUnread != 0) SizedBox(width: Dim.wm2),
                      // if (channel.messagesUnread != 0)
                      BlocBuilder<ProfileBloc, ProfileState>(
                        buildWhen: (_, curr) => curr is ProfileLoaded,
                        builder: (ctx, state) {
                          final count =
                          (state as ProfileLoaded).getBadgeForChannel(channel.id);
                          if (count > 0) {
                            return Badge(
                              shape: BadgeShape.square,
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                              padding: EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              badgeContent: Text(
                                '$count',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: Dim.tm2(),
                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
