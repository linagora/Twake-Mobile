import 'package:flutter/material.dart';

class TwakeSearchTextField extends StatelessWidget {
  final double height;
  final String hintText;
  final Color backgroundColor;
  final double fontSize;
  final TextEditingController? controller;

  const TwakeSearchTextField(
      {this.height = 46,
        this.hintText = 'Search',
        this.backgroundColor = const Color(0xfff9f8f9),
        this.fontSize = 17,
        this.controller
      }) : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: TextField(
        controller: controller,
        cursorColor: Color(0xff004dff),
        style: TextStyle(
          color: Colors.black,
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
        decoration: new InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 10),
          prefixIcon: Icon(Icons.search),
          border: new OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              width: 0,
              style: BorderStyle.none,
            ),
          ),
          filled: true,
          hintStyle: TextStyle(
            color: Color(0xff8e8e93),
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
          ),
          hintText: hintText,
          fillColor: backgroundColor,
        ),
      ),
    );
  }
}
