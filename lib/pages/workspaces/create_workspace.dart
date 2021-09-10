import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_state.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/routing/app_router.dart';
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
  List<Map<String, dynamic>> _membersList = [];
  List<String> _members = [];
  List<TextEditingController> _controllers = [];
  Account? user;

  @override
  void initState() {
    super.initState();
    user = (Get.find<AccountCubit>().state as AccountLoadSuccess).account;
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
              'To add more team members,please, verify your account. We sent verification details to: ${user!.email}'),
          actions: <Widget>[
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
    for (var map in _membersList) {
      if (map.containsKey("index")) {
        if (map["index"] == index) {
          foundIndex = index;
          break;
        }
      }
    }
    if (-1 != foundIndex) {
      _membersList.removeWhere((map) {
        return map["index"] == foundIndex;
      });
    }

    Map<String, dynamic> member = {'index': index, 'text': text};
    _membersList.add(member);
    _members = [];
    _membersList.forEach((map) {
      var _list = map.values.toList();
      _members.add(_list[1]);
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
                  title: AppLocalizations.of(context)!.newWorkspace,
                  leadingTitle: AppLocalizations.of(context)!.cancel,
                  leadingAction: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    popBack();
                  },
                  trailingTitle: AppLocalizations.of(context)!.create,
                  trailingAction: () async {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          margin: EdgeInsets.fromLTRB(
                            15.0,
                            5.0,
                            15.0,
                            65.0,
                            //  Dim.heightPercent(8),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 3),
                          content: Text('Processing'),
                        ),
                      );

                      await Get.find<WorkspacesCubit>().createWorkspace(
                        companyId: Globals.instance.companyId,
                        name: _workspaceNameController.text,
                        members: _members,
                      );

                      final state = Get.find<WorkspacesCubit>().state;
                      if (state is WorkspacesLoadSuccess) {
                        Get.find<WorkspacesCubit>()
                            .selectWorkspace(workspaceId: state.selected!.id);

                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            margin: EdgeInsets.fromLTRB(
                              15.0,
                              5.0,
                              15.0,
                              65.0,
                              //  Dim.heightPercent(8),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 3),
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
              Column(
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
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        child: Container(
                          child: Row(
                            children: [
                              GestureDetector(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(10.0),
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
                                      controller: _workspaceNameController,
                                      focusNode: _workspaceNameFocusNode,
                                      maxLength: 30,
                                      isRounded: true,
                                      borderRadius: 8,
                                      textInputType: TextInputType.text,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
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
              ),
              SizedBox(height: 40),
              HintLine(
                text: 'ADD YOUR TEAM MEMBERS',
                isLarge: true,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(
                height: 10,
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _count,
                  itemBuilder: (context, index) {
                    return _textField(index, _controllers[index]);
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
          _controllers.add(TextEditingController());
          _count < 5 || user!.isVerified ? _count++ : _invitationLimit();
        });
      },
    );
  }

  Widget _textField(int index, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 10),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Form(
          //    key: _formKey1,
          child: TextFormField(
            maxLines: 1,
            controller: controller,
            //    validator: _validate,
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(left: 15),
              suffix: IconButton(
                onPressed: () {
                  controller.clear();
                },
                iconSize: 17,
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
    );
  }
}
