import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class RoundedTextField extends StatelessWidget {
  final String? hint;
  final String? prefix;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final int? maxLength;
  final String Function(String?)? validator;
  final BorderRadius borderRadius;
  final bool enabled;

  const RoundedTextField(
      {Key? key,
      this.hint,
      this.prefix,
      this.controller,
      this.focusNode,
      this.maxLength,
      this.validator,
      this.borderRadius = BorderRadius.zero,
      this.enabled = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: borderRadius != BorderRadius.zero
            ? borderRadius
            : BorderRadius.circular(10.0),
      ),
      child: TextFormField(
        inputFormatters: [
          LengthLimitingTextInputFormatter(maxLength),
        ],
        enabled: enabled,
        validator: validator,
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.emailAddress,
        textAlign: TextAlign.end,
        style: Theme.of(context).textTheme.headline1!.copyWith(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Text(
              '$prefix',
              style:
                  Theme.of(context).textTheme.headline3!.copyWith(fontSize: 15),
            ),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
          hintStyle:
              Theme.of(context).textTheme.headline3!.copyWith(fontSize: 15),
          alignLabelWithHint: true,
          contentPadding: EdgeInsets.only(right: 16.0),
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
