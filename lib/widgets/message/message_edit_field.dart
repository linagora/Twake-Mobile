import 'dart:math';
import 'package:flutter/material.dart';
// import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:twake_mobile/config/dimensions_config.dart';
import 'package:twake_mobile/widgets/common/emoji_piker_keyboard.dart';

class MessageEditField extends StatefulWidget {
  // Optional value to edit in text field
  final bool autofocus;
  final Function(String) onMessageSend;
  MessageEditField(this.onMessageSend, {this.autofocus: false});
  @override
  _MessageEditField createState() => _MessageEditField();
}

class _MessageEditField extends State<MessageEditField> {
  // bool _keyboardVisible = false;
  bool _canSend = false;
  bool _emojiVisible = false;
  final _focus = FocusNode();
  final _controller = TextEditingController();
  // KeyboardVisibilityController visibilityController;

  /// Hide keyboard when showing emoji board,
  /// make sure we always get the focus on emoji board when clicked
  Future<void> toggleEmojiBoard() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _emojiVisible = !_emojiVisible;
    });
  }

  @override
  void initState() {
    // Listen to changes in input to detect that user has entered something
    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        setState(() => _canSend = false);
      } else if (!_canSend) {
        setState(() => _canSend = true);
      }
    });

    _focus.addListener(() {
      if (_focus.hasFocus) {
        setState(() {
          _emojiVisible = false;
        });
      }
    });
    // Make sure that emoji keyboard and ordinary keyboard never
    // happens to be on screen at the same time

    super.initState();
  }

  void onEmojiPicked(emoji) {
    setState(() {
      _controller.text += emoji.emoji;
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
    return Column(
      children: [
        TextInput(
          focusNode: _focus,
          controller: _controller,
          autofocus: widget.autofocus,
          emojiVisible: _emojiVisible,
          keyboardVisible: _keyboardVisible,
          toggleEmojiBoard: toggleEmojiBoard,
          onEmojiPicked: onEmojiPicked,
          onMessageSend: widget.onMessageSend,
          canSend: _canSend,
        ),
        Offstage(
          offstage: !_emojiVisible,
          child: EmojiPickerKeyboard(onEmojiPicked: onEmojiPicked),
        ),
      ],
    );
  }
}

class TextInput extends StatelessWidget {
  final FocusNode focusNode;
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
    this.focusNode,
    this.controller,
    this.autofocus,
    this.emojiVisible,
    this.keyboardVisible,
    this.toggleEmojiBoard,
    this.onEmojiPicked,
    this.canSend,
  });
  Future<void> onEmojiClicked() async {
    if (emojiVisible) {
      focusNode.requestFocus();
    } else if (keyboardVisible) {
      // await SystemChannels.textInput.invokeMethod('TextInput.hide');
      focusNode.unfocus();
      await Future.delayed(Duration(milliseconds: 30));
    }
    toggleEmojiBoard();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dim.wm3,
        vertical: focusNode.hasFocus ? Dim.heightMultiplier : Dim.hm2,
      ),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300], width: 2.0)),
      ),
      child: Column(
        children: [
          TextField(
            style: Theme.of(context).textTheme.headline6,
            maxLines: 4,
            minLines: 1,
            cursorHeight: Dim.tm3(),
            autofocus: autofocus,
            focusNode: focusNode,
            controller: controller,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                padding: EdgeInsets.only(top: Dim.hm2),
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
                        focusNode.unfocus();
                        controller.clear();
                      }
                    : null,
              ),
              isCollapsed: true,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              labelText: 'Reply',
              border: UnderlineInputBorder(
                borderSide: BorderSide(width: 0.0, style: BorderStyle.none),
              ),
            ),
          ),
          if (focusNode.hasFocus)
            Row(
              children: [
                IconButton(
                  iconSize: Dim.tm3(),
                  icon: Icon(
                    emojiVisible ? Icons.keyboard : Icons.tag_faces,
                    color: Colors.grey,
                  ),
                  onPressed: onEmojiClicked,
                ),
                SizedBox(width: Dim.wm2),
                IconButton(
                  iconSize: Dim.tm3(),
                  icon: Icon(
                    Icons.alternate_email,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    focusNode.unfocus();
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}
