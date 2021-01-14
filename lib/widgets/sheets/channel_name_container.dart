import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/widgets/common/selectable_avatar.dart';

class ChannelNameContainer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const ChannelNameContainer({
    Key key,
    @required this.controller,
    @required this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 83.0,
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Row(
        children: [
          Expanded(child: SelectableAvatar()),
          Expanded(
            flex: 3,
            child: ChannelInfoTextForm(
              controller: controller,
              focusNode: focusNode,
            ),
          ),
        ],
      ),
    );
  }
}

class ChannelInfoTextForm extends StatefulWidget {
  final String label;
  final Function trailingAction;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String Function(String) validator;

  const ChannelInfoTextForm({
    @required this.controller,
    @required this.focusNode,
    this.label,
    this.trailingAction,
    this.validator,
  });

  @override
  _ChannelInfoTextFormState createState() => _ChannelInfoTextFormState();
}

class _ChannelInfoTextFormState extends State<ChannelInfoTextForm> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // style: TextStyle(fontSize: Dim.tm2(decimal: 0.2)),
      validator: widget.validator,
      controller: widget.controller,
      focusNode: widget.focusNode,
      keyboardType: TextInputType.emailAddress,
      style: Theme.of(context).textTheme.headline2,
      decoration: InputDecoration(
        hintText: 'Channel name',
        hintStyle: TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.w500,
          color: Color(0xffc8c8c8),
        ),
        contentPadding: EdgeInsets.all(10.0),
        fillColor: Colors.transparent,
        filled: true,
        suffix: GestureDetector(
          onTap: () {
            widget.controller.clear();
          },
          child: ClipRect(
            child: Container(
              color: Color(0xffeeeeef),
              child: Icon(
                CupertinoIcons.clear,
                size: 15,
              ),
            ),
          ),
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            width: 0.0,
            style: BorderStyle.none,
          ),
          borderRadius: BorderRadius.circular(7.0),
        ),
      ),
    );
  }
}
