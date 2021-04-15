import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_emoji_keyboard/flutter_emoji_keyboard.dart';
import 'package:twake/utils/extensions.dart';

class MessageEditField extends StatefulWidget {
  final bool autofocus;
  final Function(String) onMessageSend;
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
  bool _emojiVisible = false;
  bool _forceLooseFocus = false;
  bool _canSend = false;

  final _focusNode = FocusNode();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onBackPress,
      child: Column(
        children: [
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

  TextInput({
    this.onMessageSend,
    this.controller,
    this.focusNode,
    this.autofocus,
    this.emojiVisible,
    this.scrollController,
    this.toggleEmojiBoard,
    this.canSend,
  });

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
          IconButton(
            padding: EdgeInsets.only(bottom: 5.0),
            icon: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationZ(-pi / 4), // rotate 45 degrees cc
              child: Icon(
                canSend ? Icons.send : Icons.send_outlined,
                color:
                canSend ? Theme.of(context).accentColor : Colors.grey[400],
              ),
            ),
            onPressed: canSend
                ? () async {
              await onMessageSend(controller.text);
              controller.clear();
            }
                : null,
          ),
        ],
      ),
    );
  }
}
