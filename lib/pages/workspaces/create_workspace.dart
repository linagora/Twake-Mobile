import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:twake/blocs/account_cubit/account_cubit.dart';
import 'package:twake/blocs/channels_cubit/channels_cubit.dart';
import 'package:twake/blocs/workspaces_cubit/workspaces_cubit.dart';
import 'package:twake/config/dimensions_config.dart';
import 'package:twake/models/account/account.dart';
import 'package:twake/models/globals/globals.dart';
import 'package:twake/routing/app_router.dart';
import 'package:twake/widgets/common/pick_image_widget.dart';
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
          title: Text(AppLocalizations.of(context)!.invitationLimit,
              style: Theme.of(context).textTheme.headline2),
          content: Text(
              '${AppLocalizations.of(context)!.invitationLimitInfo} ${user!.email}',
              style: Theme.of(context).textTheme.headline2),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(AppLocalizations.of(context)!.ok,
                  style: Theme.of(context).textTheme.headline2),
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
    if (text.indexOf(" ") != -1) {
      text = text.substring(0, text.indexOf(" "));
    }
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
    _members.removeWhere((e) => e == "");
  }

  _createWorkspace() async {
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
          content: Text(AppLocalizations.of(context)!.processing,
              style: Theme.of(context).textTheme.headline2),
        ),
      );

      await Get.find<WorkspacesCubit>().createWorkspace(
        companyId: Globals.instance.companyId,
        name: _workspaceNameController.text,
        members: _members,
      );

      Get.find<ChannelsCubit>().fetch(
        workspaceId: Globals.instance.workspaceId!,
        companyId: Globals.instance.companyId,
      );

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
            AppLocalizations.of(context)!.workspaceCreationErrorInfo,
            style: Theme.of(context).textTheme.headline2,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(minHeight: Dim.heightPercent(100)),
            child: Column(
              children: [
                Container(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: SheetTitleBar(
                      title: AppLocalizations.of(context)!.newWorkspace,
                      leadingTitle: AppLocalizations.of(context)!.cancel,
                      leadingAction: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        popBack();
                      },
                      trailingTitle: AppLocalizations.of(context)!.create,
                      trailingAction: () {
                        _createWorkspace();
                      }),
                ),
                Container(
                  height: 16,
                  constraints: BoxConstraints(minHeight: 2),
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Container(
                            child: Row(
                              children: [
                                PickImageWidget(onPickImageWidgetClick: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                }),
                                /*Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Icon(
                                      Icons.camera_alt_rounded,
                                      color: Theme.of(context)
                                          .textTheme
                                          .headline2!
                                          .color,
                                    ),
                                    height: 44,
                                    width: 44,
                                  ),*/

                                Flexible(
                                  child: Center(
                                    child: Form(
                                      key: _formKey,
                                      child: SheetTextField(
                                        hint: AppLocalizations.of(context)!
                                            .workspaceNameInfo,
                                        controller: _workspaceNameController,
                                        focusNode: _workspaceNameFocusNode,
                                        maxLength: 30,
                                        isRounded: true,
                                        borderRadius: 8,
                                        textInputType: TextInputType.text,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return AppLocalizations.of(context)!
                                                .workspaceNameError;
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
                        text: AppLocalizations.of(context)!
                            .workspaceCreationErrorInfo,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 40,
                  constraints: BoxConstraints(minHeight: 2),
                ),
                HintLine(
                  text: AppLocalizations.of(context)!.addYourTeamMembers,
                  isLarge: true,
                  fontWeight: FontWeight.w500,
                ),
                Container(
                  height: 12,
                  constraints: BoxConstraints(minHeight: 3),
                ),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _count,
                  itemBuilder: (context, index) {
                    return _textField(index, _controllers[index]);
                  },
                ),
                _addMember(),
              ],
            ),
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
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.add_circled_solid,
                  color: Theme.of(context).colorScheme.surface,
                  size: 25,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  AppLocalizations.of(context)!.addEmail,
                  style: Theme.of(context).textTheme.headline4,
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
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Form(
          //    key: _formKey1,
          child: TextFormField(
            maxLines: 1,
            controller: controller,
            //    validator: _validate,
            style: Theme.of(context)
                .textTheme
                .headline1!
                .copyWith(fontSize: 18, fontWeight: FontWeight.w400),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(left: 15),
              suffix: IconButton(
                onPressed: () {
                  controller.clear();
                  _onUpdate(index, " ");
                },
                iconSize: 17,
                icon: Icon(CupertinoIcons.clear_thick_circled),
                color: Theme.of(context).colorScheme.secondary,
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
