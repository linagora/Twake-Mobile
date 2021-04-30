import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/pages/profile/edit_profile.dart';
import 'package:twake/pages/profile/profile.dart';

class ProfileFlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profileFlowWidgets = [
      Profile(),
      EditProfile(),
    ];
    return BlocBuilder<AccountCubit, AccountState>(
      buildWhen: (_, current) => current is AccountFlowStageUpdated,
      builder: (context, state) {
        var i = 0;
        if (state is AccountFlowStageUpdated) {
          // print('Current stage: ${state.stage}');
          switch (state.stage) {
            case AccountFlowStage.info:
              i = 0;
              break;
            case AccountFlowStage.edit:
              i = 1;
              break;
          }
        }
        return SingleChildScrollView(
          child: IndexedStack(
            index: i,
            children: profileFlowWidgets,
          ),
        );
      },
    );
  }
}
