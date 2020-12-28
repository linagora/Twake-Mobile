import 'package:flutter/material.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/direct.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/widgets/common/stacked_image_avatars.dart';

class DirectTile extends StatelessWidget {
  final Direct direct;
  DirectTile(this.direct);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigator.of(context).pushNamed(
        // MessagesScreen.route,
        // arguments: direct.id,
        // )
        // .then(
        // (_) {
        // Provider.of<ChannelsProvider>(context, listen: false).directsSort();
        // },
        // );
      },
      child: ListTile(
        contentPadding: EdgeInsets.only(bottom: Dim.textMultiplier),
        leading: StackedUserAvatars(direct.members),
        // title: Text(
        // direct.buildDirectName(profile),
        // overflow: TextOverflow.ellipsis,
        // style: Theme.of(context).textTheme.headline6,
        // ),
        title: Text(
          direct.name,
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
