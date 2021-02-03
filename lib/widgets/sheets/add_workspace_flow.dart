import 'package:flutter/material.dart';
import 'package:twake/widgets/sheets/channel_participants_list.dart';

class AddWorkspaceFlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChannelParticipantsList(isDirect: true);
  }
}
