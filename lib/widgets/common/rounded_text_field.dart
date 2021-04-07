import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class RoundedTextField extends StatelessWidget {
  final String hint;
  final String prefix;
  final TextEditingController controller;
  final FocusNode focusNode;
  final int maxLength;
  final String Function(String) validator;
  final BorderRadius borderRadius;

  const RoundedTextField({
    Key key,
    this.hint,
    this.prefix,
    this.controller,
    this.focusNode,
    this.maxLength,
    this.validator,
    this.borderRadius = BorderRadius.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius != BorderRadius.zero
            ? borderRadius
            : BorderRadius.circular(10.0),
      ),
      child: TextFormField(
        inputFormatters: [
          LengthLimitingTextInputFormatter(maxLength),
        ],
        validator: validator,
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.emailAddress,
        textAlign: TextAlign.end,
        style: TextStyle(
          fontSize: 17.0,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: hint,
          prefixText: prefix,
          hintStyle: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.w400,
            color: Color(0xffc8c8c8),
          ),
          alignLabelWithHint: true,
          contentPadding: EdgeInsets.only(left: 0, right: 16.0),
          fillColor: Colors.transparent,
          filled: true,
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
