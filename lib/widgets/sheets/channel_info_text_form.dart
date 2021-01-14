import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChannelInfoTextForm extends StatefulWidget {
  final String hint;
  final Function trailingAction;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String Function(String) validator;

  const ChannelInfoTextForm({
    @required this.controller,
    @required this.focusNode,
    @required this.hint,
    this.trailingAction,
    this.validator,
  });

  @override
  _ChannelInfoTextFormState createState() => _ChannelInfoTextFormState();
}

class _ChannelInfoTextFormState extends State<ChannelInfoTextForm> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // style: TextStyle(fontSize: Dim.tm2(decimal: 0.2)),
      validator: widget.validator,
      controller: widget.controller,
      focusNode: widget.focusNode,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(
        fontSize: 17.0,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.w500,
          color: Color(0xffc8c8c8),
        ),
        contentPadding: EdgeInsets.only(
          bottom: widget.trailingAction != null ? 9.0 : 5.0,
        ),
        fillColor: Colors.transparent,
        filled: true,
        suffix: widget.trailingAction != null
            ? Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                width: 25,
                height: 25,
                child: IconButton(
                  padding: EdgeInsets.all(0),
                  onPressed: () => widget.trailingAction(),
                  icon: Icon(
                    CupertinoIcons.add_circled,
                    color: Color(0xff837cfe),
                  ),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xffeeeeef),
                ),
                width: 20,
                height: 20,
                child: IconButton(
                  padding: EdgeInsets.all(0),
                  onPressed: () => widget.controller.clear(),
                  iconSize: 15,
                  icon: Icon(CupertinoIcons.clear),
                ),
              ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            width: 0.0,
            style: BorderStyle.none,
          ),
        ),
      ),
    );
  }
}
