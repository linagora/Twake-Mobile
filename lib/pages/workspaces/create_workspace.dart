import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_state.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/services/navigator_service.dart';
import 'package:twake/widgets/sheets/hint_line.dart';
import 'package:twake/widgets/sheets/sheet_text_field.dart';
import 'package:twake/widgets/sheets/sheet_title_bar.dart';

class WorkspaceForm extends StatefulWidget {
  @override
  _WorkspaceFormState createState() => _WorkspaceFormState();
}

class _WorkspaceFormState extends State<WorkspaceForm> {
  final _formKey = GlobalKey<FormState>();
  // final _formKey1 = GlobalKey<FormState>();
  final _workspaceNameController = TextEditingController();
  final _workspaceNameFocusNode = FocusNode();
  bool _flag = true;
  int _count = 0;
  List<Map<String, dynamic>> membersList = [];
  List<String> members = [];
  @override
  void initState() {
    super.initState();
    _workspaceNameFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    _flag = !_flag;
  }

  @override
  void dispose() {
    _workspaceNameController.dispose();
    _workspaceNameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _invitationLimit() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Invitation limit'),
          content: Text(
              'To add more team members,please, verify your account. We sent verification details to: alexandre@linagora.com'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Open email'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _onUpdate(int index, String text) {
    int foundIndex = -1;
    for (var map in membersList) {
      if (map.containsKey("index")) {
        if (map["index"] == index) {
          foundIndex = index;
          break;
        }
      }
    }
    if (-1 != foundIndex) {
      membersList.removeWhere((map) {
        return map["index"] == foundIndex;
      });
    }

    Map<String, dynamic> member = {'index': index, 'text': text};
    membersList.add(member);
    members = [];
    membersList.forEach((map) {
      var _list = map.values.toList();
      members.add(_list[1]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Color(0xFFF2F2F6),
          child: Column(
            children: [
              Container(
                color: Colors.white,
                child: SheetTitleBar(
                  title: 'New Workspace',
                  leadingTitle: 'Cancel',
                  leadingAction: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    popBack();
                  },
                  trailingTitle: 'Create',
                  trailingAction: () async {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: Duration(seconds: 3),
                          content: Text('Processing'), 
                        ),
                      );

                      await Get.find<WorkspacesCubit>().createWorkspace(
                          companyId: Globals.instance.companyId,
                          name: _workspaceNameController.text,
                          members: members);

                      final state = Get.find<WorkspacesCubit>().state;
                      if (state is WorkspacesLoadSuccess) {
                        Get.find<WorkspacesCubit>()
                            .selectWorkspace(workspaceId: state.selected!.id);
                        Get.find<WorkspacesCubit>().fetch();
                        popBack();
                        Navigator.of(context).pop();

                        //  Get.find<WorkspacesCubit>().fetch();
                        // NavigatorService.instance.navigateTohomeWidget();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'An error occurred while creating the workspace'),
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
              SizedBox(height: 16),
              MediaQuery.of(context).viewInsets.bottom == 0 ||
                      _count < 2 ||
                      _flag == false
                  ? Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 15, right: 15),
                              child: Container(
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF5F5F5),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Icon(
                                          Icons.camera_alt_rounded,
                                          color: Color(0xFF969CA4),
                                        ),
                                        height: 44,
                                        width: 44,
                                      ),
                                      onTap: () async {},
                                    ),
                                    Flexible(
                                      child: Center(
                                        child: Form(
                                          key: _formKey,
                                          child: SheetTextField(
                                            hint: 'Workspace name',
                                            controller:
                                                _workspaceNameController,
                                            focusNode: _workspaceNameFocusNode,
                                            maxLength: 30,
                                            isRounded: true,
                                            borderRadius: 8,
                                            textInputType: TextInputType.text,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Workspace name cannot be empty';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: HintLine(
                            text:
                                'Please provide a name for a new workspace and optional workspace icon',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : Container(),
              SizedBox(height: 40),
              HintLine(
                text: 'ADD YOUR TEAM MEMBERS',
                isLarge: true,
                fontWeight: FontWeight.w500,
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _count,
                  itemBuilder: (context, index) {
                    return _textField(index);
                  },
                ),
              ),
              _addMember(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addMember() {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.add_circled_solid,
                  color: Color(0xFF004DFF),
                  size: 25,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Add email',
                  style: TextStyle(color: Color(0xFF004DFF), fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
      onTap: () async {
        setState(() {
          _count < 5 ? _count++ : _invitationLimit();
        });
      },
    );
  }

  Widget _textField(int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 10),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Form(
            //    key: _formKey1,
            child: TextFormField(
              //    validator: _validate,
              style: TextStyle(
                fontSize: 17.0,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10),
                suffix: IconButton(
                  onPressed: () {}, //=> widget.controller.clear(),
                  iconSize: 15,
                  icon: Icon(CupertinoIcons.clear_thick_circled),
                  color: Color(0xffeeeeef),
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 0.0,
                    style: BorderStyle.none,
                  ),
                ),
              ),
              onChanged: (text) {
                _onUpdate(index, text);
              },
            ),
          ),
        ),
      ),
    );
  }
}
