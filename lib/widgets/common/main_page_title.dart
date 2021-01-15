import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/sheet_bloc.dart';
import 'package:twake/config/dimensions_config.dart';

class MainPageTitle extends StatelessWidget {
  final String title;

  const MainPageTitle({
    Key key,
    @required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Function trailingAction;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headline3,
        ),
        BlocBuilder<SheetBloc, SheetState>(
          builder: (context, state) {
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
              onPressed: () => trailingAction?.call(),
            );
          }
        ),
      ],
    );
  }
}
