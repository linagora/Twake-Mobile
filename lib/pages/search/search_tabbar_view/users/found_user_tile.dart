import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/widgets/common/image_widget.dart';

class FoundUserTile extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String userId;
  final Function onTileClick;

  const FoundUserTile(
      {Key? key,
      required this.name,
      required this.imageUrl,
      required this.userId,
      required this.onTileClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTileClick(),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ImageWidget(
                imageType: ImageType.common,
                size: 37,
                name: name,
                imageUrl: imageUrl,
              ),
            ),
            Expanded(
              child: Text(
                name,
                style: Theme.of(context)
                    .textTheme
                    .headline1!
                    .copyWith(fontSize: 17, fontWeight: FontWeight.w400),
              ),
            ),
            userId == Globals.instance.userId
                ? Text(
                    AppLocalizations.of(context)!.youRespectful,
                    style: Theme.of(context)
                        .textTheme
                        .headline2!
                        .copyWith(fontSize: 13, fontWeight: FontWeight.w400),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
