import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/mentions_cubit/mentions_cubit.dart';
import 'package:twake/config/dimensions_config.dart';

class MentionSheet extends StatelessWidget {
  const MentionSheet({Key? key, required this.onTapMention}) : super(key: key);
  final void Function(String) onTapMention;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MentionsCubit, MentionState>(
      bloc: Get.find<MentionsCubit>(),
      builder: (context, state) {
        if (state is MentionsLoadSuccess) {
          final List<Widget> _listW = [];
          _listW.add(Divider(thickness: 1));
          for (int i = 0; i < state.accounts.length; i++) {
            _listW.add(
              InkWell(
                child: Container(
                  alignment: Alignment.center,
                  height: 40.0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(width: 15),
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        child: CircleAvatar(
                          child: state.accounts[i].picture! == ""
                              ? CircleAvatar(
                                  child: Icon(Icons.person,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                )
                              : Image.network(
                                  state.accounts[i].picture!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stack) =>
                                      Container(),
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) {
                                      return child;
                                    }

                                    return CircleAvatar(
                                      child: Icon(Icons.person,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                    );
                                  },
                                ),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          '${state.accounts[i].fullName} ',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .headline1!
                              .copyWith(
                                  fontSize: 16, fontWeight: FontWeight.w300),
                        ),
                      ),
                      SizedBox(width: 15),
                    ],
                  ),
                ),
                onTap: () {
                  Get.find<MentionsCubit>().reset();

                  onTapMention(state.accounts[i].username);
                },
              ),
            );
            if (i < state.accounts.length - 1) {
              _listW.add(Divider(thickness: 1));
            }
            _listW.add(const SizedBox(height: 6));
          }
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: Dim.heightPercent(30),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _listW,
              ),
            ),
          );
        } else if (state is MentionsInitial) {
          return SizedBox.shrink();
        }
        return SizedBox.shrink();
      },
    );
  }
}
