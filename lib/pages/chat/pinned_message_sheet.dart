import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:twake/blocs/pinned_message_cubit/pinned_messsage_cubit.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/routing/route_paths.dart';
import 'package:twake/utils/utilities.dart';

class PinnedMessageSheet extends StatefulWidget {
  final Channel channel;
  const PinnedMessageSheet({required this.channel, Key? key}) : super(key: key);

  @override
  State<PinnedMessageSheet> createState() => _PinnedMessageSheetState();
}

class _PinnedMessageSheetState extends State<PinnedMessageSheet> {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
  }

  void _unpinMessage(Message message, context) async {
    final bool result =
        await Get.find<PinnedMessageCubit>().unpinMessage(message: message);
    if (!result)
      Utilities.showSimpleSnackBar(
          context: context,
          message: AppLocalizations.of(context)!.somethingWentWrong);
  }

  void _selectPinnedMessage(PinnedMessageState state) {
    final bool result = Get.find<PinnedMessageCubit>().selectPinnedMessage();
    final selected = state.pinnedMessageList.length - 1 == state.selected
        ? 0
        : state.selected + 1;
    if (result)
      itemScrollController.scrollTo(
          index: selected,
          duration: Duration(milliseconds: 700),
          curve: Curves.linear);
    Get.find<PinnedMessageCubit>().jumpToPinnedMessage(
        message: state.pinnedMessageList[selected],
        isDirect: widget.channel.isDirect);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PinnedMessageCubit, PinnedMessageState>(
        bloc: Get.find<PinnedMessageCubit>(),
        builder: (ctx, state) {
          if (state.pinnedMesssageStatus == PinnedMessageStatus.finished) {
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    width: Get.isDarkMode ? 0 : 0.5,
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.3),
                  ),
                ),
              ),
              alignment: Alignment.centerLeft,
              height: 56,
              width: Dim.widthPercent(99),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 9,
                    child: ScrollablePositionedList.builder(
                      shrinkWrap: true,
                      addAutomaticKeepAlives: true,
                      key: PageStorageKey("uniq"),
                      itemCount: state.pinnedMessageList.length,
                      itemBuilder: (context, index) => _scrollBarTile(
                          index,
                          state.selected,
                          state.pinnedMessageList.length,
                          context),
                      itemPositionsListener: itemPositionsListener,
                      itemScrollController: itemScrollController,
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 8),
                            child: Text(
                              AppLocalizations.of(context)!.pinnedMessages,
                              style: Get.theme.textTheme.headline4!.copyWith(
                                  fontSize: 14, fontWeight: FontWeight.w300),
                            ),
                          ),
                          _pinnedMessagesTile(
                              state.pinnedMessageList[state.selected]),
                        ]),
                    onTap: () => _selectPinnedMessage(state),
                  ),
                  Spacer(),
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5, right: 2),
                      child: state.pinnedMessageList.length == 1
                          ? Icon(
                              Icons.clear,
                              color: Theme.of(context).colorScheme.surface,
                            )
                          : Image.asset(
                              imageListPinned,
                              color: Theme.of(context).colorScheme.surface,
                              height: 30,
                              width: 30,
                            ),
                    ),
                    onTap: () => state.pinnedMessageList.length == 1
                        ? _unpinMessage(
                            state.pinnedMessageList[state.selected], context)
                        : push(
                            RoutePaths.channelPinnedMessages.path,
                          ),
                  )
                ],
              ),
            );
          }
          return SizedBox.shrink();
        });
  }

  Widget _pinnedMessagesTile(Message message) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Container(
        width: Dim.widthPercent(85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: Container(
                constraints: BoxConstraints(
                    maxWidth: Dim.widthPercent(85), maxHeight: 22),
                child: Text(
                  '${message.text == "" && message.files != null ? "The message contains only file data" : message.text}',
                  style: Get.theme.textTheme.headline1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scrollBarTile(
      int index, int selected, int length, BuildContext context) {
    if (length == 1) {
      return Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14.0),
          ),
          height: 50,
        ),
      );
    } else if (length == 2) {
      return Padding(
        padding: const EdgeInsets.all(2.0),
        child: index == selected
            ? Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14.0),
                ),
                height: 25,
              )
            : Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(14.0),
                ),
                height: 25,
              ),
      );
    } else if (length == 3) {
      return Padding(
        padding: const EdgeInsets.all(2.0),
        child: index == selected
            ? Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14.0),
                ),
                height: 15,
              )
            : Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(14.0),
                ),
                height: 15,
              ),
      );
    } else
      return Padding(
        padding: const EdgeInsets.all(2.0),
        child: index == selected
            ? Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14.0),
                ),
                height: 14,
              )
            : Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(14.0),
                ),
                height: 14,
              ),
      );
  }
}
