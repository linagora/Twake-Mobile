import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji_keyboard/flutter_emoji_keyboard.dart';
import 'package:twake/utils/extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/file_upload_bloc/file_upload_bloc.dart';
import 'package:twake/blocs/mentions_cubit/mentions_cubit.dart';

const _categoryHeaderHeight = 40.0;
const _categoryTitleHeight = _categoryHeaderHeight; // to

class MessageEditField extends StatefulWidget {
  final bool autofocus;
  final Function(String, BuildContext) onMessageSend;
  final Function(String) onTextUpdated;
  final String initialText;

  MessageEditField({
    @required this.onMessageSend,
    @required this.onTextUpdated,
    this.autofocus = false,
    this.initialText = '',
  });

  @override
  _MessageEditField createState() => _MessageEditField();
}

class _MessageEditField extends State<MessageEditField> {
  final _userMentionRegex = RegExp(r'\s@[A-Za-z1-9_-]+$');
  bool _emojiVisible = false;
  bool _forceLooseFocus = false;
  bool _canSend = false;

  final _focusNode = FocusNode();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  List<PlatformFile> _paths;
  String _extension;
  bool _multiPick = false;
  FileType _pickingType = FileType.any;

  @override
  void initState() {
    super.initState();

    widget.onTextUpdated(widget.initialText);
    if (widget.initialText.isNotReallyEmpty) {
      _controller.text = widget.initialText; // possibly retrieved from cache.
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
      var text = _controller.text;
      if (_userMentionRegex.hasMatch(text)) {
        BlocProvider.of<MentionsCubit>(context)
            .fetchMentionableUsers(searchTerm: text);
      }
      // Update for cache handlers
      widget.onTextUpdated(text);
      // Sendability  validation
      if (text.isReallyEmpty && _canSend) {
        setState(() {
          _canSend = false;
        });
      } else if (text.isNotReallyEmpty && !_canSend) {
        setState(() {
          _canSend = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MessageEditField oldWidget) {
    if (oldWidget.initialText != widget.initialText) {
      _controller.text = widget.initialText;
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
    await Future.delayed(Duration(milliseconds: 150));
    setState(() {
      _emojiVisible = !_emojiVisible;
    });
    if (!_emojiVisible) {
      _forceLooseFocus = false;
      _focusNode.requestFocus();
    }
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

  void _openFileExplorer() async {
    try {
      _paths = (await FilePicker.platform.pickFiles(
        type: _pickingType,
        allowMultiple: _multiPick,
        allowedExtensions: (_extension?.isNotEmpty ?? false)
            ? _extension.replaceAll(' ', '').split(',')
            : null,
      ))
          ?.files;
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    } catch (ex) {
      print(ex);
    }
    if (!mounted) return;
    final path = _paths.map((e) => e.path).toList()[0].toString();
    // final name = _paths.map((e) => e.name).toList()[0].toString();
    //print(path);
    //needed to add indexes for multifiles

    BlocProvider.of<FileUploadBloc>(context).add(StartUpload(path: path));
  }

  @override
  Widget build(BuildContext context) {
    final List<String> listOfUsers = ['Name1', 'Name2', 'Name3'];
    return WillPopScope(
      onWillPop: onBackPress,
      child: Column(
        children: [
          Container(
            height: (MediaQuery.of(context).size.height) * 0.3,
            child: BlocBuilder<MentionsCubit, MentionState>(
              builder: (context, state) {
                if (state is MentionableUsersLoaded) {
                  return ListView.separated(
                    separatorBuilder: (context, index) => Divider(
                      color: Colors.black54,
                    ),
                    itemCount: state.users.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('${state.users[index]}'),
                      );
                    },
                  );
                } else if (state is MentionsEmpty) {
                  return Text("Empty");
                  //Text("Empty");
                }
                return Text("init");
              },
            ),
          ),
          TextInput(
            controller: _controller,
            scrollController: _scrollController,
            focusNode: _focusNode,
            autofocus: widget.autofocus,
            toggleEmojiBoard: toggleEmojiBoard,
            emojiVisible: _emojiVisible,
            onMessageSend: widget.onMessageSend,
            canSend: _canSend,
            openFileExplorer: _openFileExplorer,
          ),
          if (_emojiVisible)
            EmojiKeyboard(
              onEmojiSelected: (emoji) {
                _controller.text += emoji.text;
                _scrollController
                    .jumpTo(_scrollController.position.maxScrollExtent);
              },
              height: MediaQuery.of(context).size.height * 0.35,
            ),
        ],
      ),
    );
  }
}

class TextInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ScrollController scrollController;
  final Function toggleEmojiBoard;
  final bool autofocus;
  final bool emojiVisible;
  final bool canSend;
  final Function onMessageSend;
  final Function openFileExplorer;

  TextInput(
      {this.onMessageSend,
      this.controller,
      this.focusNode,
      this.autofocus,
      this.emojiVisible,
      this.scrollController,
      this.toggleEmojiBoard,
      this.openFileExplorer,
      this.canSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300], width: 1.5)),
      ),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(emojiVisible ? Icons.keyboard : Icons.tag_faces),
            onPressed: toggleEmojiBoard,
            color: Colors.black54,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 2),
              child: TextField(
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff444444),
                ),
                cursorHeight: 20,
                maxLines: 4,
                minLines: 1,
                autofocus: autofocus,
                focusNode: focusNode,
                scrollController: scrollController,
                controller: controller,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Colors.blueGrey),
                ),
              ),
            ),
          ),
          BlocBuilder<FileUploadBloc, FileUploadState>(
            builder: (context, state) {
              if (state is NothingToUpload) {
                return CircleAvatar(
                  backgroundColor: Colors.indigo[50],
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.file_download),
                    onPressed: openFileExplorer,
                    color: Colors.black54,
                  ),
                );
              } else if (state is FileUploading) {
                return CircularProgressIndicator();
              } else if (state is FileUploaded) {
                return CircleAvatar(
                  child: (Text('1')),
                  backgroundColor: Colors.indigo[50],
                );
              }
              return CircleAvatar(
                backgroundColor: Colors.indigo[50],
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.file_download),
                  onPressed: openFileExplorer,
                  color: Colors.black54,
                ),
              );
            },
          ),
          IconButton(
            padding: EdgeInsets.only(bottom: 5.0),
            icon: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationZ(-3 / 4), // rotate 45ish degree cc
              child: Icon(
                canSend ? Icons.send : Icons.send_outlined,
                color:
                    canSend ? Theme.of(context).accentColor : Colors.grey[400],
              ),
            ),
            onPressed: canSend
                ? () async {
                    await onMessageSend(controller.text, context);
                    controller.clear();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
