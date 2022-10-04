import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/online_status_cubit/online_status_cubit.dart';

class OnlineStatusCircle extends StatelessWidget {
  final String channelId;
  final double size;
  const OnlineStatusCircle(
      {required this.channelId, required this.size, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnlineStatusCubit, OnlineStatusState>(
      bloc: Get.find<OnlineStatusCubit>(),
      builder: (context, state) {
        final statusList = Get.find<OnlineStatusCubit>().isConnected(channelId);
        return state.onlineStatus == OnlineStatus.success && statusList[0]
            ? Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF5AD439),
                    border: Border.all(
                        width: 3,
                        color: Theme.of(context).scaffoldBackgroundColor)),
              )
            : Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF818C99),
                    border: Border.all(
                        width: 3,
                        color: Theme.of(context).scaffoldBackgroundColor)),
              );
      },
    );
  }
}
