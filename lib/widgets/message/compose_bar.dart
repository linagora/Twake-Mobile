import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twake/blocs/camera_cubit/camera_cubit.dart';
import 'package:twake/blocs/file_cubit/file_transition_cubit.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_cubit.dart';
import 'package:twake/blocs/file_cubit/upload/file_upload_state.dart';
import 'package:twake/blocs/gallery_cubit/gallery_cubit.dart';
import 'package:twake/blocs/mentions_cubit/mentions_cubit.dart';
import 'package:twake/blocs/messages_cubit/messages_cubit.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/models/file/file.dart';
import 'package:twake/models/file/message_file.dart';
import 'package:twake/models/file/upload/file_uploading.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/pages/chat/gallery/gallery_view.dart';
import 'package:twake/utils/constants.dart';
import 'package:twake/utils/extensions.dart';
import 'package:twake/utils/utilities.dart';
import 'package:twake/widgets/common/twake_alert_dialog.dart';

class ComposeBar extends StatefulWidget {
  final bool autofocus;
  final Function(String, BuildContext) onMessageSend;
  final Function(String, BuildContext) onTextUpdated;
  final String? initialText;

  ComposeBar({
    required this.onMessageSend,
    required this.onTextUpdated,
    this.autofocus = false,
    this.initialText = '',
  });

  @override
  _ComposeBar createState() => _ComposeBar();
}

class _ComposeBar extends State<ComposeBar> {
  final _userMentionRegex = RegExp(r'(^|\s)@[A-Za-z0-9._-]+$');
  var _emojiVisible = false;
  var _mentionsVisible = false;
  var _forceLooseFocus = false;
  var _canSend = false;
  var _canSendFiles = false;

  final _focusNode = FocusNode();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    widget.onTextUpdated(widget.initialText ?? '', context);
    if (widget.initialText?.isNotReallyEmpty ?? false) {
      _controller.text = widget.initialText!; // possibly retrieved from cache.
      setState(() {
        _canSend = true;
      });
    }

    _focusNode.addListener(() {
      if (_focusNode.hasPrimaryFocus)
        setState(() {
          _emojiVisible = false;
        });
    });

    _controller.addListener(() {
      if (_controller.selection.base.offset < 0) return;

      var text = _controller.text;
      text = text.substring(0, _controller.selection.base.offset);
      if (_userMentionRegex.hasMatch(text)) {
        Get.find<MentionsCubit>().fetch(
          searchTerm: text.split('@').last.trimRight(),
        );
        Future.delayed(const Duration(milliseconds: 100), () {
          mentionsVisible();
        });
      } else {
        setState(() {
          _mentionsVisible = false;
        });
      }
      // Update for cache handlers
      widget.onTextUpdated(text, context);

      // Set Send button state by combination of checking text and file uploading
      _setSendButtonState(
          stateWithoutFileUploading: _controller.text.isNotReallyEmpty);
    });

    Get.find<ChannelMessagesCubit>().stream.listen((state) {
      final uploadState = Get.find<FileUploadCubit>().state;
      final transitionState = Get.find<FileTransitionCubit>().state;

      if (state is MessagesLoadSuccess &&
          transitionState.fileTransitionStatus ==
              FileTransitionStatus.messageInprogressFileLoading) {
        Get.find<FileTransitionCubit>().messageSentFileLoading(state.messages);
      }

      if (state is MessageEditInProgress &&
          transitionState.fileTransitionStatus ==
              FileTransitionStatus.messageSentFileLoading) {
        // attacing the file to the message when it is well uploaded
        List<dynamic> attachments = uploadState.listFileUploading
            .where((fileUploading) => (fileUploading.file != null ||
                fileUploading.messageFile != null))
            .map((e) => e.messageFile != null
                ? e.messageFile!.toAttachment()
                : e.file!.toAttachment())
            .toList();
        Globals.instance.threadId == null
            ? Get.find<ChannelMessagesCubit>().edit(
                message: transitionState.messages.first,
                editedText: transitionState.messages.first.text,
                newAttachments: attachments)
            : Get.find<ThreadMessagesCubit>().edit(
                message: transitionState.messages.first,
                editedText: transitionState.messages.first.text,
                newAttachments: attachments);

        // start clearing
        Get.find<FileUploadCubit>().closeListUploadingStream();
        Get.find<FileUploadCubit>().clearFileUploadingState();
        Get.find<FileTransitionCubit>().fileTransitionFinished();
      }
    });

    Get.find<FileUploadCubit>().stream.listen((state) {
      final transitionCubitState = Get.find<FileTransitionCubit>().state;
      final hasUploadedFileInStack = state.listFileUploading.every(
          (element) => element.uploadStatus == FileItemUploadStatus.uploaded);

      if (hasUploadedFileInStack &&
          transitionCubitState.fileTransitionStatus ==
              FileTransitionStatus.messageSentFileLoading) {
        Get.find<FileTransitionCubit>().startMessageEditting();
      }

      if (hasUploadedFileInStack &&
          transitionCubitState.fileTransitionStatus ==
              FileTransitionStatus.messageEmptyFileLoading) {
        // if file sent without a text, wait till it is well loaded and send an empty message with a file
        List<dynamic> attachments = state.listFileUploading
            .where((fileUploading) => (fileUploading.file != null ||
                fileUploading.messageFile != null))
            .map((e) => e.messageFile != null
                ? e.messageFile!.toAttachment()
                : e.file!.toAttachment())
            .toList();
        Globals.instance.threadId == null
            ? Get.find<ChannelMessagesCubit>().send(
                originalStr: "",
                attachments: attachments,
                isDirect: false,
              )
            : Get.find<ThreadMessagesCubit>().send(
                originalStr: "",
                attachments: attachments,
                isDirect: false,
              );
        // start clearing
        Get.find<FileUploadCubit>().closeListUploadingStream();
        Get.find<FileUploadCubit>().clearFileUploadingState();
        Get.find<FileTransitionCubit>().fileTransitionFinished();
      }
    });
  }

  // TODO get rid of _mentionsVisible since can use states of new MentionsCubit
  void mentionsVisible() async {
    final MentionState mentionsState = Get.find<MentionsCubit>().state;
    if (mentionsState is MentionsLoadSuccess) {
      setState(() {
        _mentionsVisible = true;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ComposeBar oldWidget) {
    if (oldWidget.initialText != widget.initialText) {
      _controller.text = widget.initialText ?? '';
    }
    // print('FORCE LOOSE FOCUS: $_forceLooseFocus');
    if (widget.autofocus && !_forceLooseFocus) {
      _focusNode.requestFocus();
    }
    super.didUpdateWidget(oldWidget);
  }

  void toggleEmojiBoard() async {
    if (_focusNode.hasPrimaryFocus) {
      _focusNode.unfocus();
      _forceLooseFocus = true;
    }
    setState(() {
      _emojiVisible = !_emojiVisible;
    });
    if (!_emojiVisible) {
      _forceLooseFocus = false;
      _focusNode.requestFocus();
    }
  }

  void swipeRequestFocus(bool _focus) {
    _focus ? _focusNode.requestFocus() : _focusNode.unfocus();
  }

  void mentionReplace(String username) async {
    var text = _controller.text;
    text = text.substring(0, _controller.selection.base.offset);
    _controller.text = _controller.text.replaceRange(
      text.lastIndexOf('@'),
      _controller.selection.base.offset,
      '@$username ',
    );
    _controller.selection = TextSelection.fromPosition(
      TextPosition(
        offset: text.lastIndexOf('@') + username.length + 2,
      ),
    );
  }

  Future<bool> onBackPress() async {
    if (_emojiVisible) {
      setState(() {
        _emojiVisible = false;
      });
    } else {
      Navigator.pop(context);
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ThreadMessagesCubit, MessagesState>(
      bloc: Get.find<ThreadMessagesCubit>(),
      listener: (context, state) {
        swipeRequestFocus(false);
      },
      child: WillPopScope(
        onWillPop: onBackPress,
        child: Column(
          children: [
            _mentionsVisible
                ? BlocBuilder<MentionsCubit, MentionState>(
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
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(30)),
                                      child: CircleAvatar(
                                        child: state.accounts[i].picture! == ""
                                            ? CircleAvatar(
                                                child: Icon(Icons.person,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary),
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .secondaryContainer,
                                              )
                                            : Image.network(
                                                state.accounts[i].picture!,
                                                fit: BoxFit.contain,
                                                loadingBuilder:
                                                    (context, child, progress) {
                                                  if (progress == null) {
                                                    return child;
                                                  }

                                                  return CircleAvatar(
                                                    child: Icon(Icons.person,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary),
                                                    backgroundColor:
                                                        Theme.of(context)
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
                                                fontSize: 16,
                                                fontWeight: FontWeight.w300),
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                  ],
                                ),
                              ),
                              onTap: () {
                                Get.find<MentionsCubit>().reset();

                                mentionReplace(state.accounts[i].username);
                                setState(
                                  () {
                                    _mentionsVisible = false;
                                  },
                                );
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
                        return Container();
                        //Text("Empty");
                      }
                      return Container();
                    },
                  )
                : Container(),
            TextInput(
              controller: _controller,
              scrollController: _scrollController,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              toggleEmojiBoard: toggleEmojiBoard,
              emojiVisible: _emojiVisible,
              onMessageSend: widget.onMessageSend,
              canSend: _canSend,
            ),
            Offstage(
              offstage: !_emojiVisible,
              child: Container(
                height: 250,
                child: EmojiPicker(
                  onEmojiSelected: (cat, emoji) {
                    _controller.text += emoji.emoji;
                    _setSendButtonState(stateWithoutFileUploading: true);
                  },
                  config: Config(
                    columns: 7,
                    emojiSizeMax: 32.0,
                    verticalSpacing: 0,
                    horizontalSpacing: 0,
                    initCategory: Category.RECENT,
                    bgColor: Theme.of(context).colorScheme.secondaryContainer,
                    indicatorColor: Theme.of(context).colorScheme.surface,
                    iconColor: Theme.of(context).colorScheme.secondary,
                    iconColorSelected: Theme.of(context).colorScheme.surface,
                    progressIndicatorColor:
                        Theme.of(context).colorScheme.surface,
                    showRecentsTab: true,
                    recentsLimit: 28,
                    noRecentsText: AppLocalizations.of(context)!.noRecents,
                    noRecentsStyle: Theme.of(context)
                        .textTheme
                        .headline3!
                        .copyWith(fontSize: 20),
                    categoryIcons: const CategoryIcons(),
                    buttonMode: ButtonMode.MATERIAL,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _setSendButtonState({bool stateWithoutFileUploading = false}) {
    final uploadState = Get.find<FileUploadCubit>().state;
    final listFileUploading =
        Get.find<FileUploadCubit>().state.listFileUploading;
    if (uploadState.fileUploadStatus == FileUploadStatus.inProcessing &&
        listFileUploading.isNotEmpty) {
      setState(() {
        _canSend = _canSendFiles;
      });
    } else {
      setState(() {
        _canSend = stateWithoutFileUploading;
      });
    }
  }
}

class TextInput extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ScrollController? scrollController;
  final Function? toggleEmojiBoard;
  final bool? autofocus;
  final bool? emojiVisible;
  final bool canSend;
  final Function onMessageSend;

  TextInput({
    required this.onMessageSend,
    this.controller,
    this.focusNode,
    this.autofocus,
    this.emojiVisible,
    this.scrollController,
    this.toggleEmojiBoard,
    this.canSend = false,
  });

  @override
  _TextInputState createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  final _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 11.0, bottom: 11.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: _buildAttachment(),
          ),
          Expanded(
            child: _buildMessageContent(),
          ),
          _buildSendButton(),
        ],
      ),
    );
  }

  _buildAttachment() {
    return IconButton(
      constraints: BoxConstraints(
        minHeight: 24.0,
        minWidth: 24.0,
      ),
      padding: EdgeInsets.zero,
      icon: Image.asset(imageAddFile),
      onPressed: () => _handleOpenGallery(),
      color: Theme.of(context).colorScheme.surface,
    );
  }

  _buildMessageContent() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(30.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
      ),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          _buildMessageTextField(),
          GestureDetector(
            onTap: widget.toggleEmojiBoard as void Function()?,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.asset(imageEmojiIcon, width: 24, height: 24),
            ),
          )
        ],
      ),
    );
  }

  _buildMessageTextField() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(17),
      child: _buildTextField(),
    );
  }

  _buildTextField() {
    return SizedBox(
      height: widget.controller!.text.isNotEmpty ? null : 38,
      child: TextField(
        style: Theme.of(context)
            .textTheme
            .headline1!
            .copyWith(fontSize: 17, fontWeight: FontWeight.w400),
        maxLines: 4,
        minLines: 1,
        textCapitalization: TextCapitalization.sentences,
        autofocus: widget.autofocus!,
        focusNode: widget.focusNode,
        scrollController: widget.scrollController,
        controller: widget.controller,
        keyboardAppearance: Theme.of(context).colorScheme.brightness,
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).colorScheme.secondaryContainer,
          contentPadding:
              const EdgeInsets.only(left: 12, right: 25, top: 4, bottom: 4),
          hintText: AppLocalizations.of(context)!.newReply,
          hintStyle: Theme.of(context)
              .textTheme
              .headline2!
              .copyWith(fontSize: 17, fontWeight: FontWeight.w500),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              style: BorderStyle.none,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              style: BorderStyle.none,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              style: BorderStyle.none,
            ),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
      ),
    );
  }

  _buildSendButton() {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.canSend
            ? () async {
                widget.onMessageSend(
                  await Get.find<MentionsCubit>()
                      .completeMentions(widget.controller!.text),
                  context,
                );
                widget.controller!.clear();
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(9.0),
          child: SizedBox(
            height: 38,
            width: 38,
            child: widget.canSend
                ? Get.isDarkMode
                    ? Image.asset(
                        imageSendBlue,
                        color: Theme.of(context).colorScheme.onSurface,
                      )
                    : Image.asset(
                        imageSendBlue,
                      )
                : Get.isDarkMode
                    ? Image.asset(
                        imageSend,
                        color: Theme.of(context).colorScheme.secondaryContainer,
                      )
                    : Image.asset(
                        imageSend,
                      ),
          ),
        ));
  }

  _handleOpenGallery() async {
    final fileLen = Get.find<FileUploadCubit>().state.listFileUploading.length;
    if (fileLen == MAX_FILE_UPLOADING) {
      displayLimitationAlertDialog();
      return;
    }
    Get.find<GalleryCubit>().galleryInit();
    final bool isStatusGranted = await Utilities.checkCameraPermission();
    if (isStatusGranted) {
      Get.find<CameraCubit>().getCamera();
    } else {
      bool isRequestGranted = await Utilities.requestCameraPermission();
      if (isRequestGranted) {
        Get.find<CameraCubit>().getCamera();
      } else {
        Get.find<CameraCubit>().cameraFailed();
      }
    }

    Get.find<GalleryCubit>().getGalleryAssets();
    Get.find<FileTransitionCubit>().fileTransitionInit();

    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(40),
          ),
        ),
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: GalleryView(),
          );
        });
  }

  void displayLimitationAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TwakeAlertDialog(
          header: Text(
            AppLocalizations.of(context)?.reachedLimitFileUploading ?? '',
            style: Theme.of(context).textTheme.headline4!.copyWith(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
            textAlign: TextAlign.center,
          ),
          body: Text(
            AppLocalizations.of(context)?.reachedLimitFileUploadingSub ?? '',
            style: Theme.of(context)
                .textTheme
                .headline6!
                .copyWith(fontSize: 14.0, color: const Color(0xff6d7885)),
            textAlign: TextAlign.center,
          ),
          okActionTitle: AppLocalizations.of(context)?.gotIt ?? '',
        );
      },
    );
  }
}
