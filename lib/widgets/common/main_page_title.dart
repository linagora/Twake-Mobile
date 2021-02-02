import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/add_channel_bloc/add_channel_bloc.dart';
import 'package:twake/blocs/sheet_bloc/sheet_bloc.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/repositories/add_channel_repository.dart';

class MainPageTitle extends StatelessWidget {
  final String title;
  final bool isDirect;

  const MainPageTitle({
    Key key,
    @required this.title,
    this.isDirect = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Function trailingAction;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Color(0xff444444),
          ),
        ),
        BlocBuilder<SheetBloc, SheetState>(builder: (context, state) {
          if (state is SheetClosed || state is SheetInitial) {
            trailingAction = () => context.read<SheetBloc>().add(OpenSheet());
          } else {
            trailingAction = () => context.read<SheetBloc>().add(CloseSheet());
          }
          return IconButton(
            icon: Icon(
              Icons.add,
              size: Dim.tm3(decimal: .3),
              color: Colors.black,
            ),
            onPressed: () {
              // Let's provide a different experience to channel creation flow
              // by preselecting desired type
              // according the title opposite plus button
              if (isDirect) {
                context.read<AddChannelBloc>().add(SetFlowType(isDirect: true));
              } else {
                context
                    .read<AddChannelBloc>()
                    .add(Update(type: ChannelType.public));
                context.read<AddChannelBloc>().add(SetFlowType(isDirect: false));
              }
              trailingAction?.call();
            },
          );
        }),
      ],
    );
  }
}
