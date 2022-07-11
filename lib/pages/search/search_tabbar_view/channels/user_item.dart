import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/pages/receive_sharing_file/receive_sharing_file_widget.dart';
import 'package:twake/repositories/badges_repository.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/widgets/common/badges.dart';
import 'package:twake/widgets/common/image_widget.dart';

class UserItemWidget extends StatelessWidget {
  final Account account;

  const UserItemWidget({
    Key? key,
    required this.account,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        NavigatorService.instance.navigate(
          channelId: account.id,
        );
      },
      child: Container(
        width: 58,
        margin: const EdgeInsets.only(right: 8, bottom: 10),
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
                    name: account.fullName,
                    imageType: ImageType.common,
                    size: 56,
                    //imageUrl: account. ?? '',
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
                  Text(
                      account.fullName.length > maxTextLength
                          ? account.fullName.substring(0, maxTextLength)
                          : account.fullName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .headline1!
                          .copyWith(fontSize: 17, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4.0),
                  Text(AppLocalizations.of(context)?.membersPlural(0) ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .headline3!
                          .copyWith(fontSize: 15)),
                ],
              ),
            ),
            BadgesCount(
              type: BadgeType.channel,
              id: account.id,
              key: ValueKey(account.id),
              isTitleVisible: false,
            ),
          ],
        ),
      ),
    );
  }
}
