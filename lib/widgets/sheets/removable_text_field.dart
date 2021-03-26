import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twake/blocs/fields_cubit/fields_cubit.dart';
import 'package:twake/utils/extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RemovableTextField extends StatefulWidget {
  final int index;
  final bool isLastOne;
  final String initialText;

  const RemovableTextField({
    Key key,
    @required this.index,
    this.isLastOne = false,
    this.initialText = '',
  }) : super(key: key);

  @override
  _RemovableTextFieldState createState() => _RemovableTextFieldState();
}

class _RemovableTextFieldState extends State<RemovableTextField> {
  final _controller = TextEditingController();
  var _isLastOne = false;
  var _index = 0;
  var _inFocus = false;
  var _editable = true;

  @override
  void initState() {
    super.initState();
    _index = widget.index;
    _isLastOne = widget.isLastOne;
    _controller.text = widget.initialText;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.addListener(() {
        String text = _controller.text;
        if (text.isNotReallyEmpty) {
          context
              .read<FieldsCubit>()
              .update(withContent: text, atIndex: _index);
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant RemovableTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLastOne != widget.isLastOne) {
      _isLastOne = widget.isLastOne;
    }
    if (oldWidget.index != widget.index) {
      _index = widget.index;
    }
  }

  void _add() {
    context.read<FieldsCubit>().add(
          field: RemovableTextField(
            key: UniqueKey(),
            index: _index + 1,
            isLastOne: true,
          ),
          atIndex: _index + 1,
        );
    setState(() {
      _isLastOne = false;
    });
  }

  void _remove() {
    context.read<FieldsCubit>().remove(atIndex: _index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.only(left: 16),
                child: GestureDetector(
                  onTap: () => _isLastOne ? _add() : _remove(),
                  child: Icon(
                    _isLastOne
                        ? CupertinoIcons.add_circled_solid
                        : CupertinoIcons.minus_circle_fill,
                    color: _isLastOne ? Color(0xff3840F7) : Color(0xfff14620),
                    size: 25,
                  ),
                ),
              ),
              Expanded(
                child: FocusScope(
                  child: Focus(
                    onFocusChange: (focus) {
                      setState(() {
                        _inFocus = focus;
                      });
                    },
                    child: TextFormField(
                      // validator: widget.validator,
                      controller: _controller,
                      autofocus: true,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type email address',
                        contentPadding: EdgeInsets.all(15.0),
                        hintStyle: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: Color(0xffc8c8c8),
                        ),
                        alignLabelWithHint: true,
                        fillColor: Colors.transparent,
                        filled: true,
                        suffixIcon: Container(
                          height: 20,
                          width: 20,
                          child: GestureDetector(
                            onTap: () => _controller.clear(),
                            child: Icon(
                              CupertinoIcons.clear_thick_circled,
                              color:
                                  _inFocus ? Colors.grey : Colors.transparent,
                              size: 20,
                            ),
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
                  ),
                ),
              ),
              SizedBox(width: 5),
            ],
          ),
          Divider(
            thickness: 0.5,
            height: 0.5,
            color: Colors.black.withOpacity(0.2),
          ),
        ],
      ),
    );
  }
}
