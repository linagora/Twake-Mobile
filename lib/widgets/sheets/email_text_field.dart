import 'package:flutter/material.dart';

class EmailTextFields extends StatefulWidget {
  final int index;
  EmailTextFields(this.index);
  @override
  _EmailTextFieldsState createState() => _EmailTextFieldsState();
}

class _EmailTextFieldsState extends State<EmailTextFields> {
  TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   _nameController.text = _MyFormState.friendsList[widget.index] ?? '';
    // });
    //
    // return TextFormField(
    //   controller: _nameController,
    //   onChanged: (v) => _MyFormState.friendsList[widget.index] = v,
    //   decoration: InputDecoration(
    //       hintText: 'Enter your friend\'s name'
    //   ),
    //   validator: (v){
    //     if(v.trim().isEmpty) return 'Please enter something';
    //     return null;
    //   },
    // );
  }
}