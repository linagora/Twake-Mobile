import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';
import 'package:twake/config/image_path.dart';
import 'package:twake/config/styles_config.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class InvitationPeopleEmailPage extends StatefulWidget {
  const InvitationPeopleEmailPage({Key? key}) : super(key: key);

  @override
  _InvitationPeopleEmailPageState createState() => _InvitationPeopleEmailPageState();
}

class _InvitationPeopleEmailPageState extends State<InvitationPeopleEmailPage> {

  String? invitationUrl;
  late List<TextEditingController> controllers;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    invitationUrl = Get.arguments;
    controllers = []..add(TextEditingController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0))),
          child: Column(
            children: [
              _buildHeaderViewSection(),
              Expanded(child: _buildBodyViewSection()),
            ],
          )
        ),
      ),
    );
  }

  _buildHeaderViewSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: const Color(0xff004dff),
                ),
              ),
            ),
          ),
          Align(
              alignment: Alignment.center,
              child: Container(
                child: Text(AppLocalizations.of(context)?.inviteUsers ?? '',
                  style: StylesConfig.commonTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 17)
                ),
              )
          ),
          Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                  onTap: () => _handleClickOnButtonSend(),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                      color: Color(0xff004dff)),
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
                    child: Text(AppLocalizations.of(context)?.sendButton.toUpperCase() ?? '',
                      style: StylesConfig.commonTextStyle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13))),
              )
          )
        ],
      ),
    );
  }

  _buildBodyViewSection() {
    return Container(
      color: Color(0xfff2f2f6),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 24),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Divider(height: 0.5),
            ...controllers.map((e) => _buildEmailItem(e)).toList(),
            _buildButtonAddMoreMember()
          ],
        ),
      ),
    );
  }

  Widget _buildEmailItem(TextEditingController editingController) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    child: TextField(
        controller: editingController,
        keyboardType: TextInputType.emailAddress,
        style: StylesConfig.commonTextStyle.copyWith(fontSize: 17, fontWeight: FontWeight.w400),
        decoration: InputDecoration(
            filled: true,
            isDense: true,
            contentPadding: EdgeInsets.only(top: 16, bottom: 16, right: 42, left: 24),
            fillColor: Color(0xfffcfcfc),
            errorText: null,
            hintText: AppLocalizations.of(context)?.addEmailAddress ?? '',
            hintStyle: StylesConfig.commonTextStyle.copyWith(fontSize: 15, color: Color(0xffc8c8c8)),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10.0),
            )
        )
      ),
  );

  _buildButtonAddMoreMember() => GestureDetector(
    onTap: () => _handleClickOnButtonInviteMore(),
    child: Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Color(0xfffcfcfc)),
      child: Row(
        children: [
          Image.asset(imageAddMemberEmail, width: 24, height: 24),
          SizedBox(width: 8),
          Text(AppLocalizations.of(context)?.inviteAnotherMember ?? '',
            style: StylesConfig.commonTextStyle.copyWith(color: Color(0xff004dff), fontSize: 15),
          )
        ],
      ),
    ),
  );

  _handleClickOnButtonInviteMore() async {
    setState(() {
      controllers.add(TextEditingController());
    });
    Timer(Duration(milliseconds: 100), () async {
      await _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
    });
  }

  _handleClickOnButtonSend() async {
    final listEmails = controllers.where((e) => e.text.isNotEmpty).map((e) => e.text).toList();
    final result = await _sendEmail(
        context,
        AppLocalizations.of(context)?.joinMeOnTwake ?? '',
        invitationUrl ?? '',
        listEmails);
    if(result) {
      print('Sent');
    }
  }

  Future<bool> _sendEmail(BuildContext context, String subject, String body, List<String> recipientList) async {
    final Email email = Email(
      subject: subject,
      body: body,
      recipients: recipientList,
    );
    await FlutterEmailSender.send(email).then((value) {
      try {
        return true;
      } catch (e) {
        Logger().e('Error occurred while sending invitation email: $e');
        return false;
      }
    });
    return false;
  }

}
