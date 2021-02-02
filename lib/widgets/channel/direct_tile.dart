import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/channels_bloc/channels_bloc.dart';
import 'package:twake/blocs/directs_bloc/directs_bloc.dart';
import 'package:twake/blocs/draft_bloc/draft_bloc.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/models/direct.dart';
import 'package:twake/pages/messages_page.dart';
import 'package:twake/repositories/draft_repository.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/utils/navigation.dart';
import 'package:twake/widgets/common/stacked_image_avatars.dart';

class DirectTile extends StatelessWidget {
  final Direct direct;

  DirectTile(this.direct);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {

        var draftType = DraftType.direct;
        final id = direct.id;
        // Load draft from local storage
        context.read<DraftBloc>().add(LoadDraft(id: id, type: draftType));

        openDirect(context, direct.id);
      },
      child: SizedBox(
        height: 62.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // SizedBox(width: 12),
            StackedUserAvatars(direct.members),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    direct.name,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff444444),
                    ),
                  ),
                  if (direct.description?.isNotEmpty ?? false)
                    Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Text(
                        direct.description,
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
