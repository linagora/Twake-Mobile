import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/add_channel_bloc.dart';
import 'package:twake/repositories/add_channel_repository.dart';
import 'package:twake/widgets/sheets/channel_info_form.dart';
import 'package:twake/widgets/sheets/channel_type_form.dart';

class AddChannelFlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddChannelBloc, AddChannelState>(
        builder: (context, state) {
      var i = 1;
      if (state is StageUpdated) {
        switch (state.stage) {
          case FlowStage.info:
            i = 0;
            break;
          case FlowStage.groups:
            i = 1;
            break;
          case FlowStage.type:
            i = 2;
            break;
          case FlowStage.participants:
            i = 3;
            break;
        }
      }
      return IndexedStack(
        index: i,
        children: [
          ChannelInfoForm(),
          ChannelTypeForm(),
        ],
      );
    });
  }
}
