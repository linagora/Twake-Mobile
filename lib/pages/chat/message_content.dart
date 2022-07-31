import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/file_cubit/file_upload_transition_cubit.dart';
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

  MessageContent({
    required this.message,
    required this.isThread,
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
    final fileTransitionState = Get.find<FileUploadTransitionCubit>().state;
    final bool _isFileUploading = Get.find<FileUploadTransitionCubit>()
                .state
                .fileUploadTransitionStatus ==
            FileUploadTransitionStatus.uploadingMessageSent
        ? fileTransitionState.messages.first.id == widget.message.id
            ? true
            : false
        : false;

    return Expanded(
      child: Row(
        mainAxisAlignment: widget.isMyMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          widget.isMyMessage
              ? SizedBox.shrink()
              : widget.isSenderHidden
                  ? const SizedBox(
                      width: 36,
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
              child: _buildMessageBubble(
            _isFileUploading,
          )),
        ],
      ),
    );
  }

  _buildMessageBubble(
    bool _isFileUploading,
  ) {
    return Container(
      decoration: BoxDecoration(
          color: Get.isDarkMode
              ? widget.isMyMessage
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).iconTheme.color
              : widget.isMyMessage
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).iconTheme.color,
          borderRadius: BorderRadius.all(Radius.circular(18))),
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserName(),
            Container(
              decoration: BoxDecoration(
                border: widget.message.responsesCount > 0 ||
                        widget.message.reactions.length != 0
                    ? Border(
                        bottom: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
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
    final double _sizeOfReplyBox = widget.message.text.length.toDouble() < 15
        ? 80 - widget.message.text.length.toDouble() * 5.5
        : 5;
    return Padding(
      padding: widget.isMyMessage
          ? EdgeInsets.only(bottom: 0)
          : EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _sizeOfReplyBox,
          ),
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

  _buildPin() {
    return widget.message.pinnedInfo != null
        ? Padding(
            padding: const EdgeInsets.only(bottom: 1),
            child: Image.asset(
              imagePinned,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
              width: 12.0,
              height: 12.0,
            ),
          )
        : SizedBox.shrink();
  }

  _buildMessageSentStatus(bool _isMyMessage) {
    return _isMyMessage == true
        ? widget.message.delivery == Delivery.inProgress
            ? Image.asset(
                imageMessageDeliveryInprogress,
                height: 16,
                width: 16,
              )
            : widget.message.delivery == Delivery.delivered
                ? Image.asset(
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

  _buildMessageText() {
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
                      isSwipe: false)
                  .message,
        ),
      ],
    );
  }

  _buildTime() {
    return Text(
        widget.message.inThread
            ? DateFormatter.getVerboseDateTime(widget.message.createdAt)
            : DateFormatter.getVerboseTime(widget.message.createdAt),
        textAlign: TextAlign.end,
        style: Theme.of(context)
            .textTheme
            .headline3!
            .copyWith(fontSize: 12, fontWeight: FontWeight.w400));
  }

  _buildReplies() {
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
      padding: const EdgeInsets.only(bottom: 12, left: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: avatars == []
                ? ImageWidget(
                    imageType: ImageType.common,
                    avatars: avatars,
                    size: 62,
                    stackSize: 28,
                    stackNumLimit: 3,
                  )
                : SizedBox.shrink(),
          ),
          Text(
              '${AppLocalizations.of(context)!.replyPlural(widget.message.responsesCount)}',
              style: Get.isDarkMode
                  ? Theme.of(context)
                      .textTheme
                      .headline1!
                      .copyWith(fontSize: 17, fontWeight: FontWeight.bold)
                  : Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(fontSize: 17, fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  _buildUserName() {
    return widget.isMyMessage
        ? SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${widget.message.sender}',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: HSLColor.fromAHSL(
                        1, widget.message.username.hashCode % 360, 0.9, 0.3)
                    .toColor(),
              ),
            ),
          );
  }

  _buildFileUploadingTile() {
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

  _buildReactions(bool _isMyMessage) {
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
