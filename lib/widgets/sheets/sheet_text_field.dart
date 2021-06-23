import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SheetTextField extends StatefulWidget {
  final String hint;
  final Function? leadingAction;
  final Function? trailingAction;
  final TextEditingController controller;
  final FocusNode focusNode;
  final int? maxLength;
  final String? Function(String?)? validator;
  final bool isRounded;
  final double borderRadius;
  final TextInputType textInputType;

  const SheetTextField(
      {required this.controller,
      required this.focusNode,
      required this.hint,
      this.leadingAction,
      this.trailingAction,
      this.validator,
      this.maxLength,
      this.isRounded = false,
      this.borderRadius = 0,
      this.textInputType = TextInputType.emailAddress});

  @override
  _SheetTextFieldState createState() => _SheetTextFieldState();
}

class _SheetTextFieldState extends State<SheetTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: widget.borderRadius != 0
            ? BorderRadius.circular(widget.borderRadius)
            : BorderRadius.zero,
      ),
      padding: const EdgeInsets.only(left: 14.0, right: 7),
      child: TextFormField(
        inputFormatters: [
          LengthLimitingTextInputFormatter(widget.maxLength),
        ],
        validator: widget.validator,
        controller: widget.controller,
        focusNode: widget.focusNode,
        keyboardType: widget.textInputType,
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
          contentPadding: EdgeInsets.only(left: 0),
          fillColor: Colors.transparent,
          filled: true,
          prefix: (widget.leadingAction != null && widget.focusNode.hasFocus)
              ? Container(
                  width: 30,
                  height: 25,
                  padding: EdgeInsets.only(right: 10),
                  child: IconButton(
                    onPressed: widget.leadingAction as void Function()?,
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
                    onPressed: widget.trailingAction as void Function()?,
                    padding: EdgeInsets.all(0),
                    iconSize: 20,
                    icon: Icon(
                      CupertinoIcons.add_circled,
                      color: Color(0xff3840F7),
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
      ),
    );
  }
}
