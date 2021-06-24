import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef OnSelectedMemberTileClick = void Function();

class SelectedMemberTile extends StatelessWidget {
  final String memberName;
  final OnSelectedMemberTileClick? onSelectedMemberTileClick;

  const SelectedMemberTile({Key? key, required this.memberName, this.onSelectedMemberTileClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 44,
          color: Color(0xfffcfcfc),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: GestureDetector(
                  onTap: onSelectedMemberTileClick,
                  child: Icon(
                    Icons.remove_circle,
                    color: Color(0xffff3347),
                  ),
                ),
              ),
              Flexible(
                  child: Text(memberName,
                    maxLines: 1,
                    style: TextStyle(
                      color: Color(0xff000000),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                    ),
                  )),
              SizedBox(width: 12,)
            ],
          ),
        ));
  }
}
