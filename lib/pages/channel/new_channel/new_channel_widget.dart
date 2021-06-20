import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/pages/channel/selectable_channel_type_widget.dart';
import 'package:twake/widgets/common/rounded_image.dart';

class NewChannelWidget extends StatelessWidget {
  const NewChannelWidget() : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xfff2f2f6),
        child: Column(
          children: [
            Container(
              color: Colors.white,
              height: 56,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CupertinoButton(
                      onPressed: () {},
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xff000000),
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: CupertinoButton(
                      onPressed: () {},
                      child: Text(
                        'Create',
                        style: TextStyle(
                          color: Color(0xff004dff),
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "New channel",
                      style: TextStyle(
                        color: Color(0xff000000),
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Divider(
              color: Color(0x1e000000),
              height: 1,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 16, bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                height: 80,
                // color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      RoundedImage(
                        width: 56,
                        height: 56,
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Expanded(child: TextFormField()),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 28, right: 28, bottom: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    'Please provide a channel name and optional channel icon',
                    style: TextStyle(
                      color: Color(0xff969ca4),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                height: 48,
                child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: TextField(),
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 28, right: 28, bottom: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    'Please provide an optional decription for your channel',
                    style: TextStyle(
                      color: Color(0xff969ca4),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("CHANNEL TYPE",
                    style: TextStyle(
                      color: Color(0xff969ca4),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 16, right: 16),
              child: SelectableChannelTypeWidget(
                channelVisibility: ChannelVisibility.public,
                onSelectableChannelTypeClick: (channelVisibility) {
                  // todo
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 28, right: 28, bottom: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    'Public channels can be found by everyone, though private can only be joined by invitation',
                    style: TextStyle(
                      color: Color(0xff969ca4),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("INVITED MEMBERS (3)",
                    style: TextStyle(
                      color: Color(0xff969ca4),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
