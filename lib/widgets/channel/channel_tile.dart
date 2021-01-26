import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/channels_bloc.dart';
import 'package:twake/blocs/draft_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/channel.dart';
import 'package:twake/pages/messages_page.dart';
import 'package:twake/repositories/draft_repository.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/widgets/common/text_avatar.dart';

class ChannelTile extends StatelessWidget {
  final Channel channel;

  ChannelTile(this.channel);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        BlocProvider.of<ChannelsBloc>(context).add(
          ChangeSelectedChannel(channel.id),
        );

        var draftType = DraftType.channel;
        final id = channel.id;
        // Load draft from local storage
        context.read<DraftBloc>().add(LoadDraft(id: id, type: draftType));

        // Navigator.of(context).pushNamed(Routes.messages);
        Navigator.of(context)
            .push(MaterialPageRoute(
          builder: (context) => MessagesPage<ChannelsBloc>(),
        ))
            .then((r) {
          if (r is bool && r) {
            Scaffold.of(context).hideCurrentSnackBar();
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('No connection to internet'),
              backgroundColor: Theme.of(context).errorColor,
            ));
          }
        });
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
                  Text(
                    channel.name,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff444444),
                    ),
                  ),
                  if (channel.description?.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text(
                        channel.description,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff444444),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormatter.getVerboseDateTime(channel.lastActivity),
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                if (channel.messagesUnread != 0) SizedBox(width: Dim.wm2),
                if (channel.messagesUnread != 0)
                  Chip(
                    labelPadding:
                        EdgeInsets.symmetric(horizontal: Dim.widthMultiplier),
                    label: Text(
                      '${channel.messagesUnread}',
                      style:
                          TextStyle(color: Colors.white, fontSize: Dim.tm2()),
                    ),
                    clipBehavior: Clip.antiAlias,
                    backgroundColor: Color.fromRGBO(255, 81, 84, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
