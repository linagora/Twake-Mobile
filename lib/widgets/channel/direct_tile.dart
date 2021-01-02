import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/channels_bloc.dart';
import 'package:twake/blocs/directs_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/direct.dart';
import 'package:twake/pages/messages_page.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/widgets/common/stacked_image_avatars.dart';

class DirectTile extends StatelessWidget {
  final Direct direct;
  DirectTile(this.direct);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        BlocProvider.of<DirectsBloc>(context).add(
          ChangeSelectedChannel(direct.id),
        );
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => MessagesPage()));
      },
      child: ListTile(
        contentPadding: EdgeInsets.only(bottom: Dim.textMultiplier),
        leading: StackedUserAvatars(direct.members),
        title: Text(
          direct.name,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headline6,
        ),
        trailing: FittedBox(
          fit: BoxFit.fitWidth,
          child: Row(
            children: [
              Text(
                DateFormatter.getVerboseDateTime(direct.lastActivity),
                style: Theme.of(context).textTheme.subtitle2,
              ),
              if (direct.messagesUnread != 0) SizedBox(width: Dim.wm2),
              if (direct.messagesUnread != 0)
                Chip(
                  labelPadding:
                      EdgeInsets.symmetric(horizontal: Dim.widthMultiplier),
                  label: Text(
                    '${direct.messagesUnread}',
                    style: TextStyle(color: Colors.white, fontSize: Dim.tm2()),
                  ),
                  clipBehavior: Clip.antiAlias,
                  backgroundColor: Color.fromRGBO(255, 81, 84, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
