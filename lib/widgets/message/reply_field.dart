import 'package:flutter/material.dart';
import 'package:twake_mobile/config/dimensions_config.dart';
import 'package:twake_mobile/models/message.dart';

class ReplyField extends StatefulWidget {
  // Optional value to edit in text field
  final Message message;
  final bool autofocus;
  ReplyField({this.message, this.autofocus: false});
  @override
  _ReplyFieldState createState() => _ReplyFieldState();
}

class _ReplyFieldState extends State<ReplyField> {
  bool _isFocused = false;
  final _focus = FocusNode();
  final _controller = TextEditingController();
  @override
  void initState() {
    _focus.addListener(onFocusChange);
    if (widget.message != null) {
      _controller.text = widget.message.content.originalStr;
    }

    super.initState();
  }

  void onFocusChange() {
    setState(() {
      _isFocused = _focus.hasFocus;
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
            autofocus: widget.autofocus,
            focusNode: _focus,
            controller: _controller,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(Dim.widthMultiplier),
              floatingLabelBehavior: FloatingLabelBehavior.never,
              labelText: 'Reply',
              border: UnderlineInputBorder(
                borderSide: BorderSide(width: 0.0, style: BorderStyle.none),
              ),
            ),
          ),
          if (_isFocused)
            Column(
              children: [
                SizedBox(height: Dim.heightMultiplier),
                Row(children: [
                  IconButton(
                    iconSize: Dim.tm3(),
                    icon: Icon(
                      Icons.tag_faces,
                      color: Colors.grey,
                    ),
                    onPressed: () {},
                  ),
                  SizedBox(width: Dim.wm2),
                  IconButton(
                    iconSize: Dim.tm3(),
                    icon: Icon(
                      Icons.alternate_email,
                      color: Colors.grey,
                    ),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.send),
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
