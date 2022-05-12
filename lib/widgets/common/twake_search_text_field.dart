import 'package:flutter/material.dart';

class TwakeSearchTextField extends StatefulWidget {
  final double height;
  final String? hintText;
  final Color backgroundColor;
  final double fontSize;
  final bool showPrefixIcon;
  final double borderRadius;
  final Function? onPress;
  late final TextEditingController? controller;

  TwakeSearchTextField({
    this.height = 46,
    this.hintText,
    this.backgroundColor = const Color(0xfff9f8f9),
    this.fontSize = 17,
    this.showPrefixIcon = true,
    this.borderRadius = 12,
    this.onPress,
    TextEditingController? controller,
  }) : super() {
    this.controller = controller != null ? controller : TextEditingController();
  }

  @override
  _TwakeSearchTextFieldState createState() => _TwakeSearchTextFieldState();
}

class _TwakeSearchTextFieldState extends State<TwakeSearchTextField> {
  var showClearButton = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      widget.controller!.addListener(() {
        setState(() {
          showClearButton = widget.controller!.text.isNotEmpty;
        });
      });
    }
  }

  void _onTextFieldTap() {
    widget.onPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      child: TextField(
        controller: widget.controller,
        onTap: _onTextFieldTap,
        cursorColor: Theme.of(context).textSelectionTheme.cursorColor,
        style: Theme.of(context).textTheme.headline1,
        decoration: new InputDecoration(
          contentPadding: EdgeInsets.only(
              top: 10, bottom: 10, left: widget.showPrefixIcon ? 0 : 30),
          prefixIcon: widget.showPrefixIcon
              ? Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.secondary,
                )
              : null,
          suffixIcon: showClearButton
              ? Padding(
                  padding: const EdgeInsets.only(right: 16.0, left: 16),
                  child: GestureDetector(
                      onTap: () {
                        widget.controller?.clear();
                      },
                      child: _ClearIcon()),
                )
              : SizedBox.shrink(),
          suffixIconConstraints: BoxConstraints(minHeight: 16, minWidth: 16),
          border: new OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(widget.borderRadius),
            ),
            borderSide: BorderSide(
              width: 0,
              style: BorderStyle.none,
            ),
          ),
          filled: true,
          hintStyle: Theme.of(context)
              .textTheme
              .headline2!
              .copyWith(fontSize: widget.fontSize, fontWeight: FontWeight.w400),
          hintText: widget.hintText,
          fillColor: widget.backgroundColor,
        ),
      ),
    );
  }
}

class _ClearIcon extends StatelessWidget {
  const _ClearIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        color: Colors.grey,
        width: 16,
        height: 16,
        child: Icon(
          Icons.close,
          size: 12,
          color: Colors.white,
        ),
      ),
    );
  }
}
