import 'package:flutter/material.dart';
import 'package:twake/widgets/common/rounded_image.dart';

class HomeChannelTile extends StatelessWidget {
  const HomeChannelTile() : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          children: [
            SizedBox(
              width: 10,
            ),
            Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: RoundedImage(
                    width: 54,
                    height: 54,
                  ),
                )
              ],
            ),
            SizedBox(
              width: 11,
            ),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text("Entertainment",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.normal,
                              ))),
                      Text("15:47",
                          style: TextStyle(
                            color: Color(0xffc2c6cc),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.normal,
                          ))
                    ],
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Alexey Kondratiev',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: Color(0xb2000000),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                        )),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Let’s schedule a team building',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: Color(0x7f000000),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                        )),
                  )
                ],
              ),
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
    );
  }
}
