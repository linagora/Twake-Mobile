import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:twake/widgets/sheets/sheet_text_field.dart';

class NameContainer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const NameContainer({
    Key key,
    @required this.controller,
    @required this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        color: Colors.white,
        child: SheetTextField(
          hint: 'Channel name',
          controller: controller,
          focusNode: focusNode,
        ),
      ),
    );
  }
}
