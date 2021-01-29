import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twake/repositories/add_channel_repository.dart';
import 'package:twake/widgets/sheets/radio_item.dart';
import 'package:twake/widgets/sheets/sheet_title_bar.dart';
import 'package:twake/blocs/add_channel/add_channel_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChannelGroupsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var groups = [
      'Transactions department',
      'Tax advisory',
      'Mckinsey partners',
      'M&A deals',
    ];

    var selectedIndex = 0;

    return Column(
      children: [
        SheetTitleBar(
          title: 'Existing channel groups',
          leadingTitle: 'Back',
          leadingAction: () =>
              context.read<AddChannelBloc>().add(SetFlowStage(FlowStage.info)),
          trailingTitle: 'Save',
          trailingAction: () =>
              context.read<AddChannelBloc>().add(SetFlowStage(FlowStage.info)),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: groups.length,
          itemBuilder: (context, index) {
            return RadioItem(
              title: groups[index],
              selected: selectedIndex == index,
              onTap: () => selectedIndex = index,
            );
          },
        ),
      ],
    );
  }
}
