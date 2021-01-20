import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/draft_bloc.dart';
import 'package:twake/config/dimensions_config.dart';
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
  bool _canSend = false;

  final _focus = FocusNode();
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.initialText.isNotReallyEmpty) {
      _controller.text = widget.initialText; // possibly retrieved from cache.
      setState(() {
        _canSend = true;
      });
    }

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
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool _keyboardVisible = !(MediaQuery.of(context).viewInsets.bottom == 0.0);
    return TextInput(
      controller: _controller,
      autofocus: widget.autofocus,
      emojiVisible: _emojiVisible,
      keyboardVisible: _keyboardVisible,
      onMessageSend: widget.onMessageSend,
      canSend: _canSend,
    );
  }
}

class TextInput extends StatelessWidget {
  final TextEditingController controller;
  final Function toggleEmojiBoard;
  final Function onEmojiPicked;
  final bool autofocus;
  final bool emojiVisible;
  final bool keyboardVisible;
  final bool canSend;
  final Function onMessageSend;

  TextInput({
    this.onMessageSend,
    this.controller,
    this.autofocus,
    this.emojiVisible,
    this.keyboardVisible,
    this.toggleEmojiBoard,
    this.onEmojiPicked,
    this.canSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dim.wm3,
        vertical: Dim.heightMultiplier,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300], width: 2.0)),
      ),
      child: TextField(
        style: TextStyle(
          fontSize: 17.0,
          fontWeight: FontWeight.w400,
          color: Color(0xff444444),
        ),
        maxLines: 4,
        minLines: 1,
        // cursorHeight: Dim.tm3(),
        autofocus: autofocus,
        controller: controller,
        decoration: InputDecoration(
          suffixIcon: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                padding: EdgeInsetsDirectional.only(top: 12),
                iconSize: Dim.tm4(),
                icon: Transform(
                  transform: Matrix4.rotationZ(
                    -pi / 4,
                  ), // rotate 45 degrees cc
                  child: Icon(
                    canSend ? Icons.send : Icons.send_outlined,
                    color: canSend
                        ? Theme.of(context).accentColor
                        : Colors.grey[400],
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
          isCollapsed: true,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          labelText: 'Reply',
          border: UnderlineInputBorder(
            borderSide: BorderSide(width: 0.0, style: BorderStyle.none),
          ),
        ),
      ),
    );
  }
}
