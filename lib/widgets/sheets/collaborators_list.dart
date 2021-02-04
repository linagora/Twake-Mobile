import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twake/blocs/add_workspace_cubit/add_workspace_cubit.dart';
import 'package:twake/blocs/fields_cubit/fields_cubit.dart';
import 'package:twake/blocs/fields_cubit/fields_state.dart';
import 'package:twake/repositories/add_workspace_repository.dart';
import 'package:twake/widgets/sheets/sheet_title_bar.dart';
import 'package:twake/utils/extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CollaboratorsList extends StatefulWidget {
  @override
  _CollaboratorsListState createState() => _CollaboratorsListState();
}

class _CollaboratorsListState extends State<CollaboratorsList> {
  var _canInvite = true;
  List<Widget> _fields = [];
  List<String> _members = [];

  @override
  void initState() {
    super.initState();
    // First field init
    context.read<FieldsCubit>().add(
        RemovableTextField(
          key: UniqueKey(),
          index: 0,
          isLastOne: true,
        ),
        0);
  }

  void _return() {
    FocusScope.of(context).requestFocus(new FocusNode());
    context.read<AddWorkspaceCubit>()
      ..update(members: _members)
      ..setFlowStage(FlowStage.info);
  }

  void _invite() {
    FocusScope.of(context).requestFocus(new FocusNode());
    context.read<AddWorkspaceCubit>()
      ..update(members: _members)
      ..setFlowStage(FlowStage.info);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FieldsCubit, FieldsState>(
      listener: (context, state) {
        if (state is Updated) {
          _members = state.data.values.toList();
        }
      },
      builder: (context, state) {
        if (state is Added || state is Removed || state is Cleared) {
          _fields = state.fields;
        }
        return Column(
          children: [
            SheetTitleBar(
              title: 'Invite',
              leadingTitle: 'Back',
              leadingAction: () => _return(),
              trailingTitle: 'Invite',
              trailingAction: () => _canInvite ? _invite() : null,
            ),
            SizedBox(height: 32.0),
            Container(
              padding: const EdgeInsets.only(left: 14.0),
              width: MediaQuery.of(context).size.width,
              child: Text(
                'ADD COLLABORATORS',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black.withOpacity(0.4),
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Divider(
              thickness: 0.5,
              height: 0.5,
              color: Colors.black.withOpacity(0.2),
            ),
            ..._fields,
          ],
        );
      },
    );
  }
}

class RemovableTextField extends StatefulWidget {
  final int index;
  final bool isLastOne;
  final String initialText;

  const RemovableTextField(
      {Key key,
      @required this.index,
      this.isLastOne = false,
      this.initialText = ''})
      : super(key: key);

  @override
  _RemovableTextFieldState createState() => _RemovableTextFieldState();
}

class _RemovableTextFieldState extends State<RemovableTextField> {
  final _controller = TextEditingController();
  var _isLastOne = false;
  var _index = 0;
  var _inFocus = false;

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
          context.read<FieldsCubit>().update(_index, text);
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
          RemovableTextField(
            key: UniqueKey(),
            index: _index + 1,
            isLastOne: true,
          ),
          _index + 1,
        );
    setState(() {
      _isLastOne = false;
    });
  }

  void _remove() {
    context.read<FieldsCubit>().remove(_index);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  color: _isLastOne ? Color(0xff837cfe) : Color(0xfff14620),
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
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type email address',
                      contentPadding: EdgeInsets.all(15.0),
                      hintStyle: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
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
                            color: _inFocus ? Colors.grey : Colors.transparent,
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
    );
  }
}
