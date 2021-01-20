import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/widgets/common/selectable_avatar.dart';
import 'package:twake/widgets/sheets/channel_info_text_form.dart';

class ChannelNameContainer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const ChannelNameContainer({
    Key key,
    @required this.controller,
    @required this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: 83.0,
      width: MediaQuery.of(context).size.width,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        color: Colors.white,
        child: ChannelInfoTextForm(
          hint: 'Channel name',
          controller: controller,
          focusNode: focusNode,
        ),
        // child: Row(
        //   children: [
        //     // Expanded(child: SelectableAvatar()),
        //     Expanded(
        //       flex: 3,
        //       child: ChannelInfoTextForm(
        //         hint: 'Channel name',
        //         controller: controller,
        //         focusNode: focusNode,
        //       ),
        //     ),
        //     SizedBox(width: 10.0),
        //   ],
        // ),
      ),
    );
  }
}
