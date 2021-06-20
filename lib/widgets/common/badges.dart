import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/badges_cubit/badges_cubit.dart';
import 'package:twake/blocs/badges_cubit/badges_state.dart';
import 'package:twake/models/badge/badge.dart';

class BadgesCount extends StatelessWidget {
  final BadgeType badgeType;
  final String id;

  BadgesCount(this.badgeType, this.id);

  @override
  Widget build(BuildContext context) {
    int counter = 0;
    return Row(
      children: <Widget>[
        Text('Channels'),
        SizedBox(
          width: 5,
          height: 5,
        ),
        BlocBuilder<BadgesCubit, BadgesState>(
          bloc: Get.find<BadgesCubit>(),
          builder: (ctx, state) {
            if (state is BadgesLoadSuccess) {
              state.badges.forEach(
                (badge) {
                  badge.matches(type: badgeType, id: id)
                      ? counter = badge.count
                      : counter = 0;
                },
              );
            }
            return state is BadgesLoadSuccess && counter != 0
                ? Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF004DFF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 3,
                        ),
                        counter < 999
                            ? Text(
                                '$counter',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              )
                            : Text(
                                ' 999 ',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                        SizedBox(
                          width: 3,
                        ),
                      ],
                    ),
                  )
                : Container();
          },
        ),
      ],
    );
  }
}
