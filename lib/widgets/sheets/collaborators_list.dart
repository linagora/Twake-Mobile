import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twake/blocs/add_workspace_cubit/add_workspace_cubit.dart';
import 'package:twake/blocs/fields_cubit/fields_cubit.dart';
import 'package:twake/blocs/fields_cubit/fields_state.dart';
import 'package:twake/repositories/add_workspace_repository.dart';
import 'package:twake/widgets/sheets/sheet_title_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CollaboratorsList extends StatefulWidget {
  @override
  _CollaboratorsListState createState() => _CollaboratorsListState();
}

class _CollaboratorsListState extends State<CollaboratorsList> {
  final _formKey = GlobalKey<FormState>();
  var _canInvite = false;

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
        );
  }

  void _return() {
    FocusScope.of(context).requestFocus(new FocusNode());
    context.read<AddWorkspaceCubit>().setFlowStage(FlowStage.info);
  }

  void _invite() {
    FocusScope.of(context).requestFocus(new FocusNode());
    context.read<AddWorkspaceCubit>().setFlowStage(FlowStage.info);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FieldsCubit, FieldsState>(
      builder: (context, state) {
        List<Widget> fields = [];
        if (state is Added || state is Removed || state is Cleared) {
          fields = state.fields;

          return Column(
            children: [
              SheetTitleBar(
                title: 'Invite',
                leadingTitle: 'Back',
                leadingAction: () => _return(),
                trailingTitle: 'Invite',
                trailingAction: _canInvite ? () => _invite() : null,
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
              ...fields,
            ],
          );
        } else {
          return SizedBox();
        }
      },
    );
  }
}

class RemovableTextField extends StatefulWidget {
  final int index;
  final bool isLastOne;

  const RemovableTextField(
      {Key key, @required this.index, this.isLastOne = false})
      : super(key: key);

  @override
  _RemovableTextFieldState createState() => _RemovableTextFieldState();
}

class _RemovableTextFieldState extends State<RemovableTextField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  var _isLastOne = false;
  var _index = 0;

  @override
  void initState() {
    super.initState();
    _index = widget.index;
    _isLastOne = widget.isLastOne;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
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
            index: _index + 1,
            isLastOne: true,
          ),
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
    return TextFormField(
      // validator: widget.validator,
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(
        fontSize: 15.0,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        hintText: 'Type email address',
        hintStyle: TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.w500,
          color: Color(0xffc8c8c8),
        ),
        alignLabelWithHint: true,
        fillColor: Colors.transparent,
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        isDense: true,
        prefix: Container(
          width: 30,
          height: 25,
          padding: EdgeInsets.only(right: 10),
          child: IconButton(
            onPressed: () => _isLastOne ? _add() : _remove(),
            padding: EdgeInsets.all(0),
            iconSize: 20,
            icon: Icon(
              _isLastOne
                  ? CupertinoIcons.add_circled_solid
                  : CupertinoIcons.minus_circle_fill,
              color: _isLastOne
                  ? Color(0xff837cfe)
                  : Color(0xfff14620),
            ),
          ),
        ),
        suffix: Container(
          width: 30,
          height: 25,
          padding: EdgeInsets.only(left: 10),
          child: IconButton(
            onPressed: () => _controller.clear(),
            padding: EdgeInsets.all(0),
            iconSize: 20,
            icon: Icon(CupertinoIcons.clear_thick_circled),
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
