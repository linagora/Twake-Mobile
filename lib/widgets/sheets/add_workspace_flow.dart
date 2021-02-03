import 'package:flutter/material.dart';
import 'package:twake/widgets/sheets/participants_list.dart';

class AddWorkspaceFlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ParticipantsList(isDirect: true);
  }
}
