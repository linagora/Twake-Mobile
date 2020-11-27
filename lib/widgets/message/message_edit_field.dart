import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:twake_mobile/config/dimensions_config.dart';
import 'package:twake_mobile/models/message.dart';
import 'package:twake_mobile/widgets/common/emoji_piker_keyboard.dart';

class MessageEditField extends StatefulWidget {
  // Optional value to edit in text field
  final Message message;
  final bool autofocus;
  MessageEditField({this.message, this.autofocus: false});
  @override
  _MessageEditField createState() => _MessageEditField();
}

class _MessageEditField extends State<MessageEditField> {
  bool _emojiVisible = false;
  bool _keyboardVisible = false;
  bool _canSend = false;
  final _focus = FocusNode();
  final _controller = TextEditingController();

  /// Hide keyboard when showing emoji board,
  /// make sure we always get the focus on emoji board when clicked
  Future<void> toggleEmojiBoard() async {
    print('removing focus');
    FocusScope.of(context).unfocus();

    setState(() {
      _emojiVisible = !_emojiVisible;
    });
  }

  @override
  void initState() {
    if (widget.message != null) {
      _controller.text = widget.message.content.originalStr;
    }

    // Listen to changes in input to detect that user has entered something
    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        setState(() => _canSend = false);
      } else if (!_canSend) {
        setState(() => _canSend = true);
      }
    });

    // Make sure that emoji keyboard and ordinary keyboard never
    // happens to be on screen at the same time
    KeyboardVisibility.onChange.listen((bool isKeyboardVisible) {
      print('SETTING KEYBOARD: $isKeyboardVisible');
      setState(() {
        _keyboardVisible = isKeyboardVisible;
      });

      if (isKeyboardVisible && _emojiVisible) {
        setState(() {
          _emojiVisible = false;
        });
      }
    });

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
    print('REBUILDING FROM SCRATCH');
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
  TextInput({
    this.focusNode,
    this.controller,
    this.autofocus,
    this.emojiVisible,
    this.keyboardVisible,
    this.toggleEmojiBoard,
    this.onEmojiPicked,
  });
  Future<void> onEmojiClicked() async {
    if (emojiVisible) {
      print('Requesting Focus');
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
      // height: _isFocused ? Dim.heightPercent(13) : Dim.hm7,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300], width: 2.0)),
      ),
      child: Column(
        children: [
          TextField(
            maxLines: 3,
            minLines: 1,
            autofocus: autofocus,
            focusNode: focusNode,
            controller: controller,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(Dim.widthMultiplier),
              floatingLabelBehavior: FloatingLabelBehavior.never,
              labelText: 'Reply',
              border: UnderlineInputBorder(
                borderSide: BorderSide(width: 0.0, style: BorderStyle.none),
              ),
            ),
          ),
          // if (focusNode.hasFocus)
          Column(
            children: [
              SizedBox(height: Dim.heightMultiplier),
              Row(children: [
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
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      iconSize: Dim.tm3(),
                      icon: Transform(
                          transform: Matrix4.rotationZ(
                            -pi / 4,
                          ), // rotate 45 degrees cc
                          child: Icon(Icons.send_sharp)),
                      onPressed: () {},
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
