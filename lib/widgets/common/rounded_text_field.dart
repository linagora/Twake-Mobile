import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class RoundedTextField extends StatelessWidget {
  final String hint;
  final Function leadingAction;
  final Function trailingAction;
  final TextEditingController controller;
  final FocusNode focusNode;
  final int maxLength;
  final String Function(String) validator;

  const RoundedTextField({
    Key key,
    this.hint,
    this.leadingAction,
    this.trailingAction,
    this.controller,
    this.focusNode,
    this.maxLength,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 14.0, right: 7),
      color: Colors.white,
      child: TextFormField(
        inputFormatters: [
          LengthLimitingTextInputFormatter(maxLength),
        ],
        validator: validator,
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(
          fontSize: 17.0,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: hint,
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
          prefix: (leadingAction != null && focusNode.hasFocus)
              ? Container(
                  width: 30,
                  height: 25,
                  padding: EdgeInsets.only(right: 10),
                  child: IconButton(
                    onPressed: leadingAction,
                    padding: EdgeInsets.all(0),
                    iconSize: 20,
                    icon: Icon(
                      CupertinoIcons.minus_circle_fill,
                      color: Color(0xfff14620),
                    ),
                  ),
                )
              : null,
          suffix: trailingAction != null
              ? Container(
                  width: 30,
                  height: 25,
                  padding: EdgeInsets.only(left: 10),
                  child: IconButton(
                    onPressed: trailingAction,
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
                    onPressed: () => controller.clear(),
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
