import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/gallery_cubit/gallery_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/blocs/pinned_message_cubit/pinned_messsage_cubit.dart';
import 'package:twake/config/dimensions_config.dart' show Dim;
import 'package:twake/config/image_path.dart';
import 'package:twake/models/channel/channel.dart';
import 'package:twake/models/message/message.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/utils/dateformatter.dart';
import 'package:twake/utils/twacode.dart';
import 'package:twake/utils/utilities.dart';
import 'package:twake/widgets/common/image_widget.dart';
import 'package:twake/widgets/common/reaction.dart';
import 'package:twake/widgets/message/resend_modal_sheet.dart';

class MessageContent<T extends BaseMessagesCubit> extends StatefulWidget {
  final Message message;
  final bool isThread;
  final bool isMyMessage;
  final bool isDirect;
  final bool isSenderHidden;
  final bool isHeadInThred;

  MessageContent({
    required this.message,
    required this.isThread,
    required this.isHeadInThred,
    required this.isDirect,
    required this.isMyMessage,
    required this.isSenderHidden,
    Key? key,
  }) : super(key: key);

  @override
  _MessageContentState createState() => _MessageContentState<T>();
}

class _MessageContentState<T extends BaseMessagesCubit>
    extends State<MessageContent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /*final fileTransitionState = Get.find<FileTransitionCubit>().state;
    final bool _isFileUploading = Get.find<FileTransitionCubit>()
                .state
                .fileTransitionStatus ==
            FileTransitionStatus.uploadingMessageSent
        ? fileTransitionState.messages.first.id == widget.message.id
            ? true
            : false
        : false;*/

    return Expanded(
      child: Row(
        mainAxisAlignment: widget.isMyMessage || widget.isHeadInThred
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          widget.isMyMessage
              ? SizedBox.shrink()
              : widget.isSenderHidden
                  ? const SizedBox(
                      width: 42,
                    )
                  : Padding(
                      padding: const EdgeInsets.only(
                          left: 2, right: 6, bottom: 6, top: 2),
                      child: ImageWidget(
                          imageType: ImageType.common,
                          imageUrl: widget.message.picture ?? '',
                          name: widget.message.sender,
                          size: 36),
                    ),
          Flexible(
            child: _buildMessageBubble(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble() {
    return Container(
      decoration: BoxDecoration(
          color: Get.isDarkMode
              ? widget.isMyMessage
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.secondaryContainer
              : widget.isMyMessage
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).cardColor,
          borderRadius: BorderRadius.all(Radius.circular(18))),
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserName(),
            Container(
              decoration: BoxDecoration(
                border: (widget.message.responsesCount > 0 ||
                            widget.message.reactions.length != 0) &&
                        !widget.isThread
                    ? Border(
                        bottom: BorderSide(
                          color: Get.isDarkMode
                              ? widget.isMyMessage
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                      .withOpacity(0.5)
                                  : Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.secondary,
                          width: 0.5,
                        ),
                      )
                    : Border(),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildMessageText(),
                      _buildStatuses(),
                    ]),
              ),
            ),
            _buildReactions(widget.isMyMessage),
            if (widget.message.responsesCount > 0 && !widget.isThread)
              _buildReplies(),
          ],
        ),
      ),
    );
  }

  _buildStatuses() {
    return Padding(
      padding: widget.isMyMessage
          ? EdgeInsets.only(bottom: 0)
          : EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 3),
            child: _buildPin(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 3, right: 3),
            child: _buildTime(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: _buildMessageSentStatus(widget.isMyMessage),
          ),
        ],
      ),
    );
  }

  Widget _buildPin() {
    return widget.message.pinnedInfo != null
        ? Padding(
            padding: const EdgeInsets.only(bottom: 1),
            child: Image.asset(
              imagePinned,
              color: Get.isDarkMode
                  ? widget.isMyMessage
                      ? Colors.white.withOpacity(0.7)
                      : Colors.white.withOpacity(0.3)
                  : Theme.of(context).colorScheme.secondary.withOpacity(0.8),
              width: 12.0,
              height: 12.0,
            ),
          )
        : SizedBox.shrink();
  }

  Widget _buildMessageSentStatus(bool _isMyMessage) {
    return _isMyMessage == true
        ? widget.message.delivery == Delivery.inProgress
            ? Get.isDarkMode
                ? Image.asset(
                    imageMessageDeliveryInprogress,
                    height: 18,
                    width: 18,
                    color: Colors.white.withOpacity(0.6),
                  )
                : Image.asset(
                    imageMessageDeliveryInprogress,
                    height: 18,
                    width: 18,
                  )
            : widget.message.delivery == Delivery.delivered
                ? Get.isDarkMode
                    ? Image.asset(
                        imageMessageDeliveryRead,
                        height: 18,
                        width: 18,
                        color: Colors.white.withOpacity(0.9),
                      )
                    : Image.asset(
                        imageMessageDeliveryRead,
                        height: 18,
                        width: 18,
                      )
                : widget.message.delivery == Delivery.failed
                    ? GestureDetector(
                        onTap: () async {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) {
                              return ResendModalSheet(
                                message: widget.message,
                                isThread: widget.isThread,
                              );
                            },
                          );
                        },
                        child: Icon(
                          CupertinoIcons.exclamationmark_circle_fill,
                          color: Theme.of(context).colorScheme.error,
                          size: 18,
                        ),
                      )
                    : SizedBox.shrink()
        : SizedBox.shrink();
  }

  Widget _buildMessageText() {
    final double _sizeOfReplyBox = widget.message.text.length.toDouble() < 20 &&
            (widget.message.files != null && widget.message.files!.isEmpty)
        ? 150 - widget.message.text.length.toDouble() * 7
        : 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: widget.message.subtype == MessageSubtype.deleted
              ? Text(
                  AppLocalizations.of(context)!.messageDeleted,
                  style: Theme.of(context).textTheme.headline1!,
                )
              : TwacodeRenderer(
                  twacode: widget.message.blocks.length == 0
                      ? [widget.message.text]
                      : widget.message.blocks,
                  fileIds: widget.message.files,
                  parentStyle: Theme.of(context).textTheme.headline1!,
                  userUniqueColor: widget.message.username.hashCode % 360,
                ).message,
        ),
        SizedBox(
          width: _sizeOfReplyBox,
        ),
      ],
    );
  }

  Widget _buildTime() {
    return Text(
        widget.message.inThread
            ? DateFormatter.getVerboseDateTime(widget.message.createdAt)
            : DateFormatter.getVerboseTime(widget.message.createdAt),
        textAlign: TextAlign.end,
        style: Get.isDarkMode
            ? widget.isMyMessage
                ? Theme.of(context)
                    .textTheme
                    .headline1!
                    .copyWith(fontSize: 12, fontWeight: FontWeight.w400)
                : Theme.of(context)
                    .textTheme
                    .headline3!
                    .copyWith(fontSize: 12, fontWeight: FontWeight.w400)
            : Theme.of(context)
                .textTheme
                .headline3!
                .copyWith(fontSize: 12, fontWeight: FontWeight.w400));
  }

  Widget _buildReplies() {
    final List<Message>? last3Replies = widget.message.last3Replies;
    final List<Avatar> avatars = [];
    if (last3Replies != null) {
      last3Replies.forEach((message) {
        message.picture != null || message.username != null
            ? avatars.add(Avatar(
                link: message.picture ?? '', name: message.username ?? ''))
            : null;
      });
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 12, right: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: avatars != []
                ? ImageWidget(
                    imageType: ImageType.common,
                    avatars: avatars,
                    size: avatars.length == 1
                        ? 28
                        : (22 * avatars.length).toDouble(),
                    stackSize: 28,
                    stackNumLimit: 3,
                  )
                : SizedBox.shrink(),
          ),
          Text(
              '${AppLocalizations.of(context)!.replyPlural(widget.message.responsesCount)}',
              style: Get.isDarkMode
                  ? widget.isMyMessage
                      ? Theme.of(context)
                          .textTheme
                          .headline1!
                          .copyWith(fontSize: 17, fontWeight: FontWeight.w400)
                      : Theme.of(context)
                          .textTheme
                          .headline4!
                          .copyWith(fontSize: 17, fontWeight: FontWeight.w400)
                  : Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(fontSize: 17, fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  Widget _buildUserName() {
    return widget.isMyMessage
        ? SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 2),
            child: Text(
              '${widget.message.sender}',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: HSLColor.fromAHSL(
                        1,
                        widget.message.username.hashCode % 360,
                        0.9,
                        Get.isDarkMode ? 0.4 : 0.3)
                    .toColor(),
              ),
            ),
          );
  }

  Widget _buildFileUploadingTile() {
    return BlocBuilder<GalleryCubit, GalleryState>(
      bloc: Get.find<GalleryCubit>(),
      builder: (context, state) {
        return Container(
          constraints: BoxConstraints(maxHeight: 350),
          child: Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                itemCount: state.selectedFilesIndex.length,
                itemBuilder: (_, index) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 220,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.memory(
                              state.assetsList[state.selectedFilesIndex[index]],
                              fit: BoxFit.fill,
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Theme.of(context)
                                              .iconTheme
                                              .color!
                                              .withOpacity(0.8),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                        left: 5,
                                        bottom: 5,
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          ),
        );
      },
    );
  }

  Widget _buildReactions(bool _isMyMessage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      child: Wrap(
        runSpacing: Dim.heightMultiplier,
        crossAxisAlignment: WrapCrossAlignment.center,
        textDirection: TextDirection.ltr,
        children: [
          ...widget.message.reactions.map((r) {
            return Reaction<T>(
              message: widget.message,
              reaction: r,
              isMyMessage: widget.isMyMessage,
            );
          }),
        ],
      ),
    );
  }

  void onReply(Message message) {
    NavigatorService.instance.navigate(
      channelId: message.channelId,
      threadId: message.id,
      reloadThreads: false,
    );
  }

  void onEdit(Message message) {
    widget.isThread
        ? Get.find<ThreadMessagesCubit>().startEdit(message: widget.message)
        : Get.find<ChannelMessagesCubit>().startEdit(message: widget.message);
    Navigator.of(context).pop();
  }

  void onDelete() {
    widget.isThread
        ? Get.find<ThreadMessagesCubit>().delete(message: widget.message)
        : Get.find<ChannelMessagesCubit>().delete(message: widget.message);
    Navigator.of(context).pop();
  }

  void onCopy({required context, required text}) {
    FlutterClipboard.copy(text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: EdgeInsets.fromLTRB(
          15.0,
          5.0,
          15.0,
          65.0,
          //  Dim.heightPercent(8),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 1500),
        content: Row(
          children: [
            Icon(
              Icons.copy,
              color: Theme.of(context).colorScheme.secondary,
            ),
            SizedBox(
              width: 20,
            ),
            Text(AppLocalizations.of(context)!.messageCopiedInfo,
                style: Theme.of(context)
                    .textTheme
                    .headline1!
                    .copyWith(fontSize: 14)),
          ],
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  void onPinMessage() async {
    Get.find<PinnedMessageCubit>()
        .pinMessage(message: widget.message, isDirect: widget.isDirect);
    Navigator.of(context).pop();
  }

  void onUnpinMessage() async {
    final bool result = await Get.find<PinnedMessageCubit>()
        .unpinMessage(message: widget.message);
    Navigator.of(context).pop();
    if (!result)
      Utilities.showSimpleSnackBar(
          context: context,
          message: AppLocalizations.of(context)!.somethingWentWrong);
  }
}
