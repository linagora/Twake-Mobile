import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twake/config/dimensions_config.dart';

typedef OnSelectedMemberTileClick = void Function();

class SelectedMemberTile extends StatelessWidget {
  final String memberName;
  final OnSelectedMemberTileClick? onSelectedMemberTileClick;

  const SelectedMemberTile(
      {Key? key, required this.memberName, this.onSelectedMemberTileClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 44,
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: GestureDetector(
                  onTap: onSelectedMemberTileClick,
                  child: Icon(
                    Icons.remove_circle,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: Dim.widthPercent(72),
                  ),
                  child: Text(memberName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .headline1!
                          .copyWith(fontSize: 15, fontWeight: FontWeight.w400)),
                ),
              ),
              SizedBox(
                width: 12,
              )
            ],
          ),
        ));
  }
}
