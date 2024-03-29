import 'package:flutter/material.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/widgets/common/image_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

typedef OnFoundMemberTileClick = void Function();

class FoundMemberTile extends StatelessWidget {
  final bool isSelected;
  final String name;
  final String imageUrl;
  final String userId;
  final OnFoundMemberTileClick? onFoundMemberTileClick;

  const FoundMemberTile(
      {Key? key,
      required this.isSelected,
      required this.name,
      required this.imageUrl,
      required this.userId,
      this.onFoundMemberTileClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onFoundMemberTileClick,
      child: Container(
        height: 48,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
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
                    style: Theme.of(context).textTheme.headline2!.copyWith(fontSize: 13, fontWeight: FontWeight.w400),
                  )
                : SizedBox.shrink(),
            Padding(
                padding: const EdgeInsets.only(right: 16, left: 12),
                child: _buildSelectedImage(isSelected))
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedImage(bool isSelected) {
    return isSelected
        ? Image.asset(
            imageSelectedRoundBlue,
            width: 24,
            height: 24,
          )
        : _UnselectedChanelTypeImage();
  }
}

class _UnselectedChanelTypeImage extends StatelessWidget {
  const _UnselectedChanelTypeImage() : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary,
          ),
          borderRadius: BorderRadius.all(Radius.circular(12))),
      height: 24,
      width: 24,
    );
  }
}
