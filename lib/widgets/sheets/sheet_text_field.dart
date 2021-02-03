import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SheetTextField extends StatefulWidget {
  final String hint;
  final Function leadingAction;
  final Function trailingAction;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String Function(String) validator;

  const SheetTextField({
    @required this.controller,
    @required this.focusNode,
    @required this.hint,
    this.leadingAction,
    this.trailingAction,
    this.validator,
  });

  @override
  _SheetTextFieldState createState() => _SheetTextFieldState();
}

class _SheetTextFieldState extends State<SheetTextField> {
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
          fontSize: 17.0,
          fontWeight: FontWeight.w400,
          color: Color(0xffc8c8c8),
        ),
        alignLabelWithHint: true,
        // contentPadding: widget.leadingAction != null
        //     ? EdgeInsets.only(left: 14, bottom: 5)
        //     : null,
        fillColor: Colors.transparent,
        filled: true,
        prefix: (widget.leadingAction != null && widget.focusNode.hasFocus)
            ? Container(
                width: 30,
                height: 25,
                padding: EdgeInsets.only(right: 10),
                child: IconButton(
                  onPressed: widget.leadingAction,
                  padding: EdgeInsets.all(0),
                  iconSize: 20,
                  icon: Icon(
                    CupertinoIcons.minus_circle_fill,
                    color: Color(0xfff14620),
                  ),
                ),
              )
            : null,
        suffix: widget.trailingAction != null
            ? Container(
                width: 30,
                height: 25,
                padding: EdgeInsets.only(left: 10),
                child: IconButton(
                  onPressed: widget.trailingAction,
                  padding: EdgeInsets.all(0),
                  iconSize: 20,
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
                width: 30,
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
