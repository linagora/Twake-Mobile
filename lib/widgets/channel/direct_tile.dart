import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twake_mobile/config/dimensions_config.dart' show Dim;
import 'package:twake_mobile/models/direct.dart';
import 'package:twake_mobile/providers/messages_provider.dart';
import 'package:twake_mobile/providers/profile_provider.dart';
import 'package:twake_mobile/screens/messages_screen.dart';
import 'package:twake_mobile/services/dateformatter.dart';
import 'package:twake_mobile/widgets/common/image_avatar.dart';
// import 'package:twake_mobile/providers/channels_provider.dart';

class DirectTile extends StatelessWidget {
  final Direct direct;
  DirectTile(this.direct);

  List<Widget> buildCorrespondents(List<DirectMember> correspondents) {
    List<Padding> paddedAvatars = [];
    for (int i = 0; i < correspondents.length; i++) {
      paddedAvatars.add(Padding(
          padding: EdgeInsets.only(left: i * Dim.wm2),
          child: ImageAvatar(correspondents[i].thumbnail)));
    }
    return paddedAvatars;
  }

  String buildDirectName(List<DirectMember> correspondents) {
    String name =
        '${correspondents[0].firstName} ${correspondents[0].lastName}';
    for (int i = 1; i < correspondents.length; i++) {
      name += ', ${correspondents[i].firstName} ${correspondents[i].lastName}';
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileProvider>(context, listen: false);
    final correspondents = direct.members.where((m) {
      return !profile.isMe(m.userId);
    }).toList();

    return InkWell(
      onTap: () {
        final provider = Provider.of<MessagesProvider>(context, listen: false);
        provider.clearMessages();
        Navigator.of(context).pushNamed(
          MessagesScreen.route,
          arguments: direct.id,
          // )
          // .then(
          // (_) {
          // Provider.of<ChannelsProvider>(context, listen: false).directsSort();
          // },
        );
      },
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: Dim.heightMultiplier),
        leading: Stack(
            alignment: Alignment.centerLeft,
            children: buildCorrespondents(correspondents)),
        title: Text(
          correspondents.length == 1
              ? '${correspondents[0].firstName} ${correspondents[0].lastName}'
              : direct.name.isNotEmpty
                  ? direct.name
                  : buildDirectName(correspondents),
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headline6,
        ),
        trailing: FittedBox(
          fit: BoxFit.fitWidth,
          // width: Dim.widthPercent(40),
          child: Row(
            children: [
              Text(
                DateFormatter.getVerboseDateTime(direct.lastActivity),
                style: Theme.of(context).textTheme.subtitle2,
              ),
              if (direct.messageUnread != 0) SizedBox(width: Dim.wm2),
              if (direct.messageUnread != 0)
                Chip(
                  labelPadding:
                      EdgeInsets.symmetric(horizontal: Dim.widthMultiplier),
                  label: Text(
                    '${direct.messageUnread}',
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
