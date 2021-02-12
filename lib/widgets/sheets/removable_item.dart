import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';

class RemovableItem extends StatelessWidget {
  final String title;
  final bool removable;
  final Function onRemove;

  const RemovableItem({
    Key key,
    @required this.title,
    this.removable = true,
    this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 45.0,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Spacer(),
          Row(
            children: [
              SizedBox(width: 16.0),
              removable
                  ? GestureDetector(
                      onTap: () => onRemove?.call(),
                      child: Icon(
                        CupertinoIcons.minus_circle_fill,
                        color: Color(0xfff14620),
                        size: 25,
                      ),
                    )
                  : SizedBox(width: 25, height: 25),
              SizedBox(width: 16.0),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(width: 5),
            ],
          ),
          Spacer(),
          Divider(
            thickness: 0.5,
            height: 0.5,
            color: Colors.black.withOpacity(0.2),
          ),
        ],
      ),
    );
  }
}
