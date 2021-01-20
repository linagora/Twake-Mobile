import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twake/blocs/draft_bloc.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/repositories/draft_repository.dart';

class MessageEditField extends StatefulWidget {
  final bool autofocus;
  final Function(String) onMessageSend;

  MessageEditField(this.onMessageSend, {this.autofocus: false});

  @override
  _MessageEditField createState() => _MessageEditField();
}

class _MessageEditField extends State<MessageEditField> {
  bool _emojiVisible = false;
  String _channelId;
  DraftType _channelType = DraftType.channel;
  // Timer _debounce;

  final _focus = FocusNode();
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    print('ON CHANNEL INIt');

    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        // setState(() => );
        // print('DRAFT TO RESET: $_channelId : ${_controller.text}');
        context.read<DraftBloc>().add(ResetDraft(
          id: _channelId,
          type: _channelType,
        ));
      // } else if (!_canSend) {
        // setState(() => _canSend = true);
      } else {
        // print('DRAFT TO SAVE: $_channelId : ${_controller.text}');
        // if (_debounce?.isActive ?? false) _debounce.cancel();
        // _debounce = Timer(const Duration(milliseconds: 1500), () {
          final draft = _controller.text;
          context.read<DraftBloc>().add(SaveDraft(
            id: _channelId,
            type: _channelType,
            draft: draft,
          ));
        // });
      }
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    _controller.dispose();

    // _debounce.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool _keyboardVisible = !(MediaQuery.of(context).viewInsets.bottom == 0.0);
    return BlocBuilder<DraftBloc, DraftState>(
      buildWhen: (_, current) {
        return current is DraftLoaded;
      },
      builder: (context, state) {
        if (state is DraftLoaded) {
          _controller.text = state.draft;
          _channelId = state.id;
          _channelType = state.type;
        }
        var canSend = _controller.text.isNotEmpty;
        return TextInput(
          controller: _controller,
          autofocus: widget.autofocus,
          emojiVisible: _emojiVisible,
          keyboardVisible: _keyboardVisible,
          onMessageSend: widget.onMessageSend,
          canSend: canSend,
        );
      },
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
